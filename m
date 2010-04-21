From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 13:58:12 +0400
Message-ID: <20100421095812.GA14778@ioremap.net>
References: <4BCE33B9.8050101@candelatech.com> <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com> <4BCE392F.60104@candelatech.com> <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com> <4BCE3D8D.3030500@candelatech.com> <1271808314.7895.614.camel@edumazet-laptop> <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:43948 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab0DUJ6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 05:58:17 -0400
Content-Disposition: inline
In-Reply-To: <1271840535.7895.1612.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 11:02:15AM +0200, Eric Dumazet (eric.dumazet@gm=
ail.com) wrote:
> Le mercredi 21 avril 2010 =C3=A0 12:25 +0400, Evgeniy Polyakov a =C3=A9=
crit :
>=20
> > I believe this is a useful patch, but it addresses a different issu=
e.
> > This path should not fire up when we bind to single address.
>=20
> Well, the real problem is that following sequence can happen :
>=20
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 5
> setsockopt(5, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(5, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_ad=
dr("127.0.0.2")}, 16) =3D 0
> getsockname(5, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_add=
r=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 6
> setsockopt(6, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(6, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_ad=
dr("127.0.0.2")}, 16) =3D 0
> getsockname(6, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_add=
r=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 7
> setsockopt(7, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(7, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_ad=
dr("127.0.0.2")}, 16) =3D 0
> getsockname(7, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_add=
r=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 8
> setsockopt(8, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(8, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_ad=
dr("127.0.0.2")}, 16) =3D 0
> getsockname(8, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_add=
r=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 9
> setsockopt(9, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(9, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_ad=
dr("127.0.0.2")}, 16) =3D 0
> getsockname(9, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_add=
r=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 10
> setsockopt(10, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(10, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_a=
ddr("127.0.0.2")}, 16) =3D 0
> getsockname(10, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_ad=
dr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 11
> setsockopt(11, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(11, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_a=
ddr("127.0.0.2")}, 16) =3D 0
> getsockname(11, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_ad=
dr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
>=20
>=20
> Note ports are given several times for different sockets.
>=20
> So several sockets are 'bound' to same IP:port values

That's kind of weird, since address is the same. I'm curious why bind
conflict does not resolve that. Likely because socket is not yet
connected.

> At connect() time, we refuse and say address is not available.

Yup. But isn't it a different problem from what Gaspar observed?
Netcat connects after bind so it should not be an issue here.

--=20
	Evgeniy Polyakov
