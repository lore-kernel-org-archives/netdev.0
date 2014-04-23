From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] gianfar: Check if phydev present on ethtool -A
Date: Wed, 23 Apr 2014 17:21:27 +0100
Message-ID: <1398270087.7767.157.camel@deadeye.wl.decadent.org.uk>
References: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6JL4qHd/Mf0ucAc6u94m"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57353 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbaDWQVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:21:38 -0400
In-Reply-To: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6JL4qHd/Mf0ucAc6u94m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-23 at 16:38 +0300, Claudiu Manoil wrote:
> This fixes a seg fault on 'ethtool -A' entry if the
> interface is down.  Obviously we need to have the
> phy device initialized / "connected" (see of_phy_connect())
> to be able to advertise pause frame capabilities.

Why is the phydev detached while the interface is down?!

> Fixes: 23402bddf9e56eecb27bbd1e5467b3b79b3dbe58
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar_ethtool.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/n=
et/ethernet/freescale/gianfar_ethtool.c
> index 891dbee..76d7070 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -533,6 +533,9 @@ static int gfar_spauseparam(struct net_device *dev,
>  	struct gfar __iomem *regs =3D priv->gfargrp[0].regs;
>  	u32 oldadv, newadv;
> =20
> +	if (!phydev)
> +		return -ENODEV;
> +
>  	if (!(phydev->supported & SUPPORTED_Pause) ||
>  	    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
>  	     (epause->rx_pause !=3D epause->tx_pause)))

I think you can instead remove the following check, as pause support is
a property of the MAC not the PHY.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-6JL4qHd/Mf0ucAc6u94m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1foh+e/yOyVhhEJAQol/g//djpMn50YGCk16pWr4qkxk9O3BODzvFNC
BLceWDHBSHTvwCjRjX/O9VbsWPxZ6F4TwCcFU/GzlP43B4w8Yfw1Jd631chQ9ALD
8oTSqo8CY0tmqIRt/XeRGLTlhadODYkEr5eupdl19qtHSPFAUh/fTWSL+mVKRGBU
/GaPkMPC9Xt1H2FEykPrQoDR+bJzUUkWV9z6lxTa4SPzhaXj3XHBaPiAT0Pj5S8N
OJdrIAxdf8f4YiQUrwT9NEfmfMrsGRe+AbEppcVPogFHLOdV8lfHMyeB9b2al7UJ
gdELvbuNXKG6bPmFG2LJ1k84QtvHr2xvG1bohHZRiOgKTu2zwJl1K6SAcNUfvMzs
tHp9B3Ly4lqkTWCQsJ9y2MBJ6EW8lsWaLArTpb968+kbFqeI37+hHMTr//d+tjpy
Rct8NXtwBltbSBXDEYCObSAChFj0rFch7sKvFf/d8gih4Foe8cgl1th380YNliMj
j3ttFhjaApNStgZqLORd6CdpzEJ3wcn8eD+mXKEb059EFedWuC49r20vLRVtkY34
Gp2D76Pq7kMizaeifEWqKEQEfE9qavS27vNwF1jT+xaEtugeBE1dlJLvBdLH6wrx
t0URclGgVF5Gv6P5X50K5HRKQ6d4t4nCrC85axC8vtGAw7pB90jFFbm0aBV0g10O
PljiYqdIAX8=
=aVIH
-----END PGP SIGNATURE-----

--=-6JL4qHd/Mf0ucAc6u94m--
