From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 09:45:01 +0200
Message-ID: <1306223101.2638.43.camel@edumazet-laptop>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
	 <20110524.011330.1077020828173889583.davem@davemloft.net>
	 <1306217837.2638.36.camel@edumazet-laptop>
	 <1306218793.2298.10.camel@Joe-Laptop>  <20110524065715.GB12816@elte.hu>
	 <1306220681.2638.40.camel@edumazet-laptop>
	 <1306222507.2298.23.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, tgraf@infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35284 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab1EXHpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:45:07 -0400
Received: by wwa36 with SMTP id 36so7017243wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 00:45:06 -0700 (PDT)
In-Reply-To: <1306222507.2298.23.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 00:35 -0700, Joe Perches a =C3=A9crit :

> I think it's be better without the casts
> using the standard kernel.h macros.
>=20
> 	void *ptr;
>=20
> 	ptr =3D maybe_hide_ptr(sk);
> 	r->id.idiag_cookie[0] =3D lower_32_bits(ptr);
> 	r->id.idiag_cookie[1] =3D upper_32_bits(ptr);
>=20

I am not sure I want to patch lower_32_bits() and upper_32_bits() for
this.

They dont work on pointers, but on "numbers", according to kerneldoc
Andrew wrote years ago. gcc agrees :

net/ipv4/inet_diag.c: In function =E2=80=98inet_csk_diag_fill=E2=80=99:
net/ipv4/inet_diag.c:119: warning: cast from pointer to integer of diff=
erent size
net/ipv4/inet_diag.c:120: error: invalid operands to binary >>
make[1]: *** [net/ipv4/inet_diag.o] Error 1



