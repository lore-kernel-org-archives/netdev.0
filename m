From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] 3c59x: sparse warning fix
Date: Thu, 13 Sep 2007 08:38:04 +0200
Message-ID: <20070913063804.GA29559@newton.mathematik.tu-chemnitz.de>
References: <20070905152359.26215f89@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:57011 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXIMGiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 02:38:08 -0400
Content-Disposition: inline
In-Reply-To: <20070905152359.26215f89@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 05, 2007 at 03:23:59PM +0100, Stephen Hemminger wrote:
> --- a/drivers/net/3c59x.c	2007-09-05 15:15:16.000000000 +0100
> +++ b/drivers/net/3c59x.c	2007-09-05 15:16:29.000000000 +0100
> @@ -1122,7 +1122,7 @@ static int __devinit vortex_probe1(struc
>  					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>  					   &vp->rx_ring_dma);
>  	retval = -ENOMEM;
> -	if (vp->rx_ring == 0)
> +	if (!vp->rx_ring)
>  		goto free_region;
>  
>  	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
> @@ -2476,7 +2476,8 @@ boomerang_rx(struct net_device *dev)
>  
>  			/* Check if the packet is long enough to just accept without
>  			   copying to a properly sized skbuff. */
> -			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != 0) {
> +			if (pkt_len < rx_copybreak &&
> +			    (skb = dev_alloc_skb(pkt_len + 2)) ) {
>  				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
>  				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
>  				/* 'skb_put()' points to the start of sk_buff data area. */
> -

Thanks,

Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
