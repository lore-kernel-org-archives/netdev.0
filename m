From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Write only necessary bits in NCR in macb reset
Date: Mon, 28 Nov 2016 10:31:07 +0100
Message-ID: <ddb3f476-928d-e235-3e7e-e78434074b04@atmel.com>
References: <1480325029-39224-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <harinik@xilinx.com>, <michals@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>, <davem@davemloft.net>,
        <harinikatakamlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:49142 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932223AbcK1Jbv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:31:51 -0500
In-Reply-To: <1480325029-39224-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/11/2016 à 10:23, Harini Katakam a écrit :
> In macb_reset_hw, use read-modify-write to disable RX and TX.
> This way exiting settings and reserved bits wont be disturbed.

Yes, indeed... but I would have liked a line about how you discovered it
was an issue for you ;  what did it break, etc...

> Use the same method for clearing statistics as well.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 0e489bb..80ccfc4 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1743,15 +1743,18 @@ static void macb_init_rings(struct macb *bp)
>  static void macb_reset_hw(struct macb *bp)
>  {
>  	struct macb_queue *queue;
> -	unsigned int q;
> +	unsigned int q, ctrl;

I would have preferred a different line with u32 type.


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
