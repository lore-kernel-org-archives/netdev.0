From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815: Fix receiver hangup on Rx FIFO overflow
Date: Fri, 27 Jun 2008 01:33:56 -0400
Message-ID: <48647BC4.90402@garzik.org>
References: <20080626.171415.81099548.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38881 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758457AbYF0FeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:34:03 -0400
In-Reply-To: <20080626.171415.81099548.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> On Rx FIFO overflow error, the controller consume a buffer descriptor
> but currently the driver does not give it back to the controller.
> This results unrecoverable 'Buffer List Exhausted' condition.  This
> patch fix this problem by moving a "fbl_count--" line to proper place.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
> index dccea52..b07b8cb 100644
> --- a/drivers/net/tc35815.c
> +++ b/drivers/net/tc35815.c
> @@ -1736,7 +1736,6 @@ tc35815_rx(struct net_device *dev)
>  			skb = lp->rx_skbs[cur_bd].skb;
>  			prefetch(skb->data);
>  			lp->rx_skbs[cur_bd].skb = NULL;
> -			lp->fbl_count--;
>  			pci_unmap_single(lp->pci_dev,
>  					 lp->rx_skbs[cur_bd].skb_dma,
>  					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
> @@ -1792,6 +1791,7 @@ tc35815_rx(struct net_device *dev)
>  #ifdef TC35815_USE_PACKEDBUFFER
>  			while (lp->fbl_curid != id)
>  #else
> +			lp->fbl_count--;
>  			while (lp->fbl_count < RX_BUF_NUM)
>  #endif
>  			{
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in

applied


