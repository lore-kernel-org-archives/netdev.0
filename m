From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] skge: fix broken driver
Date: Thu, 19 Sep 2013 14:15:42 -0400 (EDT)
Message-ID: <20130919.141542.1144278748310267289.davem@davemloft.net>
References: <alpine.LRH.2.02.1309191409301.12162@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vascom2@gmail.com
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab3ISSPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:15:44 -0400
In-Reply-To: <alpine.LRH.2.02.1309191409301.12162@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 19 Sep 2013 14:13:17 -0400 (EDT)

> The patch 136d8f377e1575463b47840bc5f1b22d94bf8f63 broke the skge driver.
> Note this part of the patch:
> +               if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
> +                       dev_kfree_skb(nskb);
> +                       goto resubmit;
> +               }
> +
>                 pci_unmap_single(skge->hw->pdev,
>                                  dma_unmap_addr(e, mapaddr),
>                                  dma_unmap_len(e, maplen),
>                                  PCI_DMA_FROMDEVICE);
>                 skb = e->skb;
>                 prefetch(skb->data);
> -               skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
> 
> The function skge_rx_setup modifies e->skb to point to the new skb. Thus,
> after this change, the new buffer, not the old, is returned to the
> networking stack.
> 
> This bug is present in kernels 3.11, 3.11.1 and 3.12-rc1. The patch should 
> be queued for 3.11-stable.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Vasiliy Glazov <vascom2@gmail.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>

Applied and queued up for -stable, thanks.
