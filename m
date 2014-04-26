From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] gianfar: Check if phydev present on ethtool -A
Date: Sun, 27 Apr 2014 00:18:38 +0100
Message-ID: <1398554318.16049.30.camel@deadeye.wl.decadent.org.uk>
References: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
	 <1398270087.7767.157.camel@deadeye.wl.decadent.org.uk>
	 <5358C582.8090808@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Cq1sLpu7Nte1GIEl3y/N"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39546 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716AbaDZXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 19:18:48 -0400
In-Reply-To: <5358C582.8090808@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Cq1sLpu7Nte1GIEl3y/N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-24 at 11:04 +0300, Claudiu Manoil wrote:
> On 4/23/2014 7:21 PM, Ben Hutchings wrote:
> > On Wed, 2014-04-23 at 16:38 +0300, Claudiu Manoil wrote:
> >> This fixes a seg fault on 'ethtool -A' entry if the
> >> interface is down.  Obviously we need to have the
> >> phy device initialized / "connected" (see of_phy_connect())
> >> to be able to advertise pause frame capabilities.
> >
> > Why is the phydev detached while the interface is down?!
>=20
> Hi Ben,
> Gianfar uses the phylib framework, and it's been always calling
> phy_connect() during net_device open and the complementary
> phy_disconnect() during net_device close (ndo_stop).
> I think this is the general recommendation on how the net_device
> driver should integrate with the phylib: i.e. "phy_disconnect - disable
> interrupts, stop state machine, and detach a PHY device" while the
> interface is down.  Many other net_device drivers call phy_disconnect()
> on device close.

OK, I never actually used phylib so this is just surprising to me.

[...]
> >> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> >> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> >> @@ -533,6 +533,9 @@ static int gfar_spauseparam(struct net_device *dev=
,
> >>   	struct gfar __iomem *regs =3D priv->gfargrp[0].regs;
> >>   	u32 oldadv, newadv;
> >>
> >> +	if (!phydev)
> >> +		return -ENODEV;
> >> +
> >>   	if (!(phydev->supported & SUPPORTED_Pause) ||
> >>   	    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
> >>   	     (epause->rx_pause !=3D epause->tx_pause)))
> >
> > I think you can instead remove the following check, as pause support is
> > a property of the MAC not the PHY.
> >
>=20
> I wish it was as easy as that.  But my understanding is that link
> partners need to negotiate their pause frame capabilities at PHY
> level.  If a phy is not able to signal (advertise) to the link
> partner that the MAC supports pause frame handling then the flow
> control btw link partners won't work properly (at least this is my
> understanding from looking at other implementations, like tg3).

This is true but I don't see any reason why an MDIO-manageable
autonegotiating PHY would limit which pause flags you can set.

> If it weren't so then the phydev's pause support and advertising
> flags and mii_advertise_flowctrl()/ mii_resolve_flowctrl_fdx()
> would be useless, right?

The pause flags in phy_device::supported do seem to be useless.  The
advertising flags are not as they should be changeable through ethtool.

Ben.

--=20
Ben Hutchings
Power corrupts.  Absolute power is kind of neat.
                           - John Lehman, Secretary of the US Navy 1981-198=
7

--=-Cq1sLpu7Nte1GIEl3y/N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1w+zue/yOyVhhEJAQrwOg/9GdFZvCzEY76/Y3hLPU8tNB4HpOiRbHUm
5SdMTFDqUWpw0SdHeqF+KfTzbqJGcF2IqFyX6kHZRfCr/4eD1L4EamQfpsZmPTkR
132/baT+uy7ISVgqgN3UzTHe95XyegOvT1oo1d/1/XaDnxs/EZorSd4DT6KwTbOy
7b8t4MyaRGoapy5w5pJ7tixCu2Zpjozu7LADRbkKYhRUPntufxVrq+0+bVN76Qmb
ha/ZxxzDmVT9DCHriXD01FrYE/4fswse5FiDkIDpJwvOXdIVWnNkdG05V70QtaSa
Z5xXhKBWs1I2OlwWJ/YShhDnCm3/64iLfXyxL6Syz/pflSoYmTY+xGP4eShFYY2v
TfXHU9ExqMcFTYW8TRvsJcdeD5ToCzsv+NcGab5i/3vOljQYMJ4TIsIyBYle+z65
INCWS5VDQvA8gELrONcHAciovzq+1o8W4giJ7YpA+X1GwDJNWgITIdWWkMk15Cud
QczVMGU52UMgUvM5V1FQQNFe+qehu1RPc7BpmZecZA2rMhKQRiEAEe58WgCagJKr
IfmJTkMFIPEqdTaiqc72Arqge8RoRbjKZ1QyEufXuvf7Y2W/NyykEcrignqCVqHl
8NL47uKmBSxpdajd0Y3egqT4WxNoVLYTbrDXwAM9GmoPGGtGCi695Qo0nXrSj1Ik
2PyVBEvN2fY=
=Lk2N
-----END PGP SIGNATURE-----

--=-Cq1sLpu7Nte1GIEl3y/N--
