From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: c_can: convert to use devm * api
Date: Sun, 22 Jun 2014 12:56:24 +0200
Message-ID: <53A6B658.6030709@pengutronix.de>
References: <1403265574-12923-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fgMfhWC7AtGXTHDrHh2UnqpNvTOg1N88w"
Cc: LKML <linux-kernel@vger.kernel.org>
To: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403265574-12923-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fgMfhWC7AtGXTHDrHh2UnqpNvTOg1N88w
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/20/2014 01:59 PM, Lad, Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>=20
> this patch uses devm_* APIs as they are device managed
> and make code simpler.
>=20
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Thanks for the patch. Applied to can-next with minor change (see inline).=


> ---
>  Note: This patch is compile tested only.
> =20
>  drivers/net/can/c_can/c_can_platform.c | 41 ++++++++------------------=
--------
>  1 file changed, 9 insertions(+), 32 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 1df0b32..e0dcbcf 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -157,40 +157,31 @@ static int c_can_plat_probe(struct platform_devic=
e *pdev)
>  	}
> =20
>  	/* get the appropriate clk */
> -	clk =3D clk_get(&pdev->dev, NULL);
> +	clk =3D devm_clk_get(&pdev->dev, NULL);
>  	if (IS_ERR(clk)) {
> -		dev_err(&pdev->dev, "no clock defined\n");
> -		ret =3D -ENODEV;
> +		ret =3D PTR_ERR(clk);
>  		goto exit;
>  	}
> =20
>  	/* get the platform data */
>  	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	irq =3D platform_get_irq(pdev, 0);
> -	if (!mem || irq <=3D 0) {
> -		ret =3D -ENODEV;
> -		goto exit_free_clk;
> -	}
> -
> -	if (!request_mem_region(mem->start, resource_size(mem),
> -				KBUILD_MODNAME)) {
> -		dev_err(&pdev->dev, "resource unavailable\n");
> +	if (irq <=3D 0) {
>  		ret =3D -ENODEV;
> -		goto exit_free_clk;
> +		goto exit;
>  	}
> =20
> -	addr =3D ioremap(mem->start, resource_size(mem));
> -	if (!addr) {
> -		dev_err(&pdev->dev, "failed to map can port\n");
> -		ret =3D -ENOMEM;
> -		goto exit_release_mem;

I've moved the mem =3D platform_get_resource() for slightly better
readability here....

> +	addr =3D devm_ioremap_resource(&pdev->dev, mem);
> +	if (IS_ERR(addr)) {
> +		ret =3D  PTR_ERR(addr);
> +		goto exit;
>  	}

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fgMfhWC7AtGXTHDrHh2UnqpNvTOg1N88w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOmtlsACgkQjTAFq1RaXHNXSgCfQi30zV/CnoMzok0XdmLDaAED
gaUAn2UX++T09aAp1w/KiL4CMBSirhD6
=c4pQ
-----END PGP SIGNATURE-----

--fgMfhWC7AtGXTHDrHh2UnqpNvTOg1N88w--
