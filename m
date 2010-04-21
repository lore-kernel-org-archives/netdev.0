From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 12:21:31 +0200
Message-ID: <1271845291.7895.1780.camel@edumazet-laptop>
References: <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48241 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab0DUKVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 06:21:41 -0400
Received: by bwz25 with SMTP id 25so7899186bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 03:21:40 -0700 (PDT)
In-Reply-To: <20100421095812.GA14778@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 13:58 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> On Wed, Apr 21, 2010 at 11:02:15AM +0200, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
> > Le mercredi 21 avril 2010 =C3=A0 12:25 +0400, Evgeniy Polyakov a =C3=
=A9crit :
> >=20
> > > I believe this is a useful patch, but it addresses a different is=
sue.
> > > This path should not fire up when we bind to single address.
> >=20
> > Well, the real problem is that following sequence can happen :
> >=20
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 5
> > setsockopt(5, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(5, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_=
addr("127.0.0.2")}, 16) =3D 0
> > getsockname(5, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_a=
ddr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 6
> > setsockopt(6, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(6, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_=
addr("127.0.0.2")}, 16) =3D 0
> > getsockname(6, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_a=
ddr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 7
> > setsockopt(7, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(7, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_=
addr("127.0.0.2")}, 16) =3D 0
> > getsockname(7, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_a=
ddr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 8
> > setsockopt(8, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(8, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_=
addr("127.0.0.2")}, 16) =3D 0
> > getsockname(8, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_a=
ddr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 9
> > setsockopt(9, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(9, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_=
addr("127.0.0.2")}, 16) =3D 0
> > getsockname(9, {sa_family=3DAF_INET, sin_port=3Dhtons(34000), sin_a=
ddr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 10
> > setsockopt(10, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(10, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet=
_addr("127.0.0.2")}, 16) =3D 0
> > getsockname(10, {sa_family=3DAF_INET, sin_port=3Dhtons(34002), sin_=
addr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> > socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 11
> > setsockopt(11, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> > bind(11, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet=
_addr("127.0.0.2")}, 16) =3D 0
> > getsockname(11, {sa_family=3DAF_INET, sin_port=3Dhtons(34001), sin_=
addr=3Dinet_addr("127.0.0.2")}, [16]) =3D 0
> >=20
> >=20
> > Note ports are given several times for different sockets.
> >=20
> > So several sockets are 'bound' to same IP:port values
>=20
> That's kind of weird, since address is the same. I'm curious why bind
> conflict does not resolve that. Likely because socket is not yet
> connected.
>=20
> > At connect() time, we refuse and say address is not available.
>=20
> Yup. But isn't it a different problem from what Gaspar observed?
> Netcat connects after bind so it should not be an issue here.
>=20

Well, just replace the "#if 0" in program, and i'll connect, and
reproduce same problem

conflict only checks :

                        if (!reuse || !sk2->sk_reuse ||
                            sk2->sk_state =3D=3D TCP_LISTEN) {
                                const __be32 sk2_rcv_saddr =3D
inet_rcv_saddr(sk2);
                                if (!sk2_rcv_saddr || !sk_rcv_saddr ||
                                    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
                                        break;
                        }


ie it wont re-allocate a port only if a listener uses this port.

If sk2 is connected or close, it doesnt matter, and port can be reused.



