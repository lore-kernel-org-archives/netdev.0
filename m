From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net: macb: ensure ordering write to re-enable RX
 smoothly
Date: Mon, 28 Nov 2016 10:22:21 +0100
Message-ID: <599275f8-f40c-e550-cef6-f902e80d1738@atmel.com>
References: <1480319850-15296-1-git-send-email-zumeng.chen@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Zumeng Chen <zumeng.chen@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:47796 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbcK1JXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:23:01 -0500
In-Reply-To: <1480319850-15296-1-git-send-email-zumeng.chen@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/11/2016 à 08:57, Zumeng Chen a écrit :
> When a hardware issue happened as described by inline comments, the register
> write pattern looks like the following:
> 
>   <write ~MACB_BIT(RE)>
>   + wmb();
>   <write MACB_BIT(RE)>
> 
> There might be a memory barrier between these two write operations, so add wmb
> to ensure an flip from 0 to 1 for NCR.
> 
> Signed-off-by: Zumeng Chen <zumeng.chen@windriver.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 533653b..2f9c5b2 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1156,6 +1156,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
>  		if (status & MACB_BIT(RXUBR)) {
>  			ctrl = macb_readl(bp, NCR);
>  			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
> +			wmb();
>  			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
>  
>  			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)

It seems that there is exactly the same pattern in function
at91ether_interrupt() can you fix both locations in your patch please?

Thanks, best regards,
-- 
Nicolas Ferre
