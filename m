From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 08:48:57 +0100
Message-ID: <1289980137.2732.280.camel@edumazet-laptop>
References: <20101110.102129.112602843.davem@davemloft.net>
	 <1289414024.2469.20.camel@edumazet-laptop>
	 <20101110.103807.39173013.davem@davemloft.net>
	 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
	 <1289915053.5372.183.camel@edumazet-laptop>
	 <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
	 <1289925055.5372.484.camel@edumazet-laptop>
	 <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mjt@tls.msk.ru, davem@davemloft.net, drosenberg@vsecurity.com,
	hagen@jauu.net, xiaosuo@gmail.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60968 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759833Ab0KQHtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 02:49:05 -0500
Received: by wyb28 with SMTP id 28so1669012wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 23:49:04 -0800 (PST)
In-Reply-To: <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 10:19 +0900, Tetsuo Handa a =C3=A9c=
rit :
> Eric Dumazet wrote:
> > I dont understand the problem...
> > Once translated, you have to test the translated code, not the orig=
inal
> > one ;)
>=20
> I moved the test to after translation.
>=20
> > why u16 ?=20
> >=20
> > You store translated instructions, so u8 is OK
>=20
> I chose u16 because type of filter->code is __u16.
> But I changed to use u8 as you suggested that translated code fits in=
 u8.
>=20
> > Also fix the indentation at the end of sk_chk_filter()
> >=20
> > You have 3 extra tabulations :
>=20
> Fixed.
>=20
> Hagen Paul Pfeifer wrote:
> > Maybe I don't get it, but you increment the opcode by one, but you =
never
> > increment the opcode in sk_run_filter() - do I miss something? Did =
you test
> > the your patch (a trivial tcpdump rule should be sufficient)?
>=20
> I added a comment line.
>=20
> Changli Gao wrote:
> > > +               struct sock_filter *ftest =3D &filter[pc];
> >=20
> > Why move the define here?
>=20
> To suppress compiler's warning about mixed declaration.
>=20
> > > +               u16 code =3D ftest->code;
> > >
> > > +               if (code >=3D ARRAY_SIZE(codes))
> > > +                       return 0;
> >=20
> > return -EINVAL;
>=20
> Fixed in v2. Thanks.
>=20
> > But how about this:
> >=20
> > enum {
> >         BPF_S_RET_K =3D 1,
>=20
> If BPF_S_* are only for kernel internal use, I think we don't need to=
 translate
> from the beginning because only net/core/filter.c uses BPF_S_*.
>=20
> BPF_S_* are exposed to userspace via /usr/include/linux/filter.h sinc=
e 2.6.36.
> Is it no problem to change?

No problem, and Changli posted patch to move them to net/core/filter.c
anyway.

>=20
> Filesize change (x86_32) by this patch:
>   gcc 3.3.5: 7184 -> 5060
>   gcc 4.4.3: 7972 -> 5588
> ----------------------------------------
> From b8777ab64bc31dbbe499eb62c2ffd29add7e79c8 Mon Sep 17 00:00:00 200=
1
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Nov 2010 09:46:33 +0900
> Subject: [PATCH v3] filter: Optimize instruction revalidation code.
>=20
> Since repeating u16 value to u8 value conversion using switch() claus=
e's
> case statement is wasteful, this patch introduces u16 to u8 mapping t=
able
> and removes most of case statements. As a result, the size of net/cor=
e/filter.o
> is reduced by about 29% on x86.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/core/filter.c |  231 +++++++++++++++++--------------------------=
----------
>  1 files changed, 72 insertions(+), 159 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Please repost it when Changli patch is accepted by David=20
(if accepted :)), to get rid of the "+ 1"




