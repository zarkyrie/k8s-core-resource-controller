FROM golang:1.17 as builder
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct
ARG GOOS=linux
ARG GOARCH=amd64
WORKDIR /go/cache
ADD go.mod .
ADD go.sum .
RUN go mod tidy

WORKDIR /build
ADD . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o demo-controller ./main.go

FROM alpine:latest
COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY --from=builder /build/kubernetes-core-resource-controller /kubernets-controller/kubernetes-core-resource-controller
RUN chmod +x /kubernets-controller/kubernetes-core-resource-controller
ENTRYPOINT ["/kubernets-controller/kubernetes-core-resource-controller"]