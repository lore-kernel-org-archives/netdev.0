From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: ti_hecc: add missing prepare and unprepare of the
 clock
Date: Wed, 18 Jan 2017 13:03:55 +0100
Message-ID: <0fa9648b-99e7-2618-740c-ea31c1ef0b20@pengutronix.de>
References: <1484735757-21172-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="RqdhdAcoGDu68i7W85MHGGWc10Lk9lg41"
Cc: netdev@vger.kernel.org, wg@grandegger.com
To: yegorslists@googlemail.com, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1484735757-21172-1-git-send-email-yegorslists@googlemail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RqdhdAcoGDu68i7W85MHGGWc10Lk9lg41
Content-Type: multipart/mixed; boundary="tI1SfBVP4xFdMJ4FF6ClCJ6NwndotUUkU";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: yegorslists@googlemail.com, linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org, wg@grandegger.com
Message-ID: <0fa9648b-99e7-2618-740c-ea31c1ef0b20@pengutronix.de>
Subject: Re: [PATCH v2] can: ti_hecc: add missing prepare and unprepare of the
 clock
References: <1484735757-21172-1-git-send-email-yegorslists@googlemail.com>
In-Reply-To: <1484735757-21172-1-git-send-email-yegorslists@googlemail.com>

--tI1SfBVP4xFdMJ4FF6ClCJ6NwndotUUkU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/18/2017 11:35 AM, yegorslists@googlemail.com wrote:
> From: Yegor Yefremov <yegorslists@googlemail.com>
>=20
> In order to make the driver work with the common clock framework, this
> patch converts the clk_enable()/clk_disable() to
> clk_prepare_enable()/clk_disable_unprepare().
>=20
> Also add error checking for clk_prepare_enable().
>=20
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> ---
> Changes v1 -> v2:
> 	- add error checking for clk_prepare_enable (Marc Kleine-Budde)
>=20
>  drivers/net/can/ti_hecc.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index 680d1ff..8771531 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -948,7 +948,12 @@ static int ti_hecc_probe(struct platform_device *p=
dev)
>  	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>  		HECC_DEF_NAPI_WEIGHT);
> =20
> -	clk_enable(priv->clk);
> +	err =3D clk_prepare_enable(priv->clk);
> +	if (err) {
> +		dev_err(&pdev->dev, "clk_prepare_enable() failed\n");
> +		goto probe_exit_clk;
> +	}
> +
>  	err =3D register_candev(ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "register_candev() failed\n");
> @@ -981,7 +986,7 @@ static int ti_hecc_remove(struct platform_device *p=
dev)
>  	struct ti_hecc_priv *priv =3D netdev_priv(ndev);
> =20
>  	unregister_candev(ndev);
> -	clk_disable(priv->clk);
> +	clk_disable_unprepare(priv->clk);
>  	clk_put(priv->clk);
>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	iounmap(priv->base);
> @@ -1006,7 +1011,7 @@ static int ti_hecc_suspend(struct platform_device=
 *pdev, pm_message_t state)
>  	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
> -	clk_disable(priv->clk);
> +	clk_disable_unprepare(priv->clk);
> =20
>  	return 0;
>  }
> @@ -1016,7 +1021,7 @@ static int ti_hecc_resume(struct platform_device =
*pdev)
>  	struct net_device *dev =3D platform_get_drvdata(pdev);
>  	struct ti_hecc_priv *priv =3D netdev_priv(dev);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);

I've added error checking here, too.

> =20
>  	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>=20

Applied to can.

Tnx,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--tI1SfBVP4xFdMJ4FF6ClCJ6NwndotUUkU--

--RqdhdAcoGDu68i7W85MHGGWc10Lk9lg41
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlh/Wa0ACgkQPTuqJayp
JWq7tggAqBAjpqqHjpv+eh2oV4jw5JPNzwWGSXHukmtG9nFCHBENMNuL13HS1sFo
vReIyfdQfTrUdQERXG4rH7RRVFFYBps9cmir7BF5GLf6RP0wk57KZ1HsDiD6/K29
6jVIxpWagPUmrtcv417Pb9FdRxT0+ukMjbs099pk4/Ks1ljyoYVtOvzvHfQ4T/LM
QOJ1xGVsYImUDZGxSGKoRmugLkNw8dL+ds6Be9wtkx4BxQGggmGg8Dpz80X8OMA2
J2J7lJbOk40GH7FGvr8ToM97uaxYkwbhHUOiQc8kXEOWrGIrjB1uuvSvVCf6Wnrv
WRy58wtzBYSvVAu2nsA+fNgMuoJIpw==
=oKa0
-----END PGP SIGNATURE-----

--RqdhdAcoGDu68i7W85MHGGWc10Lk9lg41--
