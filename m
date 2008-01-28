From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 1/5] spidernet: add missing initialization
Date: Mon, 28 Jan 2008 14:40:48 +0100
Message-ID: <200801281440.48602.jens@de.ibm.com>
References: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp> <200801231453.42736.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:64891 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbYA1Nky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 08:40:54 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0SDer6r168078
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 13:40:53 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0SDeqZC4980932
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 13:40:52 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0SDenCU008726
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 13:40:49 GMT
In-Reply-To: <200801231453.42736.jens@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff,

this series of 5 patches by Ishizaki-san runs fine on the blade, I test=
ed it
for a few days. Besides it fixes a nasty bug in spidernet RX descriptor=
 handling.

Can you please consider it for 2.6.25 ?

Thanks !

Jens

On Wednesday 23 January 2008, Jens Osterkamp wrote:
> On Friday 11 January 2008, Ishizaki Kou wrote:
> > This patch fixes initialization of "aneg_count" and "medium" fields=
 in
> > spider_net_card to make spidernet driver correctly sets "link statu=
s".
> >=20
> > Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
>=20
> Acked-by: Jens Osterkamp <jens@de.ibm.com>
>=20
> > ---
> >=20
> > Index: linux-powerpc-git/drivers/net/spider_net.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-powerpc-git.orig/drivers/net/spider_net.c
> > +++ linux-powerpc-git/drivers/net/spider_net.c
> > @@ -1399,6 +1399,8 @@ spider_net_link_reset(struct net_device=20
> >  	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
> >=20
> >  	/* reset phy and setup aneg */
> > +	card->aneg_count =3D 0;
> > +	card->medium =3D BCM54XX_COPPER;
> >  	spider_net_setup_aneg(card);
> >  	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
> >=20
> > @@ -1982,6 +1984,8 @@ spider_net_open(struct net_device *netde
> >  		goto init_firmware_failed;
> >=20
> >  	/* start probing with copper */
> > +	card->aneg_count =3D 0;
> > +	card->medium =3D BCM54XX_COPPER;
> >  	spider_net_setup_aneg(card);
> >  	if (card->phy.def->phy_id)
> >  		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
> > _______________________________________________
> > cbe-oss-dev mailing list
> > cbe-oss-dev@ozlabs.org
> > https://ozlabs.org/mailman/listinfo/cbe-oss-dev
> >



--=20

Gru=DF,

Jens

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
