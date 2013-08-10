From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] skge: dma_sync the whole receive buffer
Date: Sat, 10 Aug 2013 15:02:07 -0700
Message-ID: <20130810150207.37432299@nehalam.linuxnetplumber.net>
References: <20130804.183553.514470399074672614.davem@davemloft.net>
	<52062955.90102@gmail.com>
	<20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
	<20130810.132935.1257046025460198490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33824 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758860Ab3HJWCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 18:02:13 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so6190446pab.34
        for <netdev@vger.kernel.org>; Sat, 10 Aug 2013 15:02:12 -0700 (PDT)
In-Reply-To: <20130810.132935.1257046025460198490.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA sync should sync the whole receive buffer, not just
part of it. Fixes log messages dma_sync_check.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/marvell/skge.c	2013-08-10 14:54:13.184737163 -0700
+++ b/drivers/net/ethernet/marvell/skge.c	2013-08-10 14:54:54.908099676 -0700
@@ -3077,11 +3077,13 @@ static struct sk_buff *skge_rx_get(struc
 
 		pci_dma_sync_single_for_cpu(skge->hw->pdev,
 					    dma_unmap_addr(e, mapaddr),
-					    len, PCI_DMA_FROMDEVICE);
+					    dma_unmap_len(e, maplen),
+					    PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(e->skb, skb->data, len);
 		pci_dma_sync_single_for_device(skge->hw->pdev,
 					       dma_unmap_addr(e, mapaddr),
-					       len, PCI_DMA_FROMDEVICE);
+					       dma_unmap_len(e, maplen),
+					       PCI_DMA_FROMDEVICE);
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
 		struct sk_buff *nskb;
