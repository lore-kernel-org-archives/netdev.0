From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: ti_hecc: add missing prepare and unprepare of the
 clock
Date: Wed, 18 Jan 2017 11:01:16 +0100
Message-ID: <5ccf750a-e468-5c4b-eb26-1e248b712a93@pengutronix.de>
References: <1484732616-4461-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ScOi2mbjuVueJkj2CcgoN6N3Pxtn2DMQ1"
Cc: netdev@vger.kernel.org, wg@grandegger.com
To: yegorslists@googlemail.com, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43959 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752214AbdARKB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 05:01:28 -0500
In-Reply-To: <1484732616-4461-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ScOi2mbjuVueJkj2CcgoN6N3Pxtn2DMQ1
Content-Type: multipart/mixed; boundary="bnmQaAFtp22fCDuo23ucKF9gXa97rtiCj";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: yegorslists@googlemail.com, linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org, wg@grandegger.com
Message-ID: <5ccf750a-e468-5c4b-eb26-1e248b712a93@pengutronix.de>
Subject: Re: [PATCH] can: ti_hecc: add missing prepare and unprepare of the
 clock
References: <1484732616-4461-1-git-send-email-yegorslists@googlemail.com>
In-Reply-To: <1484732616-4461-1-git-send-email-yegorslists@googlemail.com>

--bnmQaAFtp22fCDuo23ucKF9gXa97rtiCj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/18/2017 10:43 AM, yegorslists@googlemail.com wrote:
> From: Yegor Yefremov <yegorslists@googlemail.com>
>=20
> In order to make the driver work with the common clock framework, this
> patch converts the clk_enable()/clk_disable() to
> clk_prepare_enable()/clk_disable_unprepare().
>=20

Can you add the missing error checking for the prepare_enable call?

Marc

> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> ---
>  drivers/net/can/ti_hecc.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index 680d1ff..0448cb5 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -948,7 +948,8 @@ static int ti_hecc_probe(struct platform_device *pd=
ev)
>  	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>  		HECC_DEF_NAPI_WEIGHT);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);
> +
>  	err =3D register_candev(ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "register_candev() failed\n");
> @@ -981,7 +982,7 @@ static int ti_hecc_remove(struct platform_device *p=
dev)
>  	struct ti_hecc_priv *priv =3D netdev_priv(ndev);
> =20
>  	unregister_candev(ndev);
> -	clk_disable(priv->clk);
> +	clk_disable_unprepare(priv->clk);
>  	clk_put(priv->clk);
>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	iounmap(priv->base);
> @@ -1006,7 +1007,7 @@ static int ti_hecc_suspend(struct platform_device=
 *pdev, pm_message_t state)
>  	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
> -	clk_disable(priv->clk);
> +	clk_disable_unprepare(priv->clk);
> =20
>  	return 0;
>  }
> @@ -1016,7 +1017,7 @@ static int ti_hecc_resume(struct platform_device =
*pdev)
>  	struct net_device *dev =3D platform_get_drvdata(pdev);
>  	struct ti_hecc_priv *priv =3D netdev_priv(dev);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);
> =20
>  	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bnmQaAFtp22fCDuo23ucKF9gXa97rtiCj--

--ScOi2mbjuVueJkj2CcgoN6N3Pxtn2DMQ1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlh/PO4ACgkQPTuqJayp
JWp0bQgAm7PlLoRlhHqVd2ouz74Tfj8qgPMyny7H4NsP7L3xrSPhiljer+cl8lcV
1Xib3y6ThLC/asPuKb2N6+EfRnuzAsua1wUUI78pnYnH/81OgLVAYcVYfnb0Q73J
IVWr0WDvhgjkJ9hrq8+jL3iE7r5QP6/Y5qJZEWCRyWG3SiAbHNa3O1n1rWuClMXZ
XBG9qwh82VjVsSnKFOn/r/behu/bV+hQBAENsI54c+k+kRZedVfvIGqomxBG1zfw
6yhnVTEU6prpleir9dws9hLqn7t8yuWWmUQvsn1Z5xRSnAASPXYYcYd6Tj45O+cT
+m3LeWVqcm4hGdr9uyG/kJyxYSwAkw==
=VjdJ
-----END PGP SIGNATURE-----

--ScOi2mbjuVueJkj2CcgoN6N3Pxtn2DMQ1--
