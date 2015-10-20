From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] net, can, ti_hecc: fix a run time warn_on.
Date: Tue, 20 Oct 2015 16:46:37 +0200
Message-ID: <562653CD.5040101@pengutronix.de>
References: <1445351968-18956-1-git-send-email-anton.a.glukhov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="cw15kantm8NdNV84hnhbiqAQxq5cWcd7I"
Cc: hs@denx.de, netdev@vger.kernel.org
To: Anton Glukhov <anton.a.glukhov@gmail.com>,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1445351968-18956-1-git-send-email-anton.a.glukhov@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cw15kantm8NdNV84hnhbiqAQxq5cWcd7I
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/20/2015 04:39 PM, Anton Glukhov wrote:
> This patch fixes a warning in clk_enable by calling
> clk_prepare_enable instead.
>=20
> Signed-off-by: Heiko Schocher <hs@denx.de>
> Signed-off-by: Anton Glukhov <anton.a.glukhov@gmail.com>
> ---
>  drivers/net/can/ti_hecc.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index cf345cb..77dd170 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -951,7 +951,7 @@ static int ti_hecc_probe(struct platform_device *pd=
ev)
>  	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>  		HECC_DEF_NAPI_WEIGHT);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);

please add error checking

>  	err =3D register_candev(ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "register_candev() failed\n");
> @@ -966,7 +966,8 @@ static int ti_hecc_probe(struct platform_device *pd=
ev)
>  	return 0;
> =20
>  probe_exit_clk:
> -	clk_put(priv->clk);

Why do you remove the clk_put()?

> +	clk_disable_unprepare(priv->clk);
> +	priv->clk =3D NULL;

The NULLing of priv->clk is not needed.

>  probe_exit_candev:
>  	free_candev(ndev);
>  probe_exit_iounmap:
> @@ -984,8 +985,8 @@ static int ti_hecc_remove(struct platform_device *p=
dev)
>  	struct ti_hecc_priv *priv =3D netdev_priv(ndev);
> =20
>  	unregister_candev(ndev);
> -	clk_disable(priv->clk);
> -	clk_put(priv->clk);

Why do you remoe the clk_put()?

> +	clk_disable_unprepare(priv->clk);
> +	priv->clk =3D NULL;
>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	iounmap(priv->base);
>  	release_mem_region(res->start, resource_size(res));
> @@ -1009,7 +1010,7 @@ static int ti_hecc_suspend(struct platform_device=
 *pdev, pm_message_t state)
>  	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
> -	clk_disable(priv->clk);
> +	clk_disable_unprepare(priv->clk);
> =20
>  	return 0;
>  }
> @@ -1019,7 +1020,7 @@ static int ti_hecc_resume(struct platform_device =
*pdev)
>  	struct net_device *dev =3D platform_get_drvdata(pdev);
>  	struct ti_hecc_priv *priv =3D netdev_priv(dev);
> =20
> -	clk_enable(priv->clk);
> +	clk_prepare_enable(priv->clk);

please add error checking.

> =20
>  	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>=20

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cw15kantm8NdNV84hnhbiqAQxq5cWcd7I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJlPNAAoJEP5prqPJtc/H1e0H/RljxRTb1Bkphpe+CrVw33gf
VvN6SsgFuslESrJjFUiqsiBi28Q/mdxMCwixD6yzYd6virc+o8QYzzMFNei5cZPh
5bKdiSweBVzOGQszCdlTDIk2KxCHZZ/oj1drvHAm/tfSnLRfn+7gzc/DwCPoi+uf
ENul+4vOS3O9BGANpL+oaW/g8DhJuYNUg+t7u+HbXd0qZgJGKms3qrdKOyT+XRwj
vmUUiQ2479vUztkZlj+OqY1T5JoU2SaHQ+d+Dx7Hdw39EJJwWwc82YrmKsM6QbrF
0Gz/nihL07erl/+Jdm65xJz5h6/LiQVOmCmcqHrGD3ec5UkOdhixDSCCbP6uTl4=
=1IiJ
-----END PGP SIGNATURE-----

--cw15kantm8NdNV84hnhbiqAQxq5cWcd7I--
