From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 14:50:55 -0300
Message-ID: <20080513175055.GI15306@ghostprotocols.net>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, Ulrich Drepper <drepper@redhat.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51497 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752851AbYEMRwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:52:10 -0400
Content-Disposition: inline
In-Reply-To: <200805132037.39580.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, May 13, 2008 at 08:37:38PM +0300, R=E9mi Denis-Courmont escreve=
u:
> Le Tuesday 13 May 2008 20:03:25 Gerrit Renker, vous avez =E9crit=A0:
> > Using work-arounds is brittle and frustrating when the API behaviou=
r
> > suddenly changes. My experience of using such a wrapper was:
> >
> >  * it passed UDP(-Lite), TCP through without changing the socket ty=
pe;
> >  * when passed DCCP, it set the socket type to 0, to avoid `ai_sock=
type
> >    not supported' getaddrinfo error;
>=20
> >  * this used to work fine until about January, when something in th=
e
> >    lookup machinery for dual-stack hosts changed:
> >    - before, AF_UNSPEC + ai_socktype=3D0 put IPv6 first into the re=
sult list,
> >    - now the the result order is reversed (IPv4 sockets are returne=
d first)
>=20
> You're probably using a recent libc that applies RFC3484 _properly_. =
If you=20
> still want IPv6 first, no matter what addresses the host has, I think=
 the=20
> AI_PASSIVE flag should do the trick. Then again, working around RFC34=
84=20
> policy is _not_ a good idea.
>=20
> As far as I am concerned, for DCCP, I (meaning VLC) currently use SOC=
K_STREAM,=20
> and overrides the socktype and protocol fields in the socket() call=20
> manually - so I don't get a TCP socjet.
>=20
> In any case, getaddrinfo() should be patched to
> 1/ accept ai_socktype =3D=3D SOCK_DCCP and ai_protocol =3D=3D IPPROTO=
_DCCP,
> 2/ accept ai_socktype =3D=3D SOCK_DCCP and ai_protocol =3D=3D 0,
>    and set ai_protocol to IPPROTO_DCCP in the results,
> 3/ (perhaps?) accept ai_protocol =3D=3D IPPROTO_DCCP and ai_socktype =
=3D=3D 0,
>    and set ai_socktype to SOCK_DCCP in the results.
>=20
> Similarly:
> 1/ accept ai_socktype =3D=3D SOCK_DGRAM and ai_protocol =3D=3D IPPROT=
O_UDPLITE,
> 2/ (intentionally omitted - keep normal UDP non-Lite behavior)
> 3/ (perhaps?) accept ai_protocol =3D=3D IPPROTO_UDPLITE and ai_sockty=
pe =3D=3D 0,
>    and set ai_socktype to SOCK_DGRAM in the results.
>=20
> Voil=E0. Best to check this with Ulrich Drepper, no?

Cest bon! Agreed. Ulrich?

- Arnaldo
