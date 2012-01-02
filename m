From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL + Basic Latency under load results - 100Mbit, GSO/TSO off,
 pfifo_fast vs SFQ vs QFQ
Date: Mon, 02 Jan 2012 06:07:41 +0100
Message-ID: <1325480861.2526.15.camel@edumazet-laptop>
References: <CAA93jw6r45zBn4p76R9-2UNdp=OM+uiYqPKcKnjqBReR_oh1BA@mail.gmail.com>
	 <CAA93jw5JjVBQOFL=td55rOpXbUYc=uT_rjeY04O137g_-tBJHw@mail.gmail.com>
	 <CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
	 <1325478811.2526.10.camel@edumazet-laptop>
	 <1325480125.2526.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg@freedesktop.org, Stephen Hemminger <shemminger@vyatta.com>,
	Juliusz Chroboczek <jch@pps.jussieu.fr>,
	Kathleen Nichols <nichols@pollere.com>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:60482 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab2ABFIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 00:08:01 -0500
Received: by wibhm6 with SMTP id hm6so8161797wib.19
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2012 21:08:00 -0800 (PST)
In-Reply-To: <1325480125.2526.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 05:55 +0100, Eric Dumazet a =C3=A9crit =
:

> I tested this patch with a 50 concurrent netperf workload, and indeed
> this fixes the problem for me.
>=20
> # ping 192.168.20.108
> PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
> 64 bytes from 192.168.20.108: icmp_req=3D1 ttl=3D64 time=3D0.021 ms
> 64 bytes from 192.168.20.108: icmp_req=3D2 ttl=3D64 time=3D0.011 ms
> 64 bytes from 192.168.20.108: icmp_req=3D3 ttl=3D64 time=3D0.011 ms
> 64 bytes from 192.168.20.108: icmp_req=3D4 ttl=3D64 time=3D0.010 ms
> 64 bytes from 192.168.20.108: icmp_req=3D5 ttl=3D64 time=3D0.010 ms
> 64 bytes from 192.168.20.108: icmp_req=3D6 ttl=3D64 time=3D0.010 ms
>=20

Oops, pinging a real machine, not myself I get more realistic numbers :=
)

# ping -c 20 192.168.20.112
PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.488 ms
64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.214 ms
64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.696 ms
64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.135 ms
64 bytes from 192.168.20.112: icmp_req=3D5 ttl=3D64 time=3D0.110 ms
64 bytes from 192.168.20.112: icmp_req=3D6 ttl=3D64 time=3D0.401 ms
64 bytes from 192.168.20.112: icmp_req=3D7 ttl=3D64 time=3D0.378 ms
64 bytes from 192.168.20.112: icmp_req=3D8 ttl=3D64 time=3D0.384 ms
64 bytes from 192.168.20.112: icmp_req=3D9 ttl=3D64 time=3D1.03 ms
64 bytes from 192.168.20.112: icmp_req=3D10 ttl=3D64 time=3D0.439 ms
64 bytes from 192.168.20.112: icmp_req=3D11 ttl=3D64 time=3D0.126 ms
64 bytes from 192.168.20.112: icmp_req=3D12 ttl=3D64 time=3D0.093 ms
64 bytes from 192.168.20.112: icmp_req=3D13 ttl=3D64 time=3D0.834 ms
64 bytes from 192.168.20.112: icmp_req=3D14 ttl=3D64 time=3D0.696 ms
64 bytes from 192.168.20.112: icmp_req=3D15 ttl=3D64 time=3D0.776 ms
64 bytes from 192.168.20.112: icmp_req=3D16 ttl=3D64 time=3D0.215 ms
64 bytes from 192.168.20.112: icmp_req=3D17 ttl=3D64 time=3D0.262 ms
64 bytes from 192.168.20.112: icmp_req=3D18 ttl=3D64 time=3D0.554 ms
64 bytes from 192.168.20.112: icmp_req=3D19 ttl=3D64 time=3D0.373 ms
64 bytes from 192.168.20.112: icmp_req=3D20 ttl=3D64 time=3D0.666 ms

--- 192.168.20.112 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 19000ms
rtt min/avg/max/mdev =3D 0.093/0.443/1.035/0.264 ms
