From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: sja1000_isa: fix "limited range" compiler warnings
Date: Thu, 24 Nov 2011 10:34:46 +0100
Message-ID: <4ECE0FB6.5000106@pengutronix.de>
References: <4ECE0993.6050902@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig08FD1C15445EDDA193883521"
Cc: Netdev@vger.kernel.org,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ECE0993.6050902@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig08FD1C15445EDDA193883521
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2011 10:08 AM, Wolfgang Grandegger wrote:
> This patch fixes the compiler warnings: "comparison is always
> false due to limited range of data type" by using "0xff" instead
> of "-1" for unsigned values.
>=20
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>  drivers/net/can/sja1000/sja1000_isa.c |   24 ++++++++++++------------
>  1 files changed, 12 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sj=
a1000/sja1000_isa.c
> index 496223e..f0840d5 100644
> --- a/drivers/net/can/sja1000/sja1000_isa.c
> +++ b/drivers/net/can/sja1000/sja1000_isa.c
> @@ -44,9 +44,9 @@ static unsigned long port[MAXDEV];
>  static unsigned long mem[MAXDEV];
>  static int __devinitdata irq[MAXDEV];
>  static int __devinitdata clk[MAXDEV];
> -static char __devinitdata cdr[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D -1=
};
> -static char __devinitdata ocr[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D -1=
};
> -static char __devinitdata indirect[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D=
 -1};
> +static unsigned char __devinitdata cdr[MAXDEV] =3D {[0 ... (MAXDEV - 1=
)] =3D 0xff};
> +static unsigned char __devinitdata ocr[MAXDEV] =3D {[0 ... (MAXDEV - 1=
)] =3D 0xff};
> +static int __devinitdata indirect[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D=
 -1};
> =20
>  module_param_array(port, ulong, NULL, S_IRUGO);
>  MODULE_PARM_DESC(port, "I/O port number");
> @@ -54,7 +54,7 @@ MODULE_PARM_DESC(port, "I/O port number");
>  module_param_array(mem, ulong, NULL, S_IRUGO);
>  MODULE_PARM_DESC(mem, "I/O memory address");
> =20
> -module_param_array(indirect, byte, NULL, S_IRUGO);
> +module_param_array(indirect, int, NULL, S_IRUGO);
>  MODULE_PARM_DESC(indirect, "Indirect access via address and data port"=
);
> =20
>  module_param_array(irq, int, NULL, S_IRUGO);
> @@ -189,17 +189,17 @@ static int __devinit sja1000_isa_probe(struct dev=
ice *pdev, unsigned int idx)
>  	else
>  		priv->can.clock.freq =3D CLK_DEFAULT / 2;
> =20
> -	if (ocr[idx] !=3D -1)
> -		priv->ocr =3D ocr[idx] & 0xff;
> -	else if (ocr[0] !=3D -1)
> -		priv->ocr =3D ocr[0] & 0xff;
> +	if (ocr[idx] !=3D 0xff)
> +		priv->ocr =3D ocr[idx];
> +	else if (ocr[0] !=3D 0xff)
> +		priv->ocr =3D ocr[0];
>  	else
>  		priv->ocr =3D OCR_DEFAULT;
> =20
> -	if (cdr[idx] !=3D -1)
> -		priv->cdr =3D cdr[idx] & 0xff;
> -	else if (cdr[0] !=3D -1)
> -		priv->cdr =3D cdr[0] & 0xff;
> +	if (cdr[idx] !=3D 0xff)
> +		priv->cdr =3D cdr[idx];
> +	else if (cdr[0] !=3D 0xff)
> +		priv->cdr =3D cdr[0];
>  	else
>  		priv->cdr =3D CDR_DEFAULT;
> =20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig08FD1C15445EDDA193883521
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7OD7kACgkQjTAFq1RaXHNx8wCgkdd6wTserJ7i3/dHofyRByrI
QoEAn1PH7Rue6vER+UWfiPoB9lWlxHZK
=RcpF
-----END PGP SIGNATURE-----

--------------enig08FD1C15445EDDA193883521--
