From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 05/11] ksz884x: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:29 -0700
Message-ID: <1341878975-10577-5-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab2GJAJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:24 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:23 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set during ring init.  It is already being set
to the proper value when eth_type_trans is called on packet receive, and the
skb->dev is not referenced anywhere else in the code.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/micrel/ksz884x.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index eaf9ff0..2b59e39 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4480,14 +4480,12 @@ static void ksz_init_rx_buffers(struct dev_info *adapter)
 		dma_buf->len = adapter->mtu;
 		if (!dma_buf->skb)
 			dma_buf->skb = alloc_skb(dma_buf->len, GFP_ATOMIC);
-		if (dma_buf->skb && !dma_buf->dma) {
-			dma_buf->skb->dev = adapter->dev;
+		if (dma_buf->skb && !dma_buf->dma)
 			dma_buf->dma = pci_map_single(
 				adapter->pdev,
 				skb_tail_pointer(dma_buf->skb),
 				dma_buf->len,
 				PCI_DMA_FROMDEVICE);
-		}
 
 		/* Set descriptor. */
 		set_rx_buf(desc, dma_buf->dma);
-- 
1.7.9.5
