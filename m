From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 15:00:22 +0100
Message-ID: <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41911 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939Ab1LWOA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 09:00:26 -0500
Received: by wgbdr13 with SMTP id dr13so17504099wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 06:00:25 -0800 (PST)
In-Reply-To: <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 14:45 +0100, Eric Dumazet a =C3=
=A9crit :

> 1) What kernel version do you use ?
>=20
> 2) How many concurrent flows are running (number of netperf/netcat)
>=20
> 3) Remind that 'perturb xxx' introduces a temporary doubling of the
> number of flows.
>=20
> 4) Had you disabled tso on eth1 ?
>    (If not, you might send 64Kbytes packets, and at 400kbit, they tak=
e a
> lot of time to transmit : more than one second ...)
>=20
>=20

Using your script on net-next, (only using eth3 instead of eth1) and

ethtool -K eth3 tso off
ethtool -K eth3 gso off
ip ro flush cache

one ssh : dd if=3D/dev/zero | ssh 192.168.0.1 "dd of=3D/dev/null"
my ping is quite good :


$ ping -c 20 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
2011/11/23 14:57:01.106 64 bytes from 192.168.0.1: icmp_seq=3D1 ttl=3D6=
4 time=3D59.4 ms
2011/11/23 14:57:02.121 64 bytes from 192.168.0.1: icmp_seq=3D2 ttl=3D6=
4 time=3D72.7 ms
2011/11/23 14:57:03.109 64 bytes from 192.168.0.1: icmp_seq=3D3 ttl=3D6=
4 time=3D60.3 ms
2011/11/23 14:57:04.108 64 bytes from 192.168.0.1: icmp_seq=3D4 ttl=3D6=
4 time=3D57.8 ms
2011/11/23 14:57:05.115 64 bytes from 192.168.0.1: icmp_seq=3D5 ttl=3D6=
4 time=3D62.6 ms
2011/11/23 14:57:06.116 64 bytes from 192.168.0.1: icmp_seq=3D6 ttl=3D6=
4 time=3D62.6 ms
2011/11/23 14:57:07.112 64 bytes from 192.168.0.1: icmp_seq=3D7 ttl=3D6=
4 time=3D57.6 ms
2011/11/23 14:57:08.127 64 bytes from 192.168.0.1: icmp_seq=3D8 ttl=3D6=
4 time=3D70.9 ms
2011/11/23 14:57:09.123 64 bytes from 192.168.0.1: icmp_seq=3D9 ttl=3D6=
4 time=3D65.4 ms
2011/11/23 14:57:10.113 64 bytes from 192.168.0.1: icmp_seq=3D10 ttl=3D=
64 time=3D53.5 ms
2011/11/23 14:57:11.127 64 bytes from 192.168.0.1: icmp_seq=3D11 ttl=3D=
64 time=3D66.7 ms
2011/11/23 14:57:12.129 64 bytes from 192.168.0.1: icmp_seq=3D12 ttl=3D=
64 time=3D67.4 ms
2011/11/23 14:57:13.119 64 bytes from 192.168.0.1: icmp_seq=3D13 ttl=3D=
64 time=3D56.3 ms
2011/11/23 14:57:14.127 64 bytes from 192.168.0.1: icmp_seq=3D14 ttl=3D=
64 time=3D64.0 ms
2011/11/23 14:57:15.116 64 bytes from 192.168.0.1: icmp_seq=3D15 ttl=3D=
64 time=3D51.9 ms
2011/11/23 14:57:16.127 64 bytes from 192.168.0.1: icmp_seq=3D16 ttl=3D=
64 time=3D61.2 ms
2011/11/23 14:57:17.127 64 bytes from 192.168.0.1: icmp_seq=3D17 ttl=3D=
64 time=3D60.4 ms
2011/11/23 14:57:18.135 64 bytes from 192.168.0.1: icmp_seq=3D18 ttl=3D=
64 time=3D68.2 ms
2011/11/23 14:57:19.137 64 bytes from 192.168.0.1: icmp_seq=3D19 ttl=3D=
64 time=3D69.1 ms
2011/11/23 14:57:20.136 64 bytes from 192.168.0.1: icmp_seq=3D20 ttl=3D=
64 time=3D67.0 ms

--- 192.168.0.1 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 19022ms
rtt min/avg/max/mdev =3D 51.909/62.796/72.751/5.579 ms

$ tc -s -d class show dev eth3
class hfsc 1: root=20
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
 period 0 level 2=20

class hfsc 1:1 parent 1: sc m1 0bit d 0us m2 1490Kbit ul m1 0bit d 0us =
m2 1490Kbit=20
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
 period 69 work 38559740 bytes level 1=20

class hfsc 1:10 parent 1:1 leaf 1101: rt m1 327680bit d 50.0ms m2 20000=
0bit ls m1 0bit d 0us m2 1000Kbit=20
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
 period 0 level 0=20

class hfsc 1:20 parent 1:1 leaf 1201: rt m1 0bit d 0us m2 400000bit ls =
m1 0bit d 0us m2 200000bit=20
 Sent 38587058 bytes 27022 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 19p requeues 0=20
 period 69 work 38559740 bytes rtwork 10358780 bytes level 0=20

class hfsc 1:30 parent 1:1 leaf 1301: rt m1 605600bit d 20.0ms m2 20000=
bit=20
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
 period 0 level 0=20

class sfq 1201:f7 parent 1201:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 25804b 18p requeues 0=20
 allot -1336=20


Hmm... we probably could fill hfsc class information with non null byte=
s backlog...
I'll take a look.
