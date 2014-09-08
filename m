From: Jaroslav Kysela <perex@perex.cz>
Subject: Re: [PATCH net-next] hp100: Convert the normal skb free path to dev_consume_skb_any()
Date: Mon, 08 Sep 2014 21:38:57 +0200
Message-ID: <540E05D1.4000802@perex.cz>
References: <20140908153133.103882900309@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.perex.cz ([77.48.224.245]:41562 "EHLO mail1.perex.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbaIHT7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 15:59:36 -0400
In-Reply-To: <20140908153133.103882900309@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date 8.9.2014 17:31, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> A bit of floor sweeping in a dusty old corner.  Convert the "normal"
> skb free calls to dev_consume_skb_any() so packet drop tracing will
> be more sane.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Acked-by: Jaroslav Kysela <perex@perex.cz>

> 
> ---
> 
> Compile tested only.  I wonder how many of these cards are still in
> operation?-)

It's really old hw..

> 
> diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
> index ed7916f..76a6e0c 100644
> --- a/drivers/net/ethernet/hp/hp100.c
> +++ b/drivers/net/ethernet/hp/hp100.c
> @@ -1627,7 +1627,7 @@ static void hp100_clean_txring(struct net_device *dev)
>  #endif
>  		/* Conversion to new PCI API : NOP */
>  		pci_unmap_single(lp->pci_dev, (dma_addr_t) lp->txrhead->pdl[1], lp->txrhead->pdl[2], PCI_DMA_TODEVICE);
> -		dev_kfree_skb_any(lp->txrhead->skb);
> +		dev_consume_skb_any(lp->txrhead->skb);
>  		lp->txrhead->skb = NULL;
>  		lp->txrhead = lp->txrhead->next;
>  		lp->txrcommit--;
> @@ -1745,7 +1745,7 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
>  	hp100_ints_on();
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> -	dev_kfree_skb_any(skb);
> +	dev_consume_skb_any(skb);
>  
>  #ifdef HP100_DEBUG_TX
>  	printk("hp100: %s: start_xmit: end\n", dev->name);
> 


-- 
Jaroslav Kysela <perex@perex.cz>
Linux Kernel Sound Maintainer
ALSA Project; Red Hat, Inc.
