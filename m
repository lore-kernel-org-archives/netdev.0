From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/11] cassini: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:08 -0800
Message-ID: <20100120204559.381373073@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab0ATVW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:57 -0500
Content-Disposition: inline; filename=cassini.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/cassini.c	2010-01-20 11:54:22.608138316 -0800
+++ b/drivers/net/cassini.c	2010-01-20 11:55:56.108761882 -0800
@@ -2027,12 +2027,12 @@ static int cas_rx_process_pkt(struct cas
 		i = hlen;
 		if (!dlen) /* attach FCS */
 			i += cp->crc_size;
-		pci_dma_sync_single_for_cpu(cp->pdev, page->dma_addr + off, i,
-				    PCI_DMA_FROMDEVICE);
+		pci_dma_sync_single_for_cpu(cp->pdev, page->dma_addr,
+					    cp->page_size, PCI_DMA_FROMDEVICE);
 		addr = cas_page_map(page->buffer);
 		memcpy(p, addr + off, i);
-		pci_dma_sync_single_for_device(cp->pdev, page->dma_addr + off, i,
-				    PCI_DMA_FROMDEVICE);
+		pci_dma_sync_single_for_device(cp->pdev, page->dma_addr,
+					       cp->page_size, PCI_DMA_FROMDEVICE);
 		cas_page_unmap(addr);
 		RX_USED_ADD(page, 0x100);
 		p += hlen;

-- 

