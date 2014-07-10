From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 7/7] net: cpmac: fix in releasing resources
Date: Thu, 10 Jul 2014 08:11:53 -0500
Message-ID: <20140710131153.GG15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-8-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yZnyZsPjQYjG7xG7"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42827 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702AbaGJNMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 09:12:48 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-8-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--yZnyZsPjQYjG7xG7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:45AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> before registering the the net device this code freeing net device

remove one 'the'

> by using the label 'fail'
>=20
> fixed by introducing an another label 'out'
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ethernet/ti/cpmac.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index b6efe3e..b68c5b5 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -1142,7 +1142,7 @@ static int cpmac_probe(struct platform_device *pdev)
>  	mem =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
>  	if (!mem) {
>  		rc =3D -ENODEV;
> -		goto fail;
> +		goto out;
>  	}
> =20
>  	dev->irq =3D platform_get_irq_byname(pdev, "irq");
> @@ -1170,7 +1170,7 @@ static int cpmac_probe(struct platform_device *pdev)
>  			dev_err(&pdev->dev, "Could not attach to PHY\n");
> =20
>  		rc =3D PTR_ERR(priv->phy);
> -		goto fail;
> +		goto out;
>  	}
> =20
>  	rc =3D register_netdev(dev);
> @@ -1189,6 +1189,7 @@ static int cpmac_probe(struct platform_device *pdev)
> =20
>  fail:
>  	free_netdev(dev);
> +out:

this will leak 'dev'.

>  	return rc;
>  }
> =20
> --=20
> 1.7.9.5
>=20

--=20
balbi

--yZnyZsPjQYjG7xG7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpEZAAoJEIaOsuA1yqREFRIQALGUYki6Rroh1u6iRWBd8dlm
zVrwjGmFzLgapFj4oYGHauG7kGz6VPZSem81eZ8pCm1DouvYKRrJwpmzZrdCSPPy
mbEQW0/BH+O/wo/6IVS9/qFgXmba0PWStZP451iqI9ZHra5N7jEPNgP4UG9Ve3hd
BCbcyA19TCPPkNzCwTh86RdojAkBEFj5oi51CfIn13x+HioF/1caLECInRRdhvHq
YbORFG6Rafa2USDsh99T7kw4rgnh2Y0ASeFTzY67j7pP9hSb2qEKHgNr2ZaEoNaX
oYyxfzMvBSKlnrkz+TDZ1aTjTecARoMQzYPO7EHrKQHN9lf/K9g9+tyZz+2ILJDF
XqQklRZCjUZijJ6bGOaKCPi61hSWKw/Ph6eh6j6vq4JOZ+qr3z/gcoGwTfClcw6k
BvuRdgxKDV52O9u0uStkUowEkaXDLInwBhTnYdg5CMHf0auZRStW4X6SQ1waBF8s
7Bl+hZ9EsFCEPCrGjNK+5TEPYRyugjAicGtfVxi5D4SlMQQ61XHtbh7FQTzi/q7h
q1AaYCtV4/bhDaXLjjGPXkvroK/0blYTNrXMXGeX56Lj5RzxMwgoS13no56GeTkD
JkFtsRbZcQu3lYcrTTOcShtxhZCaiUldSR4J1k6TOsWKKeb8PXfMUNkg7nZrE9ai
WUGYXLBkwhrf0/apwAZn
=o8T5
-----END PGP SIGNATURE-----

--yZnyZsPjQYjG7xG7--
