From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] cirrus: Remove redundant NULL check before kfree
Date: Wed, 27 Feb 2013 01:19:33 +0530
Message-ID: <1361908173-3157-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, hsweeten@visionengravers.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:41712 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759905Ab3BZTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:49:51 -0500
Received: by mail-da0-f51.google.com with SMTP id n15so2178028dad.10
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:49:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 354cbb7..298aaa9 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -476,8 +476,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 		if (d)
 			dma_unmap_single(dev, d, PKT_BUF_SIZE, DMA_FROM_DEVICE);
 
-		if (ep->rx_buf[i] != NULL)
-			kfree(ep->rx_buf[i]);
+		kfree(ep->rx_buf[i]);
 	}
 
 	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
@@ -487,8 +486,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 		if (d)
 			dma_unmap_single(dev, d, PKT_BUF_SIZE, DMA_TO_DEVICE);
 
-		if (ep->tx_buf[i] != NULL)
-			kfree(ep->tx_buf[i]);
+		kfree(ep->tx_buf[i]);
 	}
 
 	dma_free_coherent(dev, sizeof(struct ep93xx_descs), ep->descs,
-- 
1.7.9.5
