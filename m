From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 2/3] net: davinci_mdio: Convert pr_err() to dev_err() call
Date: Fri, 2 May 2014 09:18:04 -0500
Message-ID: <20140502141804.GB4631@saruman.home>
References: <1399026017-734-1-git-send-email-george.cherian@ti.com>
 <1399026017-734-3-git-send-email-george.cherian@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DIOMP1UsTsWJauNi"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <davem@davemloft.net>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>
To: George Cherian <george.cherian@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399026017-734-3-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--DIOMP1UsTsWJauNi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 02, 2014 at 03:50:16PM +0530, George Cherian wrote:
> Convert the lone pr_err() to dev_err() call.
> Also, Convert kzalloc to devm_kzalloc.
>=20
> Signed-off-by: George Cherian <george.cherian@ti.com>
> ---

there's a kfree(data) on davinci_mdio_remove() which could be deleted
too. Other than that:

Reviewed-by: Felipe Balbi <balbi@ti.com>

>  drivers/net/ethernet/ti/davinci_mdio.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/etherne=
t/ti/davinci_mdio.c
> index 0cca9de..1b2e30a 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -303,7 +303,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform=
_data *data,
>  		return -EINVAL;
> =20
>  	if (of_property_read_u32(node, "bus_freq", &prop)) {
> -		pr_err("Missing bus_freq property in the DT.\n");
> +		dev_err(&pdev->dev, "Missing bus_freq property in the DT.\n");
>  		return -EINVAL;
>  	}
>  	data->bus_freq =3D prop;
> @@ -321,7 +321,7 @@ static int davinci_mdio_probe(struct platform_device =
*pdev)
>  	struct phy_device *phy;
>  	int ret, addr;
> =20
> -	data =3D kzalloc(sizeof(*data), GFP_KERNEL);
> +	data =3D devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
>  	if (!data)
>  		return -ENOMEM;
> =20
> @@ -414,8 +414,6 @@ bail_out:
>  	pm_runtime_put_sync(&pdev->dev);
>  	pm_runtime_disable(&pdev->dev);
> =20
> -	kfree(data);
> -
>  	return ret;
>  }
> =20
> --=20
> 1.8.3.1
>=20

--=20
balbi

--DIOMP1UsTsWJauNi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTY6kcAAoJEIaOsuA1yqREy5cP/Ay9U6dJP9vNKfzL9cbLi1ww
opEmmgxHA8z2tjqnJIPoBWjSI9aHod7UEnw/holGHgwfHGRht3bJKldFtz7NSFWs
h5UvAYSHu5/zMD0y6Flqc6eKqYTa1Jo20He4QQX5uG0DFFuBIlfgIzwPkd6/tlIV
A9hFEn58+2uLN6J8AZpQ3w3MrcOKgqazoDFOKZUjh4fXtjJcrSU+y2jTUR1cRMQO
/LK+ZWjc8tVivhuB70iDwoKeguS44T3j5qYo7KhvSUrrvbTUQNkSn4VPlpD82CYP
bX3Jqv9tmkZ1+hN0XlA/R6n+FvvG4M7yXR5C3LB05BH3XhP7VN1TIO7dS7UvsZTt
y6NxyZHVbZYfEOayv3q+yPM+C++FleIxlnfUqPEq2a3ne+zzF9P56AAtFigSq84K
GJqRKLMMhT197GoUdkj9ZHhbtWro66GEC1VrTXwk9ZD6KkFB10dOqBvX8JD3pUAD
GlxPQ8wcLw4/nOoFO06u/vgRDD+3v0nvndGDL7IJmcu2Ow1F2ETHul9pLTx/JoST
3aWZMGjgHUlWIbl7P8+8LeNZhfonBCpEsNRGipc4x2QG9cxpLoPvYcV3TsTmHVmP
0Y0Mfe2t8FeyAQw/HzoEdoKixgnldbj4BK1x6jxTzuRLJbNsckp3PhwTjqwXCuXl
hiwxXzAj4OjyAyqS2KFX
=DBpc
-----END PGP SIGNATURE-----

--DIOMP1UsTsWJauNi--
