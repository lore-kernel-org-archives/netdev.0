From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Fri, 27 Sep 2013 17:40:29 -0700
Message-ID: <1380328829.2965.3.camel@joe-AO722>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-09-28 at 02:11 +0400, Sergei Shtylyov wrote:
> Add support for the CAN controller found in Renesas R-Car SoCs. 

trivia:

> +++ linux-can-next/drivers/net/can/rcar_can.c
[]
> +static void rcar_can_rx_pkt(struct rcar_can_priv *priv, int mbx)
> +{
> +       struct net_device_stats *stats = &priv->ndev->stats;
> +       struct can_frame *cf;
> +       struct sk_buff *skb;
> +       u32 data;
> +       u8 dlc;
> +
> +       skb = alloc_can_skb(priv->ndev, &cf);
> +       if (!skb) {
> +               stats->rx_dropped++;
> +               if (printk_ratelimit())
> +                       netdev_err(priv->ndev,
> +                                  "%s: alloc_can_skb() failed\n", __func__);

This logging message is unnecessary because it's
redundant to the generic OOM error in __alloc_skb.
It already gets a dump_stack();




