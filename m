From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL + Basic Latency under load results - 100Mbit, GSO/TSO off,
 pfifo_fast vs SFQ vs QFQ
Date: Mon, 02 Jan 2012 06:27:09 +0100
Message-ID: <1325482029.2526.26.camel@edumazet-laptop>
References: <CAA93jw6r45zBn4p76R9-2UNdp=OM+uiYqPKcKnjqBReR_oh1BA@mail.gmail.com>
	 <CAA93jw5JjVBQOFL=td55rOpXbUYc=uT_rjeY04O137g_-tBJHw@mail.gmail.com>
	 <CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
	 <1325478811.2526.10.camel@edumazet-laptop>
	 <1325480125.2526.13.camel@edumazet-laptop>
	 <1325480861.2526.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg@freedesktop.org, Stephen Hemminger <shemminger@vyatta.com>,
	Juliusz Chroboczek <jch@pps.jussieu.fr>,
	Kathleen Nichols <nichols@pollere.com>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63677 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab2ABF1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 00:27:14 -0500
Received: by wgbdr13 with SMTP id dr13so26264916wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2012 21:27:13 -0800 (PST)
In-Reply-To: <1325480861.2526.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 06:07 +0100, Eric Dumazet a =C3=A9crit =
:
> Le lundi 02 janvier 2012 =C3=A0 05:55 +0100, Eric Dumazet a =C3=A9cri=
t :
>=20
> > I tested this patch with a 50 concurrent netperf workload, and inde=
ed
> > this fixes the problem for me.
> >=20
> > # ping 192.168.20.108
> > PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
> > 64 bytes from 192.168.20.108: icmp_req=3D1 ttl=3D64 time=3D0.021 ms
> > 64 bytes from 192.168.20.108: icmp_req=3D2 ttl=3D64 time=3D0.011 ms
> > 64 bytes from 192.168.20.108: icmp_req=3D3 ttl=3D64 time=3D0.011 ms
> > 64 bytes from 192.168.20.108: icmp_req=3D4 ttl=3D64 time=3D0.010 ms
> > 64 bytes from 192.168.20.108: icmp_req=3D5 ttl=3D64 time=3D0.010 ms
> > 64 bytes from 192.168.20.108: icmp_req=3D6 ttl=3D64 time=3D0.010 ms
> >=20
>=20
> Oops, pinging a real machine, not myself I get more realistic numbers=
 :)
>=20
> # ping -c 20 192.168.20.112
> PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
> 64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.488 ms
> 64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.214 ms
> 64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.696 ms
> 64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.135 ms
> 64 bytes from 192.168.20.112: icmp_req=3D5 ttl=3D64 time=3D0.110 ms
> 64 bytes from 192.168.20.112: icmp_req=3D6 ttl=3D64 time=3D0.401 ms
> 64 bytes from 192.168.20.112: icmp_req=3D7 ttl=3D64 time=3D0.378 ms
> 64 bytes from 192.168.20.112: icmp_req=3D8 ttl=3D64 time=3D0.384 ms
> 64 bytes from 192.168.20.112: icmp_req=3D9 ttl=3D64 time=3D1.03 ms
> 64 bytes from 192.168.20.112: icmp_req=3D10 ttl=3D64 time=3D0.439 ms
> 64 bytes from 192.168.20.112: icmp_req=3D11 ttl=3D64 time=3D0.126 ms
> 64 bytes from 192.168.20.112: icmp_req=3D12 ttl=3D64 time=3D0.093 ms
> 64 bytes from 192.168.20.112: icmp_req=3D13 ttl=3D64 time=3D0.834 ms
> 64 bytes from 192.168.20.112: icmp_req=3D14 ttl=3D64 time=3D0.696 ms
> 64 bytes from 192.168.20.112: icmp_req=3D15 ttl=3D64 time=3D0.776 ms
> 64 bytes from 192.168.20.112: icmp_req=3D16 ttl=3D64 time=3D0.215 ms
> 64 bytes from 192.168.20.112: icmp_req=3D17 ttl=3D64 time=3D0.262 ms
> 64 bytes from 192.168.20.112: icmp_req=3D18 ttl=3D64 time=3D0.554 ms
> 64 bytes from 192.168.20.112: icmp_req=3D19 ttl=3D64 time=3D0.373 ms
> 64 bytes from 192.168.20.112: icmp_req=3D20 ttl=3D64 time=3D0.666 ms
>=20
> --- 192.168.20.112 ping statistics ---
> 20 packets transmitted, 20 received, 0% packet loss, time 19000ms
> rtt min/avg/max/mdev =3D 0.093/0.443/1.035/0.264 ms
>=20

And after disabling TSO (as you did in your tests) I get this :
(Note my link is Gigabit, so I had to install a HTB shaper to 100Mbit t=
o
mimic your workload)

# ping -c 20 192.168.20.112
PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.113 ms
64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.153 ms
64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.092 ms
64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.095 ms
64 bytes from 192.168.20.112: icmp_req=3D5 ttl=3D64 time=3D0.176 ms
64 bytes from 192.168.20.112: icmp_req=3D6 ttl=3D64 time=3D0.159 ms
64 bytes from 192.168.20.112: icmp_req=3D7 ttl=3D64 time=3D0.169 ms
64 bytes from 192.168.20.112: icmp_req=3D8 ttl=3D64 time=3D0.122 ms
64 bytes from 192.168.20.112: icmp_req=3D9 ttl=3D64 time=3D0.148 ms
64 bytes from 192.168.20.112: icmp_req=3D10 ttl=3D64 time=3D0.123 ms
64 bytes from 192.168.20.112: icmp_req=3D11 ttl=3D64 time=3D0.186 ms
64 bytes from 192.168.20.112: icmp_req=3D12 ttl=3D64 time=3D0.210 ms
64 bytes from 192.168.20.112: icmp_req=3D13 ttl=3D64 time=3D0.142 ms
64 bytes from 192.168.20.112: icmp_req=3D14 ttl=3D64 time=3D0.134 ms
64 bytes from 192.168.20.112: icmp_req=3D15 ttl=3D64 time=3D0.092 ms
64 bytes from 192.168.20.112: icmp_req=3D16 ttl=3D64 time=3D0.187 ms
64 bytes from 192.168.20.112: icmp_req=3D17 ttl=3D64 time=3D0.123 ms
64 bytes from 192.168.20.112: icmp_req=3D18 ttl=3D64 time=3D0.159 ms
64 bytes from 192.168.20.112: icmp_req=3D19 ttl=3D64 time=3D0.142 ms
64 bytes from 192.168.20.112: icmp_req=3D20 ttl=3D64 time=3D0.207 ms

--- 192.168.20.112 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 18999ms
rtt min/avg/max/mdev =3D 0.092/0.146/0.210/0.037 ms

# tc -s -d cl show dev eth3
class htb 1:1 root leaf 10: prio 0 quantum 80000 rate 100000Kbit ceil 1=
00000Kbit=20
burst 40000b/256 mpu 0b overhead 0b cburst 40000b/256 mpu 0b overhead 0=
b level 0=20
 Sent 4569893772 bytes 3107171 pkt (dropped 43457, overlimits 0 requeue=
s 0)=20
 rate 75836Kbit 6315pps backlog 0b 127p requeues 0=20
 lended: 1204316 borrowed: 0 giants: 0
 tokens: -1892 ctokens: -1892

class sfq 10:1b parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:25 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:34 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:48 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:4b parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot -448=20

class sfq 10:4c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:68 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:96 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:a9 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:c8 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:ca parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:112 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:11a parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:149 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:150 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:16b parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:171 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:185 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:19f parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:1ac parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:1bb parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:1bf parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:1dc parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:1e7 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:1f1 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:201 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:20f parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:216 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:21d parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:22a parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:22e parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:263 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:2d4 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:306 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:307 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:344 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:346 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:34f parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:359 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:36f parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:385 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:3a0 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:3a4 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 1514b 1p requeues 0=20
 allot 0=20

class sfq 10:3ac parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 3028b 2p requeues 0=20
 allot 1520=20

class sfq 10:3ee parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20

class sfq 10:3fe parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1520=20
