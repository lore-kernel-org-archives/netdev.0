From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 06/11] de2104x: fix DMA sync_single length error
Date: Thu, 21 Jan 2010 18:02:44 -0700
Message-ID: <20100122010244.GA27529@lackof.org>
References: <20100120204459.820265084@vyatta.com> <20100120204559.177544514@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:60379 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab0AVBCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 20:02:45 -0500
Content-Disposition: inline
In-Reply-To: <20100120204559.177544514@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 12:45:05PM -0800, Stephen Hemminger wrote:
> The DMA api requires that the full mapping be sync'd when
> copying frame. First found by Jarek on sky2.

Are you referring to the example code in Documentation/PCI/PCI-DMA-mapping.txt?

I don't see any "Use the full mapping" statement otherwise.

Is there a DMA HW implementation that requires the syncing full buffer?

I think it would be interesting to point that out in the commit comments
since other NIC drivers are likely to also have this issue as well.

I have no objection to this patch. Just want to be clear why
it's being pushed.

Please added Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant


> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/tulip/de2104x.c	2010-01-20 11:41:20.878138314 -0800
> +++ b/drivers/net/tulip/de2104x.c	2010-01-20 11:41:59.858847380 -0800
> @@ -456,11 +456,13 @@ static void de_rx (struct de_private *de
>  					       buflen, PCI_DMA_FROMDEVICE);
>  			de->rx_skb[rx_tail].skb = copy_skb;
>  		} else {
> -			pci_dma_sync_single_for_cpu(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
> +			pci_dma_sync_single_for_cpu(de->pdev, mapping,
> +						    buflen, PCI_DMA_FROMDEVICE);
>  			skb_reserve(copy_skb, RX_OFFSET);
>  			skb_copy_from_linear_data(skb, skb_put(copy_skb, len),
>  						  len);
> -			pci_dma_sync_single_for_device(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
> +			pci_dma_sync_single_for_device(de->pdev, mapping,
> +						       buflen, PCI_DMA_FROMDEVICE);
>  
>  			/* We'll reuse the original ring buffer. */
>  			skb = copy_skb;
> 
> -- 
