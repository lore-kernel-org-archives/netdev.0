From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 3/3] drivers: net: davinci_cpdma: Convert kzalloc() to
 devm_kzalloc().
Date: Fri, 2 May 2014 09:21:17 -0500
Message-ID: <20140502142117.GC4631@saruman.home>
References: <1399026017-734-1-git-send-email-george.cherian@ti.com>
 <1399026017-734-4-git-send-email-george.cherian@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jL2BoiuKMElzg3CS"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <davem@davemloft.net>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>
To: George Cherian <george.cherian@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399026017-734-4-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--jL2BoiuKMElzg3CS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, May 02, 2014 at 03:50:17PM +0530, George Cherian wrote:
> Convert kzalloc() to devm_kzalloc().
>=20
> Signed-off-by: George Cherian <george.cherian@ti.com>
> ---
>  drivers/net/ethernet/ti/davinci_cpdma.c | 32 ++++++++++++---------------=
-----
>  1 file changed, 12 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethern=
et/ti/davinci_cpdma.c
> index 88ef270..b83ffbb 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -158,9 +158,9 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, =
u32 hw_addr,
>  	int bitmap_size;
>  	struct cpdma_desc_pool *pool;
> =20
> -	pool =3D kzalloc(sizeof(*pool), GFP_KERNEL);
> +	pool =3D devm_kzalloc(dev, sizeof(*pool), GFP_KERNEL);
>  	if (!pool)
> -		return NULL;
> +		goto fail;
> =20
>  	spin_lock_init(&pool->lock);
> =20
> @@ -170,7 +170,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, =
u32 hw_addr,
>  	pool->num_desc	=3D size / pool->desc_size;
> =20
>  	bitmap_size  =3D (pool->num_desc / BITS_PER_LONG) * sizeof(long);
> -	pool->bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> +	pool->bitmap =3D devm_kzalloc(dev, bitmap_size, GFP_KERNEL);
>  	if (!pool->bitmap)
>  		goto fail;
> =20
> @@ -187,10 +187,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys,=
 u32 hw_addr,
> =20
>  	if (pool->iomap)
>  		return pool;
> -
>  fail:
> -	kfree(pool->bitmap);
> -	kfree(pool);

remove kfree() on cpda_desc_pool_destroy() too.

>  	return NULL;
>  }
> =20
> @@ -276,7 +273,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_par=
ams *params)
>  {
>  	struct cpdma_ctlr *ctlr;
> =20
> -	ctlr =3D kzalloc(sizeof(*ctlr), GFP_KERNEL);
> +	ctlr =3D devm_kzalloc(params->dev, sizeof(*ctlr), GFP_KERNEL);

likewise, drop the kfree() in cpdma_ctlr_destroy()

Fix those and you can add

Reviewed-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--jL2BoiuKMElzg3CS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTY6ndAAoJEIaOsuA1yqRElL4P/0UWVN3l8Gx+UIRzaVEgwbfe
uWvUJG6UYxBIe69EePoKO1WxG9ZP0qXORQzpw4HVQ3Jz1nLGiuu5RCXtf5jq+WIC
EuRsrj7bcJVc2PzIBmGlJijCZmBFy15F5tBMtONGAkZ0au/MvrQZprqg4obhILIY
MhMD34HRDEPvCtL75BHiwsmMwdZwPTdudOQ+X8hImiuzFg6HWLQAl8R7wwhGL0jp
hUOb9NmwN6VUhMmLBXJOnvYUdIdFRIc9FOdiOtC1cANEJ57cNqCRzO4jc4dUuMGB
R9IEvf36cZofpuKAotwXBia7JsYf7kWvxmgOp5aa4EWyP7vYN557pypWORQMjzQT
duYgCY7pHR8LSapCohcoxWspIAMHkDWaywk3GsCrFXzwSlWiZGsaj1tBMB+jJnho
6vKUOW+6ll184t2iAgT69nLamWv8LGbfgYoYi1mWqLo4Q76wavRvDf2o9avwghnK
ufWeFy5S64rLdmRaXTYzAs84b1IRnEfmuHLGTp7r20pNx0pUdNLaTZyoTIwSOCmB
4k7lcCAFMVYsV+9pddyzd+TNdUN3DOT4hj2iSCFSMF2mCnJRKOz8z1lkI8YRTImF
QHb+Af8C8tMylu/4mZqg3a4Q0jh/XnrIxzrEnNGhf54qfcvMvmNMXVUBqBeib8H4
1P/5U2uV2AFDmyl4YrE7
=OoNI
-----END PGP SIGNATURE-----

--jL2BoiuKMElzg3CS--
