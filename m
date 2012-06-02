From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] fec_mpc52xx: fix timestamp filtering
Date: Sat, 2 Jun 2012 21:06:05 +0200
Message-ID: <20120602190605.GA2202@netboy.at.omicron.at>
References: <1338642246-10911-1-git-send-email-stephan@gatzka.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stable <stable@vger.kernel.org>
To: Stephan Gatzka <stephan@gatzka.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41786 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965649Ab2FBTGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 15:06:17 -0400
Content-Disposition: inline
In-Reply-To: <1338642246-10911-1-git-send-email-stephan@gatzka.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 02, 2012 at 03:04:06PM +0200, Stephan Gatzka wrote:
> skb_defer_rx_timestamp was called with a freshly allocated skb but must
> be called with rskb instead.

Thanks for checking this, and sorry for the trouble it caused you.

Acked-by: Richard Cochran <richardcochran@gmail.com>

> 
> Signed-off-by: Stephan Gatzka <stephan@gatzka.org>
> Cc: stable <stable@vger.kernel.org>
> ---
>  drivers/net/ethernet/freescale/fec_mpc52xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
> index 97f947b..2933d08 100644
> --- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
> +++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
> @@ -437,7 +437,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
>  		length = status & BCOM_FEC_RX_BD_LEN_MASK;
>  		skb_put(rskb, length - 4);	/* length without CRC32 */
>  		rskb->protocol = eth_type_trans(rskb, dev);
> -		if (!skb_defer_rx_timestamp(skb))
> +		if (!skb_defer_rx_timestamp(rskb))
>  			netif_rx(rskb);
>  
>  		spin_lock(&priv->lock);
> -- 
> 1.7.9.5
> 
