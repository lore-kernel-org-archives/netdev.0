From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Thu, 26 May 2011 17:14:49 -0700
Message-ID: <20110527001449.GS19633@outflux.net>
References: <1306223101.2638.43.camel@edumazet-laptop>
 <20110524.035801.1555795213632087107.davem@davemloft.net>
 <20110525232921.GD19633@outflux.net>
 <20110525.215040.47969627064310792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, joe@perches.com, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	tgraf@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:56725 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755356Ab1E0APQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 20:15:16 -0400
Content-Disposition: inline
In-Reply-To: <20110525.215040.47969627064310792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 09:50:40PM -0400, David Miller wrote:
> From: Kees Cook <kees.cook@canonical.com>
> Date: Wed, 25 May 2011 16:29:21 -0700
>=20
> > Hi David,
> >=20
> > On Tue, May 24, 2011 at 03:58:01AM -0400, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Tue, 24 May 2011 09:45:01 +0200
> >>=20
> >> > Le mardi 24 mai 2011 =C3=A0 00:35 -0700, Joe Perches a =C3=A9cri=
t :
> >> >=20
> >> >> I think it's be better without the casts
> >> >> using the standard kernel.h macros.
> >> >>=20
> >> >> 	void *ptr;
> >> >>=20
> >> >> 	ptr =3D maybe_hide_ptr(sk);
> >> >> 	r->id.idiag_cookie[0] =3D lower_32_bits(ptr);
> >> >> 	r->id.idiag_cookie[1] =3D upper_32_bits(ptr);
> >> >>=20
> >> >=20
> >> > I am not sure I want to patch lower_32_bits() and upper_32_bits(=
) for
> >> > this.
> >> >=20
> >> > They dont work on pointers, but on "numbers", according to kerne=
ldoc
> >> > Andrew wrote years ago. gcc agrees :
> >> >=20
> >> > net/ipv4/inet_diag.c: In function =E2=80=98inet_csk_diag_fill=E2=
=80=99:
> >> > net/ipv4/inet_diag.c:119: warning: cast from pointer to integer =
of different size
> >> > net/ipv4/inet_diag.c:120: error: invalid operands to binary >>
> >> > make[1]: *** [net/ipv4/inet_diag.o] Error 1
> >>=20
> >> Also you can't do this, the "cookie" is used by the kernel future
> >> lookups to find sockets.
> >>=20
> >> The kernel pointer is part of the API, so sorry you can't "hide"
> >> kernel pointers in this case without really breaking user visible
> >> things.
> >=20
> > But this is precisely what we're trying to control with kptr_restri=
ct.
> > Setting kptr_restrict will make inet_diag (and some details of simi=
lar
> > things in /proc) meaningless. Based on the name, "diag" isn't going=
 to be
> > used in normal operation, and kptr_restrict is 0 by default, so onl=
y system
> > owners interested in this will enable it and effectively disable in=
et_diag.
>=20
> Are you kidding me?
>=20
> inet_diag is the standard way to dump sockets using netlink.
> It's not a special obscure debugging facility, it's for real
> users.
>=20
> And the encoded kernel pointer here is used as a shortcut to looking
> up precise sockets.

We got this dropped from the /proc view; why can't we do the same for
this netlink interface?

-Kees

--=20
Kees Cook
Ubuntu Security Team
