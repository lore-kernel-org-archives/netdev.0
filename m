From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 3/7] mlx4_en: Incoming traffic alignment optimizations
Date: Tue, 18 Oct 2011 10:40:07 +0200
Message-ID: <1318927207.2657.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E9C8D53.5040006@mellanox.co.il>
	 <1318902799.2571.26.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB7E@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40147 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab1JRIjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:39:49 -0400
Received: by eye27 with SMTP id 27so310304eye.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 01:39:48 -0700 (PDT)
In-Reply-To: <953B660C027164448AE903364AC447D2235EEB7E@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 07:43 +0000, Yevgeny Petrilin a =C3=A9c=
rit :
> >=20
> > > @@ -91,7 +91,7 @@
> > >  /* Receive fragment sizes; we use at most 4 fragments (for 9600 =
byte MTU
> > >   * and 4K allocations) */
> > >  enum {
> > > -	FRAG_SZ0 =3D 512 - NET_IP_ALIGN,
> > > +	FRAG_SZ0 =3D 2048,
> > >  	FRAG_SZ1 =3D 1024,
> > >  	FRAG_SZ2 =3D 4096,
> > >  	FRAG_SZ3 =3D MLX4_EN_ALLOC_SIZE
> >=20
> > Is the 512 -> 2048 change really wanted ? Its not mentioned in chan=
gelog and is confusing.
> >=20
> > This means mlx4 lost the ability to use a small frag (512 bytes) to=
 store small frames.
> >=20
> The change is wanted as an optimization for our HW.
> We do get better numbers with this change, even with small packets.
> You are correct, I should have mentioned it in the changelog.

Oh my...

Of course you are aware that the 'truesize' stuff around means that
using big frag size will probably lower your performance number, unless
you allow protocol stacks to use more ram ?

Only possible drawback using 512 bytes instead of 2048 is the cache-lin=
e
bounce on the page->_count field. So I would say your change hides a
performance issue of your driver.

Maybe you should make sure you dont touch it too often [ You should use
a single add per allocated PAGE, not 2 (for 2048-bytes frags) or 8 (for
512-bytes frags) ]
