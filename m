From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 10:34:30 +0200
Message-ID: <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E9C8D8B.90606@mellanox.co.il>
	 <1318902525.2571.24.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40718 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab1JRIeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:34:11 -0400
Received: by mail-ey0-f174.google.com with SMTP id 27so305717eye.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 01:34:10 -0700 (PDT)
In-Reply-To: <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 07:36 +0000, Yevgeny Petrilin a =C3=A9c=
rit :
> > >  	rss_context->flags =3D rss_mask;
> > > +	rss_context->hash_fn =3D 1;
> > > +	for (i =3D 0; i < 10; i++)
> > > +		rss_context->rss_key[i] =3D random32();
> > >
> >=20
> > Thats bit of a problem : Two NICS will have different seeds, and th=
us provide different rxhash for a given flow. A bonding of two NICS wil=
l
> > not be able to provide a consistent rxhash.
> >=20
> > drivers/net/ethernet/intel/igb/igb_main.c uses a static table to av=
oid this problem.
> >=20
>=20
> Hello Eric, thanks for your review.
>=20
> I agree that in this case two ports will have different seeds.
> But even if we use static values for the key, what about bonding of 2=
 NICs from different vendors?
> How can we ensure we get same rxhash value for all NICs?
>=20
> There are also other drivers that use random values as well, for exam=
ple:
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>=20

What is the gain using random values ?

Usually, we tend to have same hardware in a single machine, or we use
active-backup bonding mode, and an active slave flip can change rxhash
values with litle effect, since this happens not often.

I really prefer not random values, because it allows to have replayable
configurations : For a given tcp flow, the same rxhash value is given
and same cpu target in RPS. Its way easier to tune your machine for som=
e
workloads.
