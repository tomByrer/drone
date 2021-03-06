
all: embed build

deps:
	go get code.google.com/p/go.crypto/bcrypt
	go get code.google.com/p/go.crypto/ssh
	go get code.google.com/p/go.net/websocket
	go get code.google.com/p/go.text/unicode/norm
	go get launchpad.net/goyaml
	go get github.com/andybons/hipchat
	go get github.com/bmizerany/pat
	go get github.com/dchest/authcookie
	go get github.com/dchest/passwordreset
	go get github.com/dchest/uniuri
	go get github.com/dotcloud/docker/archive
	go get github.com/dotcloud/docker/pkg/term
	go get github.com/dotcloud/docker/utils
	go get github.com/drone/go-github/github
	go get github.com/drone/go-bitbucket/bitbucket
	go get github.com/GeertJohan/go.rice
	go get github.com/GeertJohan/go.rice/rice
	go get github.com/mattn/go-sqlite3
	go get github.com/russross/meddler

embed:
	cd cmd/droned   && rice embed
	cd pkg/template && rice embed

build:
	cd cmd/drone  && go build -o ../../bin/drone
	cd cmd/droned && go build -o ../../bin/droned

test:
	go test -v github.com/drone/drone/pkg/build
	go test -v github.com/drone/drone/pkg/build/buildfile
	go test -v github.com/drone/drone/pkg/build/docker
	go test -v github.com/drone/drone/pkg/build/dockerfile
	go test -v github.com/drone/drone/pkg/build/proxy
	go test -v github.com/drone/drone/pkg/build/repo
	go test -v github.com/drone/drone/pkg/build/script
	go test -v github.com/drone/drone/pkg/channel
	go test -v github.com/drone/drone/pkg/database
	go test -v github.com/drone/drone/pkg/database/encrypt
	go test -v github.com/drone/drone/pkg/database/testing
	go test -v github.com/drone/drone/pkg/mail
	go test -v github.com/drone/drone/pkg/model
	go test -v github.com/drone/drone/pkg/queue

install:
	cp deb/drone/etc/init/drone.conf /etc/init/drone.conf
	test -f /etc/default/drone || cp deb/drone/etc/default/drone /etc/default/drone
	cd bin && install -t /usr/local/bin drone
	cd bin && install -t /usr/local/bin droned
	mkdir -p /var/lib/drone

clean:
	cd cmd/droned   && rice clean
	cd pkg/template && rice clean
	rm -rf cmd/drone/drone
	rm -rf cmd/droned/droned
	rm -rf cmd/droned/drone.sqlite
	rm -rf bin/drone
	rm -rf bin/droned
	rm -rf deb/drone.deb
	rm -rf usr/local/bin/drone
	rm -rf usr/local/bin/droned
	rm -rf drone.sqlite

# creates a debian package for drone
# to install `sudo dpkg -i drone.deb`
dpkg:
	mkdir -p deb/drone/usr/local/bin
	mkdir -p deb/drone/var/lib/drone
	cp bin/drone  deb/drone/usr/local/bin
	cp bin/droned deb/drone/usr/local/bin
	dpkg-deb --build deb/drone

run:
	bin/droned --port=":8080" --datasource="/tmp/drone.sqlite"
