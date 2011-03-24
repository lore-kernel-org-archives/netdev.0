From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: RFC: [PATCH] can: c_can: disable one shot mode until driver is
	fixed
Date: Thu, 24 Mar 2011 11:44:46 +0100
Message-ID: <4D8B209E.5010907@pengutronix.de>
References: <1300961549-28882-1-git-send-email-mkl@pengutronix.de>
	<20110324102852.GA339@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8556569667838299296=="
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110324102852.GA339-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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
--===============8556569667838299296==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig22ED0BDBE4B7AA0968021C13"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig22ED0BDBE4B7AA0968021C13
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/24/2011 11:28 AM, Kurt Van Dijck wrote:
> On Thu, Mar 24, 2011 at 11:12:29AM +0100, Marc Kleine-Budde wrote:
>> This patch disables the one shot mode, until the driver has been fixed=
 and
>> tested to support it.
>>
> isn't this part necessary now (temporarily) to avoid dead code?

It's not necessary, the driver should still work. But it's dead code. If
someone fixes the driver she/he can easily revert the patch.

Can I fold your patch and add your S-o-b?

Marc
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 1405078..2c3d090 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -588,14 +588,9 @@ static void c_can_chip_config(struct net_device *d=
ev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
> -	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> -		/* disable automatic retransmission */
> -		priv->write_reg(priv, &priv->regs->control,
> -				CONTROL_DISABLE_AR);
> -	else
> -		/* enable automatic retransmission */
> -		priv->write_reg(priv, &priv->regs->control,
> -				CONTROL_ENABLE_AR);
> +	/* enable automatic retransmission */
> +	priv->write_reg(priv, &priv->regs->control,
> +			CONTROL_ENABLE_AR);
> =20
>  	if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
>  					CAN_CTRLMODE_LOOPBACK)) {
>=20
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> https://lists.berlios.de/mailman/listinfo/socketcan-core


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig22ED0BDBE4B7AA0968021C13
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2LIKEACgkQjTAFq1RaXHOxfgCghKfTTQvgUenoB/jBXAUicSqZ
YsEAn1yRo7DRJ1GV67HI5yVFv6ZZr7IT
=z+TQ
-----END PGP SIGNATURE-----

--------------enig22ED0BDBE4B7AA0968021C13--

--===============8556569667838299296==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8556569667838299296==--
