From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/11] skge: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:02 -0800
Message-ID: <20100120204558.969768450@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753765Ab0ATVW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:56 -0500
Content-Disposition: inline; filename=skge-dmar-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2010-01-20 10:10:29.538786102 -0800
+++ b/drivers/net/skge.c	2010-01-20 10:11:18.443974883 -0800
@@ -3078,11 +3078,13 @@ static struct sk_buff *skge_rx_get(struc
 
 		pci_dma_sync_single_for_cpu(skge->hw->pdev,
 					    pci_unmap_addr(e, mapaddr),
-					    len, PCI_DMA_FROMDEVICE);
+					    pci_unmap_len(e, maplen),
+					    PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(e->skb, skb->data, len);
 		pci_dma_sync_single_for_device(skge->hw->pdev,
 					       pci_unmap_addr(e, mapaddr),
-					       len, PCI_DMA_FROMDEVICE);
+					       pci_unmap_len(e, maplen),
+					       PCI_DMA_FROMDEVICE);
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
 		struct sk_buff *nskb;

-- 

