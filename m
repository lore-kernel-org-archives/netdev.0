From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/11] de2104x: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:05 -0800
Message-ID: <20100120204559.177544514@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623Ab0ATVXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:23:06 -0500
Content-Disposition: inline; filename=de2104x.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/de2104x.c	2010-01-20 11:41:20.878138314 -0800
+++ b/drivers/net/tulip/de2104x.c	2010-01-20 11:41:59.858847380 -0800
@@ -456,11 +456,13 @@ static void de_rx (struct de_private *de
 					       buflen, PCI_DMA_FROMDEVICE);
 			de->rx_skb[rx_tail].skb = copy_skb;
 		} else {
-			pci_dma_sync_single_for_cpu(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_cpu(de->pdev, mapping,
+						    buflen, PCI_DMA_FROMDEVICE);
 			skb_reserve(copy_skb, RX_OFFSET);
 			skb_copy_from_linear_data(skb, skb_put(copy_skb, len),
 						  len);
-			pci_dma_sync_single_for_device(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_device(de->pdev, mapping,
+						       buflen, PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
 			skb = copy_skb;

-- 

