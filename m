From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 03/16] net: reduce and unify printk level in
	netdev_fix_features()
Date: Sun, 23 Jan 2011 00:40:51 +0100
Message-ID: <20110122234051.GA30734@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl> <1295737942.25868.114.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56158 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab1AVXkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 18:40:52 -0500
Content-Disposition: inline
In-Reply-To: <1295737942.25868.114.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 22, 2011 at 03:12:22PM -0800, Joe Perches wrote:
> On Sat, 2011-01-22 at 23:14 +0100, Micha=B3 Miros=B3aw wrote:
> > Reduce printk() levels to KERN_INFO in netdev_fix_features() as thi=
s will
> > be used by ethtool and might spam dmesg unnecessarily.
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 01d7ce2..168588f 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5127,58 +5127,52 @@ static void rollback_registered(struct net_=
device *dev)
> >  	rollback_registered_many(&single);
> >  }
> > =20
> > -u32 netdev_fix_features(u32 features, const char *name)
> > +u32 netdev_fix_features(struct net_device *dev, u32 features)
>=20
> Perhaps this would be simpler as:
> void netdev_fix_features(struct net_device *dev)

Code introduced in next patches in the series pass modified features
values here.

> >  {
> >  	/* Fix illegal checksum combinations */
> >  	if ((features & NETIF_F_HW_CSUM) &&
> >  	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
>=20
> 	if (dev->features & etc...) {
> 		dev->features &=3D etc...)
>=20
> > +		netdev_info(dev,0
> > +			"mixed HW and IP checksum settings.\n");
>=20
> Fits nicely on a single line:
>=20
> 		netdev_info(dev, "mixed HW and IP checksum settings\n");=20

=46ixed.

> >  		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> >  	}
> > =20
> >  	if ((features & NETIF_F_NO_CSUM) &&
> >  	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSU=
M))) {
> > -		if (name)
> > -			printk(KERN_NOTICE "%s: mixed no checksumming and other setting=
s.\n",
> > -				name);
> > +		netdev_info(dev,
> > +			"mixed no checksumming and other settings.\n");
>=20
> Here too, etc...
> 		netdev_info(dev, "mixed no checksumming and other settings\n");

This one is actually exactly 80 chars then, fixed this and another one.

Long time ago there were editors which added spurious empty line when l=
ine
length matched terminal's width. Hope they're all gone by now. ;)

Best Regards,
Micha=B3 Miros=B3aw
