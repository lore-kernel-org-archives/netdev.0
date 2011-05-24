From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 07:43:55 -0700
Message-ID: <20110524074355.422e12f9@nehalam>
References: <1306220681.2638.40.camel@edumazet-laptop>
	<1306222507.2298.23.camel@Joe-Laptop>
	<1306223101.2638.43.camel@edumazet-laptop>
	<20110524.035801.1555795213632087107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, joe@perches.com, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, tgraf@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36778 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842Ab1EXOn6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 10:43:58 -0400
In-Reply-To: <20110524.035801.1555795213632087107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2011 03:58:01 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 24 May 2011 09:45:01 +0200
>=20
> > Le mardi 24 mai 2011 =C3=A0 00:35 -0700, Joe Perches a =C3=A9crit :
> >=20
> >> I think it's be better without the casts
> >> using the standard kernel.h macros.
> >>=20
> >> 	void *ptr;
> >>=20
> >> 	ptr =3D maybe_hide_ptr(sk);
> >> 	r->id.idiag_cookie[0] =3D lower_32_bits(ptr);
> >> 	r->id.idiag_cookie[1] =3D upper_32_bits(ptr);
> >>=20
> >=20
> > I am not sure I want to patch lower_32_bits() and upper_32_bits() f=
or
> > this.
> >=20
> > They dont work on pointers, but on "numbers", according to kerneldo=
c
> > Andrew wrote years ago. gcc agrees :
> >=20
> > net/ipv4/inet_diag.c: In function =E2=80=98inet_csk_diag_fill=E2=80=
=99:
> > net/ipv4/inet_diag.c:119: warning: cast from pointer to integer of =
different size
> > net/ipv4/inet_diag.c:120: error: invalid operands to binary >>
> > make[1]: *** [net/ipv4/inet_diag.o] Error 1
>=20
> Also you can't do this, the "cookie" is used by the kernel future
> lookups to find sockets.
>=20
> The kernel pointer is part of the API, so sorry you can't "hide"
> kernel pointers in this case without really breaking user visible
> things.
> [Error decoding BASE64]

Couldn't the pointer be replaced by a socket index?

--=20
