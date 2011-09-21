From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning
 to debug message
Date: Wed, 21 Sep 2011 13:25:55 +0200
Message-ID: <20110921112555.GE1966@pengutronix.de>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+SfteS7bOf3dGlBC"
Cc: "David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	Lothar =?iso-8859-15?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47534 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab1IULZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:25:58 -0400
Content-Disposition: inline
In-Reply-To: <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+SfteS7bOf3dGlBC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Shawn,

On Wed, Sep 21, 2011 at 07:10:30PM +0800, Shawn Guo wrote:
> FEC can work without a phy reset on some platforms, which means not
> very platform necessarily have a phy-reset gpio encoded in device tree.
> So it makes more sense to have the phy-reset-gpio request failure as
> a debug message rather than a warning.

Or remove it entirely?

>=20
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> ---
>  drivers/net/ethernet/freescale/fec.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/=
freescale/fec.c
> index 158b82e..a057abf 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1422,7 +1422,7 @@ static int __devinit fec_reset_phy(struct platform_=
device *pdev)
>  	phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
>  	err =3D gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
>  	if (err) {
> -		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
> +		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
>  		return err;

I also wanted to suggested to drop returning the error code, since it is
not an error anymore, strictly speaking. Then I noticed that the caller
does not check the error code. So, this could be added or turn the
function to void?

>  	}
>  	msleep(1);
> --=20
> 1.7.4.1
>=20
>=20
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--+SfteS7bOf3dGlBC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk55ycMACgkQD27XaX1/VRtQNACgr5jlXSbQkvgu/QBlYGZEZC36
tCMAoKmIGD2T3Fq1Yki8Vb6VXqDBiWJF
=6Jdi
-----END PGP SIGNATURE-----

--+SfteS7bOf3dGlBC--
