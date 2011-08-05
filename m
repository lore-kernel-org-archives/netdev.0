From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [flexcan] Add support for FLEXCAN_DEBUG
Date: Fri, 05 Aug 2011 09:16:06 +0200
Message-ID: <4E3B98B6.4040003@pengutronix.de>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
	<1312509979-13226-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8018226937775675283=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312509979-13226-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
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
--===============8018226937775675283==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigABA831039DB1FCDFFB7F70D4"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigABA831039DB1FCDFFB7F70D4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/05/2011 04:06 AM, Robin Holt wrote:
> Add a wrapper function for a register dump when a developer defines
> FLEXCAN_DEBUG

Comments inline..however I'm not sure if we need this patch.

> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  drivers/net/can/flexcan.c |   40 +++++++++++++++++++++++++++++++++++++=
+++
>  1 files changed, 40 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index fbb61c6..96684ca 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -316,6 +316,38 @@ static inline unsigned long flexcan_clk_get_rate(s=
truct clk *clk)
> =20
>  #endif
> =20
> +#if defined(FLEXCAN_DEBUG)
> +void _flexcan_reg_dump(struct net_device *dev, const char *file, int l=
ine,
> +		       const char *func)
> +{
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +
> +	printk(KERN_INFO "flexcan_reg_dump:%s:%d:%s()\n", file, line, func);

Use netdev_$LEVEL, please.
If you use dbg, you can remove the ifdef altogether.

> +	printk(KERN_INFO
> +		"\t  mcr 0x%08x  ctrl 0x%08x timer 0x%08x   rxg 0x%08x",
> +		flexcan_read(&regs->mcr),
> +		flexcan_read(&regs->ctrl),
> +		flexcan_read(&regs->timer),
> +		flexcan_read(&regs->rxgmask));
> +	printk(KERN_INFO
> +		"\t rx14 0x%08x  rx15 0x%08x   ecr 0x%08x   esr 0x%08x",
> +		flexcan_read(&regs->rx14mask),
> +		flexcan_read(&regs->rx15mask),
> +		flexcan_read(&regs->ecr),
> +		flexcan_read(&regs->esr));
> +	printk(KERN_INFO
> +		"\timsk2 0x%08x imsk1 0x%08x iflg2 0x%08x iflg1 0x%08x",
> +		flexcan_read(&regs->imask2),
> +		flexcan_read(&regs->imask1),
> +		flexcan_read(&regs->iflag2),
> +		flexcan_read(&regs->iflag1));
> +}
> +#define flexcan_reg_dump(_d) _flexcan_reg_dump(_d, __FILE__, __LINE__,=
 __func__)
> +#else
> +#define flexcan_reg_dump(_d)
> +#endif
> +
>  /*
>   * Swtich transceiver on or off
>   */
> @@ -376,6 +408,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	u32 can_id;
>  	u32 ctrl =3D FLEXCAN_MB_CNT_CODE(0xc) | (cf->can_dlc << 16);
> =20
> +	flexcan_reg_dump(dev);
> +
>  	if (can_dropped_invalid_skb(dev, skb))
>  		return NETDEV_TX_OK;
> =20
> @@ -408,6 +442,8 @@ static int flexcan_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	/* tx_packets is incremented in flexcan_irq */
>  	stats->tx_bytes +=3D cf->can_dlc;
> =20
> +	flexcan_reg_dump(dev);
> +
>  	return NETDEV_TX_OK;
>  }
> =20
> @@ -676,6 +712,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
>  	struct flexcan_regs __iomem *regs =3D priv->base;
>  	u32 reg_iflag1, reg_esr;
> =20
> +	flexcan_reg_dump(dev);
> +
>  	reg_iflag1 =3D flexcan_read(&regs->iflag1);
>  	reg_esr =3D flexcan_read(&regs->esr);
>  	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
> @@ -716,6 +754,8 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
>  		netif_wake_queue(dev);
>  	}
> =20
> +	flexcan_reg_dump(dev);
> +
>  	return IRQ_HANDLED;
>  }
> =20

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigABA831039DB1FCDFFB7F70D4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk47mLYACgkQjTAFq1RaXHMvZACfcghOTyC8ROayfz8LTyVs6KZ0
bwIAni+Kyedy0kR64mbkpTDrvrCwmRSb
=IYJS
-----END PGP SIGNATURE-----

--------------enigABA831039DB1FCDFFB7F70D4--

--===============8018226937775675283==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8018226937775675283==--
