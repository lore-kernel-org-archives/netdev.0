From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 12/17 v3] can: EG20T PCH: Fix bit timing
	calculation issue
Date: Wed, 24 Nov 2010 13:58:25 +0100
Message-ID: <4CED0BF1.1060305@pengutronix.de>
References: <4CED037F.6060306@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0669653057841683452=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CED037F.6060306-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============0669653057841683452==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig77324EAB8C3B34DEAE8D6DC6"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig77324EAB8C3B34DEAE8D6DC6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2010 01:22 PM, Tomoya MORINAGA wrote:
> Fix bit timing calculation issue
> Modify like use calculated value directly passed by CAN core module.
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

> ---
>  drivers/net/can/pch_can.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 7342030..466f011 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -800,17 +800,15 @@ static int pch_set_bittiming(struct net_device *n=
dev)
>  	const struct can_bittiming *bt =3D &priv->can.bittiming;
>  	u32 canbit;
>  	u32 bepe;
> -	u32 brp;
>=20
>  	/* Setting the CCE bit for accessing the Can Timing register. */
>  	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
>=20
> -	brp =3D (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
> -	canbit =3D brp & PCH_MSK_BITT_BRP;
> +	canbit =3D (bt->brp - 1) & PCH_MSK_BITT_BRP;

Masking here shouldn't be necessary but won't hurt, better play safe.

>  	canbit |=3D (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
>  	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIF=
T;
>  	canbit |=3D (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
> -	bepe =3D (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
> +	bepe =3D ((bt->brp - 1) & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHI=
FT;

dito

>  	iowrite32(canbit, &priv->regs->bitt);
>  	iowrite32(bepe, &priv->regs->brpe);
>  	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig77324EAB8C3B34DEAE8D6DC6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkztC/QACgkQjTAFq1RaXHNRIQCePMQYYBNFn4127QpxG2R6RbjN
q84An0SmoXzlx4RX0uHRcnwVw/w6zvqo
=98VQ
-----END PGP SIGNATURE-----

--------------enig77324EAB8C3B34DEAE8D6DC6--

--===============0669653057841683452==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0669653057841683452==--
