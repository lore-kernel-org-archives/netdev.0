From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net: macb: Write only necessary bits in NCR in macb
 reset
Date: Tue, 29 Nov 2016 09:57:47 +0100
Message-ID: <b509fe3c-ea7c-e593-8dd5-76e89a13a746@atmel.com>
References: <1480398985-24037-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <harinik@xilinx.com>, <michals@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>, <davem@davemloft.net>,
        <harinikatakamlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:31875 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbcK2I6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 03:58:30 -0500
In-Reply-To: <1480398985-24037-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/11/2016 à 06:56, Harini Katakam a écrit :
> In macb_reset_hw, use read-modify-write to disable RX and TX.
> Existing settings, for ex. management port enable,
> are being cleared in the current implementation.
> Also certain reserved bits are read only.
> Hence it is better to use read-modify-write.
> Use the same method for clearing statistics as well.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
> 
> v2:
> Make ctrl type as u32
> Improve commit description
> 
> ---
>  drivers/net/ethernet/cadence/macb.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 0e489bb..2ce3407 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1744,14 +1744,18 @@ static void macb_reset_hw(struct macb *bp)
>  {
>  	struct macb_queue *queue;
>  	unsigned int q;
> +	u32 ctrl;
>  
>  	/* Disable RX and TX (XXX: Should we halt the transmission
>  	 * more gracefully?)
>  	 */
> -	macb_writel(bp, NCR, 0);
> +	ctrl = macb_readl(bp, NCR);
> +	ctrl &= ~(MACB_BIT(RE) | MACB_BIT(TE));
> +	macb_writel(bp, NCR, ctrl);
>  
>  	/* Clear the stats registers (XXX: Update stats first?) */
> -	macb_writel(bp, NCR, MACB_BIT(CLRSTAT));
> +	ctrl |= MACB_BIT(CLRSTAT);
> +	macb_writel(bp, NCR, ctrl);
>  
>  	/* Clear all status flags */
>  	macb_writel(bp, TSR, -1);
> 


-- 
Nicolas Ferre
