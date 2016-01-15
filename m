From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: clear interrupts when disabling them
Date: Fri, 15 Jan 2016 09:25:29 +0100
Message-ID: <5698ACF9.7020601@atmel.com>
References: <1452799647-1426-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452799647-1426-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/01/2016 20:27, Nathan Sullivan a =E9crit :
> Disabling interrupts with the IDR register does not stop the macb har=
dware
> from asserting its interrupt line if there are interrupts pending.  A=
lways
> clear the interrupts using ISR, and be sure to write it on hardware t=
hat
> is not read-to-clear, like Zynq.  Not doing so will cause interrupts =
when
> the driver doesn't expect them.
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

It seems okay:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c |    4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index c563475..9d9984a 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1040,6 +1040,8 @@ static irqreturn_t macb_interrupt(int irq, void=
 *dev_id)
>  		/* close possible race with dev_close */
>  		if (unlikely(!netif_running(dev))) {
>  			queue_writel(queue, IDR, -1);
> +			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +				queue_writel(queue, ISR, -1);
>  			break;
>  		}
> =20
> @@ -1561,6 +1563,8 @@ static void macb_reset_hw(struct macb *bp)
>  	for (q =3D 0, queue =3D bp->queues; q < bp->num_queues; ++q, ++queu=
e) {
>  		queue_writel(queue, IDR, -1);
>  		queue_readl(queue, ISR);
> +		if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +			queue_writel(queue, ISR, -1);
>  	}
>  }
> =20
>=20


--=20
Nicolas Ferre
