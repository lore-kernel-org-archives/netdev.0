From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC
 addresses.
Date: Tue, 22 Mar 2011 08:49:41 +0100
Message-ID: <19848.21653.877174.416543@ipc1.ka-ro>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
	<a6ba75577552abe8d5045434030c276d5f45779a.1300724245.git.LW@KARO-electronics.de>
	<20110322074336.GE28098@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:63545 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab1CVHts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 03:49:48 -0400
In-Reply-To: <20110322074336.GE28098@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Shawn Guo writes:
> On Mon, Mar 21, 2011 at 05:37:36PM +0100, Lothar Wa=C3=9Fmann wrote:
> > The FEC driver currently uses the MAC address assigned to the first
> > interface incremented by one for the second interface.
> >=20
> > Change this to be able to configure distinct MAC addresses via
> > platform_data.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/fec.c |    9 ++-------
> >  1 files changed, 2 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index 3666524..9d89e99 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -750,13 +750,12 @@ static void __inline__ fec_get_mac(struct net=
_device *ndev)
> >  	/*
> >  	 * 2) from flash or fuse (via platform data)
> >  	 */
> > +	if (pdata)
> > +		memcpy(iap, pdata->mac, ETH_ALEN);
> >  	if (!is_valid_ether_addr(iap)) {
> >  #ifdef CONFIG_M5272
> >  		if (FEC_FLASHMAC)
> >  			iap =3D (unsigned char *)FEC_FLASHMAC;
> > -#else
> > -		if (pdata)
> > -			memcpy(iap, pdata->mac, ETH_ALEN);
> >  #endif
> >  	}
> > =20
> > @@ -772,10 +771,6 @@ static void __inline__ fec_get_mac(struct net_=
device *ndev)
> >  	}
> > =20
> >  	memcpy(ndev->dev_addr, iap, ETH_ALEN);
> > -
> > -	/* Adjust MAC if using macaddr */
> > -	if (iap =3D=3D macaddr)
> > -		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev-=
>id;
> >  }
> > =20
> >  /* ---------------------------------------------------------------=
---------- */
> > --=20
> > 1.5.6.5
> >=20
> >=20
> NAK.
>=20
> The 'mac' was designed as an optional member of fec
> platform_data, as some platforms may not be able to provide it. This
> patch breaks the order of getting mac, and will not work on the
> platform that does not provide an valid mac with either platform_data
> or controller mac registers, even there may be one in the kernel
> command line.
>=20
> The existing code takes mac address from kernel command line as the
> first choice, and only falls through on other options when it's
> invalid/unavailable.  So an valid mac from  kernel command line will
> always get fec work anyway.
>=20
The problem is that you can only assign one mac address on the kernel
cmdline and the second one will be derived from the first one.
And even if the MAC address is set via platform_data it will not be
used for the second interface.

IMO an ethernet driver has no business in inventing arbitrary MAC
addresses. Either the MAC address is supplied by the boot loader or
the platform code or it has to be assigned from userspace via
ifconfig.



Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
