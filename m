From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] net: phy: smsc: energy saving does not work without
 interrupts
Date: Wed, 21 Mar 2012 15:28:34 +0100
Message-ID: <20120321142834.GE3244@pengutronix.de>
References: <1332331707-2350-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zjcmjzIkjQU2rmur"
Cc: David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39546 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030924Ab2CUO2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 10:28:36 -0400
Content-Disposition: inline
In-Reply-To: <1332331707-2350-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zjcmjzIkjQU2rmur
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 21, 2012 at 01:08:27PM +0100, Wolfram Sang wrote:
> We discovered link detection failures using this PHY with the Freescale F=
EC
> which does not have interrupt support yet. Disabling the energy saving mo=
de
> makes all go well. It should be possible to make this mode work without
> interrupts by adding some code dealing with the ENERGYON flag. Since addi=
ng
> interrupt support to the FEC driver seems to be the better solution for u=
s, I
> want to at least make sure the PHY works reliably always. So, disable ene=
rgy
> saving if there is no interrupt support.
>=20
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>=20
> Giuseppe: Did you test with interrupts? Do you agree?
>=20
> If Giuseppe is fine with the patch, this should probably be tagged for st=
able.
>=20
>  drivers/net/phy/smsc.c |   22 ++++++++++++----------
>  1 files changed, 12 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index fc3e7e9..6dcf57a 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -43,16 +43,18 @@ static int smsc_phy_ack_interrupt(struct phy_device *=
phydev)
> =20
>  static int smsc_phy_config_init(struct phy_device *phydev)
>  {
> -	int rc =3D phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> -	if (rc < 0)
> -		return rc;
> -
> -	/* Enable energy detect mode for this SMSC Transceivers */
> -	rc =3D phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> -		       rc | MII_LAN83C185_EDPWRDOWN);
> -	if (rc < 0)
> -		return rc;
> -
> +	/* TODO: add code to make EDPWRDOWN work without interrupts */
> +	if (PHY_INTERRUPT_ENABLED =3D=3D phydev->interrupts) {

Gnarg, that should probably be:

+	if (phydev->irq !=3D PHY_POLL) ...

since interrupts maybe not enabled at this point? Will resend, but will
wait some more for comments.

> +		int rc =3D phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> +		if (rc < 0)
> +			return rc;
> +
> +		/* Enable energy detect mode for this SMSC Transceivers */
> +		rc =3D phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> +			       rc | MII_LAN83C185_EDPWRDOWN);
> +		if (rc < 0)
> +			return rc;
> +	}
>  	return smsc_phy_ack_interrupt (phydev);
>  }
> =20
> --=20
> 1.7.9.1
>=20

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--zjcmjzIkjQU2rmur
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk9p5ZIACgkQD27XaX1/VRvzeACfct6m45uCIzq6JEXaGz0rcizF
CjQAnA4oUfJHGQCAzXaBpZZIBw11DBOU
=U/cq
-----END PGP SIGNATURE-----

--zjcmjzIkjQU2rmur--
