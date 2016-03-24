From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net: macb: replace macb_writel() call by
 queue_writel() to update queue ISR
Date: Thu, 24 Mar 2016 16:39:28 +0100
Message-ID: <56F40A30.6030907@atmel.com>
References: <1458830404-6213-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458830404-6213-1-git-send-email-cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/03/2016 15:40, Cyrille Pitchen a =E9crit :
> macb_interrupt() should not use macb_writel(bp, ISR, <value>) but onl=
y
> queue_writel(queue, ISR, <value>).
>=20
> There is one IRQ and one set of {ISR, IER, IDR, IMR} [1] registers pe=
r
> queue on gem hardware, though only queue0 is actually used for now to
> receive frames: other queues can already be used to transmit frames.
>=20
> The queue_readl() and queue_writel() helper macros are designed to ac=
cess
> the relevant IRQ registers.
>=20
> [1]
> ISR: Interrupt Status Register
> IER: Interrupt Enable Register
> IDR: Interrupt Disable Register
> IMR: Interrupt Mask Register
>=20
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Fixes: bfbb92c44670 ("net: macb: Handle the RXUBR interrupt on all de=
vices")

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks!

> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 39447a337149..c9c6b2762a39 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1146,7 +1146,7 @@ static irqreturn_t macb_interrupt(int irq, void=
 *dev_id)
>  			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
> =20
>  			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> -				macb_writel(bp, ISR, MACB_BIT(RXUBR));
> +				queue_writel(queue, ISR, MACB_BIT(RXUBR));
>  		}
> =20
>  		if (status & MACB_BIT(ISR_ROVR)) {
>=20


--=20
Nicolas Ferre
