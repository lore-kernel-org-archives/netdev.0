From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] phy: unmask link partner capabilities
Date: Mon, 24 Feb 2014 23:36:33 +0000
Message-ID: <1393284993.6823.107.camel@deadeye.wl.decadent.org.uk>
References: <1393257178-25052-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ouS+gMbsIF5pdrCWKH2X"
Cc: netdev@vger.kernel.org, madalin.bucur@freescale.com,
	shaohui.xie@freescale.com, shruti@freescale.com
To: cristian.bercaru@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36380 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752555AbaBXXgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:36:41 -0500
In-Reply-To: <1393257178-25052-1-git-send-email-cristian.bercaru@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ouS+gMbsIF5pdrCWKH2X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 17:52 +0200, cristian.bercaru@freescale.com wrote:
> From: Cristian Bercaru <cristian.bercaru@freescale.com>
>=20
> Masking the link partner's capabilities with local capabilities can be
> misleading in autonegotiation scenarios such as PAUSE frame
> autonegotiation.
> This patch calculates the join between the local capabilities and the
> link parner capabilities, when it calculates the speed and duplex
> settings, but does not mask any of the link partner capabilities
> when it calculates PAUSE frame settings.
>=20
> Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
> ---
> v2 caches (lpa & adv) and (lpa & adv << 2) in intermediate variables.
>=20
>  drivers/net/phy/phy_device.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index a70b604..4b021a3 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -933,6 +933,8 @@ int genphy_read_status(struct phy_device *phydev)
>  	int err;
>  	int lpa;
>  	int lpagb =3D 0;
> +	int common_adv;
> +	int common_adv_gb;

I think common_adv_gb needs to be initialised to 0...

> =20
>  	/* Update the link, but return if there was an error */
>  	err =3D genphy_update_link(phydev);
> @@ -954,7 +956,7 @@ int genphy_read_status(struct phy_device *phydev)
> =20
>  			phydev->lp_advertising =3D
>  				mii_stat1000_to_ethtool_lpa_t(lpagb);
> -			lpagb &=3D adv << 2;
> +			common_adv_gb =3D lpagb & adv << 2;
>  		}
[...]

...as this assignment is conditional.

Ben.

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-ouS+gMbsIF5pdrCWKH2X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwvXgee/yOyVhhEJAQrzLBAAqU+kOm32rI3xcaamCgK5bITLGb1OC8yi
POMEcr8CXOfN5awajSE+finaOWAv1W+BCXond9k7tMLSLR8B3dZcatyydS8CS1g2
xSS3njLbzjFwRa0Rwd0F3XEfuL4MCYUF3YqwGeKS5viPR3jRQ6T2Xg6VsQeE9bFP
Dz7SxkcoZs46ri3DAgiNo8hXn7gNi0yKUAzKE8b8G2stOiRAhTEcf5PKZ/1vlbZl
NawXG4PGCT5xYWE7OjEe/LnVPwv5/lHK/sVGZbmbCAbjs0u9lp2vYNIj7KP2cDro
7dxJ8DGTl7uWFevh9zkgTrC1yCcupCJLVbDFIFX+uXavsBTMsIAyr56jy1I3U2qm
xqnHKq9ACl7TYQqd25GpxQFUqK9zn1jBB9zAimvqZroxkfhNbfHdkP2PTE7zOF0B
RIfR8tL2KWvhskMgsKQUIlMewRwqD8/zu8hP4NwnMMDWpenINiQaEPBDDjAfOl/g
a9spPH+d3mMux2p5+rdMcvuLv/sZ6cu8kIUCQrChdol0dlErFsH6btj2+nK0XQnC
lTEbwDeuqpCdHCck6w9gcxCLmRDPDgF5sainCMdM1/Pj4WnD5PZSNsNbzXd6gyEs
URDcmTb0pt0bN8HiAbMc06F6rOcrUuLHe6Ia6PINGn667cuEeoKzuIU/iihAZdP/
8Sh4ZrwaTuE=
=PTIn
-----END PGP SIGNATURE-----

--=-ouS+gMbsIF5pdrCWKH2X--
