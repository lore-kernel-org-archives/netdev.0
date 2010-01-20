From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/11] sungem: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:06 -0800
Message-ID: <20100120204559.246153541@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab0ATVW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:56 -0500
Content-Disposition: inline; filename=sungem.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sungem.c	2010-01-20 11:43:58.779387706 -0800
+++ b/drivers/net/sungem.c	2010-01-20 11:52:50.398529616 -0800
@@ -847,9 +847,13 @@ static int gem_rx(struct gem *gp, int wo
 
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
-			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr,
+						    RX_BUF_ALLOC_SIZE(gp),
+						    PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
-			pci_dma_sync_single_for_device(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_device(gp->pdev, dma_addr,
+						       RX_BUF_ALLOC_SIZE(gp),
+						       PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
 			skb = copy_skb;

-- 

