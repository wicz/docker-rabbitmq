FROM ubuntu:latest
MAINTAINER Vinicius Horewicz <vinicius@horewi.cz>

RUN sed -i.bak "s/main$/main universe/" /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN locale-gen en_US en_US.UTF-8
RUN echo "root:root" | chpasswd

# initctl workaround
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# prevent services from starting automatically
RUN echo exit 101 > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

RUN apt-get install -y curl monit openssh-server rabbitmq-server

# disable upstart for SSH
RUN mv /etc/init/ssh.conf /etc/init/ssh.conf.dist

ADD ./etc/monit/sshd.conf     /etc/monit/conf.d/sshd.conf
ADD ./etc/monit/rabbitmq.conf /etc/monit/conf.d/rabbitmq.conf

# run monit in foreground
CMD ["/usr/bin/monit", "-I"]

EXPOSE 22 :5672

