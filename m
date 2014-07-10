From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 08:08:05 -0500
Message-ID: <20140710130805.GC15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gr/z0/N6AeWAPJVB"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54748 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753611AbaGJNI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 09:08:59 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--gr/z0/N6AeWAPJVB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:41AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> This patch does the following changes
> 1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device obje=
ct
>    or convert to dev_dbg() if we have device object.
> 2. convert printk(KERN_WARNING.. to netdev_warn() if we have net_device o=
bject
>    or convert to dev_warn() if we have device object
> 3. convert printk() to pr_*
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ethernet/ti/cpmac.c |  136 ++++++++++++++++++---------------=
------
>  1 file changed, 62 insertions(+), 74 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index 1d8ef39..9faf669 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
>  		if (i % 16 =3D=3D 0) {
>  			if (i)
>  				pr_cont("\n");
> -			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
> -			       priv->regs + i);
> +			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
>  		}
> -		printk(" %08x", cpmac_read(priv->regs, i));
> +		pr_debug(" %08x", cpmac_read(priv->regs, i));

looks like this should be pr_cont()

>  	}
> -	printk("\n");
> +	pr_debug("\n");

same here. Ditto to all below

--=20
balbi

--gr/z0/N6AeWAPJVB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpA1AAoJEIaOsuA1yqRE+TIP/iLeEPcF9i4MiDrgTmpbvBvF
zHqLHfD/k3ZIJDJNRV56/rJH3XGx2oqEWkXz7AifRIE1aR99U/TwkDbkp6XRrnr5
3ekPqM7iK8XI8XIG5Lyc4hYf26lSwEdgj7Tj+xbJWN4p75pBeF4b24l59VyQiMAo
W58fPZhx0YNGPDlDLR6nEU+iaanloB3G5j7I8P7xZRokdT/qgh/G+WRyr8k+Wb/f
YZJ1grqM7JxU5mOhrTe+4/GwHCIaBNcf5w+S9tXcDwgOOcPMk8FN4OmoNatArC+5
WfNYu4H1F5S1RUr15wwhTWwO4lGTAk+OQMsGXb0uTTp8qEizz3hAOnOwRTaoOhba
xMCnSNzJUby87bJaqgGtzKMmBw9R20GRYwt7lUy/Rb5UgyOBBrokIxgTzzuaxBMY
+ZPYLFUOSiGBImtxoN7CGRdmEPTaxFGYCAMxp8AjkrWV6Y8TTCvaV3bsZAhGT6gQ
upWhZf/QCYDFDfuOhbh4TEMCQ+ElVnWosXT9PuUBZCuuzr4rplCvqNKVk6H19Ol8
rMrjlDgh95TrxYToXA7zOGQSjKDHnlMpJYkiB8BqXpl0Sd1Oy+1xamrlYeZj6MX1
BG7rE/JuuSAauHzk+xHbgoQQLEFc03/6R5+s4XTqpOWHSOhP3rTvkmj5bbqsN6GT
pGcAaOi9FWSduqkzaUUP
=SkKQ
-----END PGP SIGNATURE-----

--gr/z0/N6AeWAPJVB--
