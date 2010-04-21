From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 11:02:15 +0200
Message-ID: <1271840535.7895.1612.camel@edumazet-laptop>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55613 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab0DUJC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 05:02:26 -0400
Received: by bwz25 with SMTP id 25so7800100bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 02:02:24 -0700 (PDT)
In-Reply-To: <20100421082559.GA32475@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 12:25 +0400, Evgeniy Polyakov a =C3=A9=
crit :

> I believe this is a useful patch, but it addresses a different issue.
> This path should not fire up when we bind to single address.

Well, the real problem is that following sequence can happen :

socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 5
setsockopt(5, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(5, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_addr=
("127.0.0.2")}, 16) =3D 0
getsockname(5, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_addr=3D=
inet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 6
setsockopt(6, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(6, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_addr=
("127.0.0.2")}, 16) =3D 0
getsockname(6, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_addr=3D=
inet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 7
setsockopt(7, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(7, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_addr=
("127.0.0.2")}, 16) =3D 0
getsockname(7, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_addr=3D=
inet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 8
setsockopt(8, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(8, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_addr=
("127.0.0.2")}, 16) =3D 0
getsockname(8, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_addr=3D=
inet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 9
setsockopt(9, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(9, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_addr=
("127.0.0.2")}, 16) =3D 0
getsockname(9, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_addr=3D=
inet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 10
setsockopt(10, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(10, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_add=
r("127.0.0.2")}, 16) =3D 0
getsockname(10, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_addr=
=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 11
setsockopt(11, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(11, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_add=
r("127.0.0.2")}, 16) =3D 0
getsockname(11, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_addr=
=3Dinet_addr("127.0.0.2")}, [16]) =3D 0


Note ports are given several times for different sockets.

So several sockets are 'bound' to same IP:port values

At connect() time, we refuse and say address is not available.



=46ollowing program to demonstrate the problem.

=46irst time, launch it with an extra agument to setup ip aliases and i=
p_local_port_range




#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <errno.h>

int listenfd;
int on =3D 1;

void listener()
{
	if (fork())
		return;

	while (1) {
		struct sockaddr_in addr;
		socklen_t len =3D sizeof(addr);
		int fd =3D accept(listenfd, (struct sockaddr *)&addr, &len);
	}
}

int main(int argc, char *argv[])
{
	int i, port, total =3D 0;
	char cmd[128];
	struct sockaddr_in addr;
	socklen_t len;

	if (argc > 1) {
		for (i =3D 2; i < 8; i++) {
			sprintf(cmd, "ip addr add 127.0.0.%d/8 dev lo 2>/dev/null", i);
			system(cmd);
		}
		system("echo '34000 34002' >/proc/sys/net/ipv4/ip_local_port_range");
	}
	listenfd =3D socket(AF_INET, SOCK_STREAM, 0);
	setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
	memset(&addr, 0, sizeof(addr));
	addr.sin_family =3D AF_INET;
	addr.sin_port =3D htons(4444);
	if (bind(listenfd, (struct sockaddr *)&addr, sizeof(addr)) =3D=3D -1) =
{
		perror("bind");
		return 1;
	}
	listen(listenfd, 10);
	listener();

	for (i =3D 2; i < 8; i++) {
		for (port =3D 34000; port < 34010; port++) {
			int fd =3D socket(AF_INET, SOCK_STREAM, 0);
			if (fd =3D=3D -1) {
				fprintf(stderr, "Could not open socket, errno=3D%d\n", errno);
				goto end;
			}
			setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
			addr.sin_addr.s_addr =3D htonl(0x7f000000 + i);
//			addr.sin_port =3D htons(port);
			addr.sin_port =3D 0;
			if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) =3D=3D -1) {
				fprintf(stderr, "Could not bind()\n");
				goto end;
			}
			len =3D sizeof(addr);
			getsockname(fd, (struct sockaddr *)&addr, &len);
#if 0
			addr.sin_addr.s_addr =3D htonl(0x7f000001);
			addr.sin_port =3D htons(4444);
			if ((total < 10) && (connect(fd, (struct sockaddr *)&addr, sizeof(ad=
dr)) =3D=3D -1)) {
				len =3D sizeof(addr);
				getsockname(fd, (struct sockaddr *)&addr, &len);
				fprintf(stderr, "Could not connect()\n");
				goto end;
			}
#endif
			total++;
		}
	}
end:
	printf("i=3D127.0.0.%d port=3D%d (total=3D%d)\n", i, port, total);
	pause();
}


