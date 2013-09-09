From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 16/16] c_can: fix TX packet accounting
Date: Mon, 09 Sep 2013 12:31:02 +0200
Message-ID: <522DA366.5060809@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-17-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="O6JtuF38GIu5Q3BKSGxwxkDOS1h81TmmA"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-17-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--O6JtuF38GIu5Q3BKSGxwxkDOS1h81TmmA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> Due to the integration of the FlexCard support the TX stats accounting =
got
> lost. Readd the accounting.

Please squash into the appropriate patch.

Marc

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 92c1444..b409cf2 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -619,6 +619,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff =
*skb,
>  	u32 msg_obj_no;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	struct can_frame *frame =3D (struct can_frame *)skb->data;
> +	struct net_device_stats *stats =3D &dev->stats;
>  	int tx_fifo, txie_off;
> =20
>  	if (can_dropped_invalid_skb(dev, skb))
> @@ -664,6 +665,9 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff =
*skb,
>  		ctrl =3D readl(priv->base + FC_TXFIFO_CTRL);
>  		ctrl |=3D FC_TXFIFO_CTRL_REQ;
>  		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
> +
> +		stats->tx_bytes +=3D frame->can_dlc;
> +		stats->tx_packets++;
>  		kfree_skb(skb);
>  	} else {
>  		msg_obj_no =3D get_tx_next_msg_obj(priv);
> @@ -672,6 +676,8 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff =
*skb,
>  		c_can_write_msg_object(dev, 0, frame, msg_obj_no, txie_off);
>  		priv->tx_next++;
> =20
> +		stats->tx_bytes +=3D frame->can_dlc;
> +		stats->tx_packets++;
>  		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
>  		/* we have to stop the queue in case of a wrap around or
>  		 * if the next TX message object is still in use
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--O6JtuF38GIu5Q3BKSGxwxkDOS1h81TmmA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIto2YACgkQjTAFq1RaXHME6gCfeEAv9U37rV+cLLnwNB3uSqU3
Ke8AoINDp791sUUfs/e1TomxMGM2a6/9
=d5Wj
-----END PGP SIGNATURE-----

--O6JtuF38GIu5Q3BKSGxwxkDOS1h81TmmA--
