From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 5/6] net: davinci_emac: Fix ioremap for devices with MDIO
 within the EMAC address space
Date: Tue, 13 Jan 2015 13:54:05 -0600
Message-ID: <20150113195405.GU16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-6-git-send-email-tony@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SidV/bKy1CyabPX8"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421177368-19756-6-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--SidV/bKy1CyabPX8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 11:29:27AM -0800, Tony Lindgren wrote:
> Some devices like dm816x have the MDIO registers within the first EMAC
> instance address space. Let's fix the issue by allowing to pass an
> optional second IO range for the EMAC control register area.
>=20
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/etherne=
t/ti/davinci_emac.c
> index 4c8d82c..0342273 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1877,7 +1877,7 @@ davinci_emac_of_get_pdata(struct platform_device *p=
dev, struct emac_priv *priv)
>  static int davinci_emac_probe(struct platform_device *pdev)
>  {
>  	int rc =3D 0;
> -	struct resource *res;
> +	struct resource *res, *res_ctrl;
>  	struct net_device *ndev;
>  	struct emac_priv *priv;
>  	unsigned long hw_ram_addr;
> @@ -1936,11 +1936,20 @@ static int davinci_emac_probe(struct platform_dev=
ice *pdev)
>  		rc =3D PTR_ERR(priv->remap_addr);
>  		goto no_pdata;
>  	}
> +
> +	res_ctrl =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	if (res_ctrl) {

devm_ioremap_resource() will check for res_ctrl being a valid pointer,
perhaps below would be slightly better ?


	res_ctrl =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
	priv->ctrl_base =3D devm_ioremap_resource(&pdev->dev, res_ctrl);
	if (IS_ERR(priv->ctrl_base))
		priv->ctrl_base =3D priv->remap_addr + pdata->ctrl_mod_reg_offset;

--=20
balbi

--SidV/bKy1CyabPX8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtXfdAAoJEIaOsuA1yqRERkwP/RAd4sCwDXFgNd7XJle4M4p7
pbTL+F+vOj5L6l4zHZfH/cadQy9crC/EfLCE6j99pBLK18rJ1JURFZy1CfVwpu7P
BMVkIZBygYhvK2Vd5FSGSFXWaGQo1BUBCILRT6ve2kS8oF1EfEmEinMPDvhMsNEA
MdztFFbo6bkOWCfeDHoqq6gi5pgsHU+xPJdl1+dik/GAUEEBVusqPh+Yc+cF0h/b
Km/lKp9FUA+PUYHhyxAa0NW673JSJ0E5fYXsAaaWSiLcVGwJ4TykVe1qsczHL7dh
K9uTcGxVgtprsaKaOfreLEkLmiLiAYLBijKHaF+CeLpioR5NQr8PzXsgo63tmfGs
lDVx91/ucGMkh+z+nbYt3EYpVbmazb0OPvd0fLixQ7k2w8si06fDIejhBCaglD5z
b4B4VVMkQop4FOa0w2JncdH3rt+zjttbX54klRuGhyDvyPhNq21lEuhbKltaqVjs
1IupO8+uI5gqjI9AxwRMvDkQ8E4RWDoBFIgnjg7ZEPUgqt4ILR38kiI3uAi49ZaY
XmR8Ss1pZUbTPY+c+lTPfatkFaWvH8reoJaF3B81rmHBFtsu89wSbgInIntHW31A
4iIrfaeqz4fiHFuzAVKwpH5QUMjUHaEvHdDAm1TGOJfUHzMLoYSXAsRaarvDpU9g
6C8E4VdCRBksDeVFb/Rh
=zqUI
-----END PGP SIGNATURE-----

--SidV/bKy1CyabPX8--
