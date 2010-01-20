From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/11] sunhme: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:07 -0800
Message-ID: <20100120204559.315199780@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835Ab0ATVW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:57 -0500
Content-Disposition: inline; filename=sunhme.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sunhme.c	2010-01-20 11:51:53.579700152 -0800
+++ b/drivers/net/sunhme.c	2010-01-20 11:53:10.408138348 -0800
@@ -2062,9 +2062,11 @@ static void happy_meal_rx(struct happy_m
 
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
-			dma_sync_single_for_cpu(hp->dma_dev, dma_addr, len, DMA_FROM_DEVICE);
+			dma_sync_single_for_cpu(hp->dma_dev, dma_addr,
+						RX_BUF_ALLOC_SIZE, DMA_FROM_DEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
-			dma_sync_single_for_device(hp->dma_dev, dma_addr, len, DMA_FROM_DEVICE);
+			dma_sync_single_for_device(hp->dma_dev, dma_addr,
+						   RX_BUF_ALLOC_SIZE, DMA_FROM_DEVICE);
 			/* Reuse original ring buffer. */
 			hme_write_rxd(hp, this,
 				      (RXFLAG_OWN|((RX_BUF_ALLOC_SIZE-RX_OFFSET)<<16)),

-- 

