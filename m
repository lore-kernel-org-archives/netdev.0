From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fix memory corruption in fec_mpc52xx
Date: Tue, 04 Dec 2007 14:54:17 -0500
Message-ID: <4755B069.3050901@pobox.com>
References: <1196721490.13978.185.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Domen Puncer <domen.puncer@telargo.com>,
	Jon Smirl <jonsmirl@gmail.com>,
	Grant Likely <grant.likely@secretlab.ca>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbXLDTyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 14:54:19 -0500
In-Reply-To: <1196721490.13978.185.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> From: Jon Smirl <jonsmirl@gmail.com>
> 
> The mpc5200 fec driver is corrupting memory. This patch fixes two bugs
> where the wrong skb was being referenced.
> 
> Signed-off-by: Jon Smirl <jonsmirl@gmail.com>
> Acked-by: Domen Puncer <domen.puncer@telargo.com>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -422,7 +422,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
> 
>  		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
>  				(struct bcom_bd **)&bd);
> -		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
> +		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE);
> 
>  		/* Test for errors in received frame */
>  		if (status & BCOM_FEC_RX_BD_ERRORS) {
> @@ -467,7 +467,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
>  			bcom_prepare_next_buffer(priv->rx_dmatsk);
> 
>  		bd->status = FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
> +		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
>  				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> 

applied #upstream-fixes


