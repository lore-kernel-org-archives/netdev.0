From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v8 03/20] CAN : Fix endianness issue.
Date: Sun, 12 Dec 2010 16:30:26 +0100
Message-ID: <4D04EA92.2010802@pengutronix.de>
References: <4CFE1489.4030808@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7356558899495613242=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CFE1489.4030808-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============7356558899495613242==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6811D42A31640DF4F02BB901"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6811D42A31640DF4F02BB901
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/07/2010 12:03 PM, Tomoya MORINAGA wrote:
> there is endianness issue both Tx and Rx.
> Currently, data is set like below.
> Register:
> MSB--LSB
> x x D0 D1
> x x D2 D3
> x x D4 D5
> x x D6 D7
>=20
> But Data to be sent must be set like below.
> Register:
> MSB--LSB
> x x D1 D0
> x x D3 D2
> x x D5 D4
> x x D7 D6  (x means reserved area.)

Nitpick inline, please fix it, then add my Acked-by

Marc

> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |   47 +++++++++++++++++++------------------=
-------
>  1 files changed, 20 insertions(+), 27 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 0b6d4f4..b17ca0c 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -138,10 +138,7 @@ struct pch_can_if_regs {
>  	u32 id1;
>  	u32 id2;
>  	u32 mcont;
> -	u32 dataa1;
> -	u32 dataa2;
> -	u32 datab1;
> -	u32 datab2;
> +	u32 data[4];
>  	u32 rsv[13];
>  };
> =20
> @@ -424,10 +421,10 @@ static void pch_can_clear_buffers(struct pch_can_=
priv *priv)
>  		iowrite32(0x0, &priv->regs->ifregs[0].id1);
>  		iowrite32(0x0, &priv->regs->ifregs[0].id2);
>  		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
> -		iowrite32(0x0, &priv->regs->ifregs[0].dataa1);
> -		iowrite32(0x0, &priv->regs->ifregs[0].dataa2);
> -		iowrite32(0x0, &priv->regs->ifregs[0].datab1);
> -		iowrite32(0x0, &priv->regs->ifregs[0].datab2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[0]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[1]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[2]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[3]);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->ifregs[0].cmask);
> @@ -441,10 +438,10 @@ static void pch_can_clear_buffers(struct pch_can_=
priv *priv)
>  		iowrite32(0x0, &priv->regs->ifregs[1].id1);
>  		iowrite32(0x0, &priv->regs->ifregs[1].id2);
>  		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
> -		iowrite32(0x0, &priv->regs->ifregs[1].dataa1);
> -		iowrite32(0x0, &priv->regs->ifregs[1].dataa2);
> -		iowrite32(0x0, &priv->regs->ifregs[1].datab1);
> -		iowrite32(0x0, &priv->regs->ifregs[1].datab2);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[0]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[1]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[2]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[3]);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->ifregs[1].cmask);
> @@ -707,12 +704,13 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  	canid_t id;
>  	u32 ide;
>  	u32 rtr;
> -	int i, j, k;
> +	int i, k;
>  	int rcv_pkts =3D 0;
>  	struct sk_buff *skb;
>  	struct can_frame *cf;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	u16 data_reg;
> =20
>  	/* Reading the messsage object from the Message RAM */
>  	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> @@ -778,12 +776,10 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  			      ((ioread32(&priv->regs->ifregs[0].mcont)) & 0x0f);
>  		}
> =20
> -		for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -			reg =3D ioread32(&priv->regs->ifregs[0].dataa1 + j*4);
> -			cf->data[i++] =3D cpu_to_le32(reg & 0xff);
> -			if (i =3D=3D cf->can_dlc)
> -				break;
> -			cf->data[i++] =3D cpu_to_le32((reg >> 8) & 0xff);
> +		for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
> +			data_reg =3D ioread16(&priv->regs->ifregs[0].data[i / 2]);
> +			cf->data[i] =3D data_reg & 0xff;

The & 0xff is not needed cf->data is only 8bit wide.

> +			cf->data[i + 1] =3D data_reg >> 8;
>  		}
> =20
>  		netif_receive_skb(skb);
> @@ -1016,10 +1012,10 @@ static int pch_close(struct net_device *ndev)
> =20
>  static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *nd=
ev)
>  {
> -	int i, j;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct can_frame *cf =3D (struct can_frame *)skb->data;
>  	int tx_buffer_avail =3D 0;
> +	int i;
> =20
>  	if (can_dropped_invalid_skb(ndev, skb))
>  		return NETDEV_TX_OK;
> @@ -1060,13 +1056,10 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
, struct net_device *ndev)
>  	if (cf->can_id & CAN_RTR_FLAG)
>  		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
> =20
> -	for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -		iowrite32(le32_to_cpu(cf->data[i++]),
> -			 (&priv->regs->ifregs[1].dataa1) + j*4);
> -		if (i =3D=3D cf->can_dlc)
> -			break;
> -		iowrite32(le32_to_cpu(cf->data[i++] << 8),
> -			 (&priv->regs->ifregs[1].dataa1) + j*4);
> +	/* Copy data to register */
> +	for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
> +		iowrite16(cf->data[i] | (cf->data[i + 1] << 8),
> +			  &priv->regs->ifregs[1].data[i / 2]);
>  	}
> =20
>  	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_END - 1);


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6811D42A31640DF4F02BB901
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0E6pMACgkQjTAFq1RaXHNDhwCeNCsCUUZXijS4lSgVyfDGGdmL
o6UAnjYHFyHm6OTYEpEsLHk2cIppjg1W
=oSfo
-----END PGP SIGNATURE-----

--------------enig6811D42A31640DF4F02BB901--

--===============7356558899495613242==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7356558899495613242==--
