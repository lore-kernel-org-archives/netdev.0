From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: sja1000 platform data fixes
Date: Mon, 17 May 2010 16:42:23 +0200
Message-ID: <4BF155CF.3030905@pengutronix.de>
References: <4BF151D2.5030906@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8492958907316124050=="
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4BF151D2.5030906-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8492958907316124050==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7CAD8E397604D657676E6483"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7CAD8E397604D657676E6483
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> The member "clock" of struct "sja1000_platform_data" is documented as
> "CAN bus oscillator frequency in Hz" but it's actually used as the CAN
> clock frequency, which is half of it. To avoid further confusion, this
> patch fixes it by renaming the member to "osc_freq". That way, also
> non mainline users will notice the change. The platform code for the
> relevant boards is updated accordingly. Furthermore, pre-defined
> values are now used for the members "ocr" and "cdr".
>=20
> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> CC: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Cheers, Marc
>=20
> diff --git a/arch/arm/mach-mx2/pcm970-baseboard.c b/arch/arm/mach-mx2/p=
cm970-baseboard.c
> index 4aafd5b..f490a40 100644
> --- a/arch/arm/mach-mx2/pcm970-baseboard.c
> +++ b/arch/arm/mach-mx2/pcm970-baseboard.c
> @@ -201,9 +201,9 @@ static struct resource pcm970_sja1000_resources[] =3D=
 {
>  };
> =20
>  struct sja1000_platform_data pcm970_sja1000_platform_data =3D {
> -	.clock		=3D 16000000 / 2,
> -	.ocr		=3D 0x40 | 0x18,
> -	.cdr		=3D 0x40,
> +	.osc_freq	=3D 16000000,
> +	.ocr		=3D OCR_TX1_PULLDOWN | OCR_TX0_PUSHPULL,
> +	.cdr		=3D CDR_CBP,
>  };
> =20
>  static struct platform_device pcm970_sja1000 =3D {
> diff --git a/arch/arm/mach-mx3/mach-pcm037.c b/arch/arm/mach-mx3/mach-p=
cm037.c
> index 2df1ec5..78ecd75 100644
> --- a/arch/arm/mach-mx3/mach-pcm037.c
> +++ b/arch/arm/mach-mx3/mach-pcm037.c
> @@ -530,9 +530,9 @@ static struct resource pcm970_sja1000_resources[] =3D=
 {
>  };
> =20
>  struct sja1000_platform_data pcm970_sja1000_platform_data =3D {
> -	.clock		=3D 16000000 / 2,
> -	.ocr		=3D 0x40 | 0x18,
> -	.cdr		=3D 0x40,
> +	.osc_freq	=3D 16000000,
> +	.ocr		=3D OCR_TX1_PULLDOWN | OCR_TX0_PUSHPULL,
> +	.cdr		=3D CDR_CBP,
>  };
> =20
>  static struct platform_device pcm970_sja1000 =3D {
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index b65cabb..d9fadc4 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -111,7 +111,8 @@ static int sp_probe(struct platform_device *pdev)
>  	dev->irq =3D res_irq->start;
>  	priv->irq_flags =3D res_irq->flags & (IRQF_TRIGGER_MASK | IRQF_SHARED=
);
>  	priv->reg_base =3D addr;
> -	priv->can.clock.freq =3D pdata->clock;
> +	/* The CAN clock frequency is half the oscillator clock frequency */
> +	priv->can.clock.freq =3D pdata->osc_freq / 2;
>  	priv->ocr =3D pdata->ocr;
>  	priv->cdr =3D pdata->cdr;
> =20
> diff --git a/include/linux/can/platform/sja1000.h b/include/linux/can/p=
latform/sja1000.h
> index 01ee2ae..96f8fcc 100644
> --- a/include/linux/can/platform/sja1000.h
> +++ b/include/linux/can/platform/sja1000.h
> @@ -26,7 +26,7 @@
>  #define OCR_TX_SHIFT      2
> =20
>  struct sja1000_platform_data {
> -	u32 clock;	/* CAN bus oscillator frequency in Hz */
> +	u32 osc_freq;	/* CAN bus oscillator frequency in Hz */
> =20
>  	u8 ocr;		/* output control register */
>  	u8 cdr;		/* clock divider register */


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7CAD8E397604D657676E6483
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkvxVdMACgkQjTAFq1RaXHOvZACfVtRXCG9jM74av7YePxSQzA3F
8d8Anjvieo32Y7sqM0FCHGkkl/QY1k8R
=AzIt
-----END PGP SIGNATURE-----

--------------enig7CAD8E397604D657676E6483--

--===============8492958907316124050==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8492958907316124050==--
