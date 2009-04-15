From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 04/12] fec: remove unnecessary cast
Date: Wed, 15 Apr 2009 13:32:17 +0200
Message-ID: <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37945 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbZDOLfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:35:13 -0400
In-Reply-To: <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index fea8e27..3a43d96 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1661,11 +1661,10 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	struct bufdesc *bdp, *cbd_base;
 	int 		i, j;
 
-	/* Allocate memory for buffer descriptors.
-	*/
-	mem_addr = (unsigned long)dma_alloc_coherent(NULL, PAGE_SIZE,
-			&fep->bd_dma, GFP_KERNEL);
-	if (mem_addr == 0) {
+	/* Allocate memory for buffer descriptors. */
+	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
+			GFP_KERNEL);
+	if (!cbd_base) {
 		printk("FEC: allocate descriptor memory failed?\n");
 		return -ENOMEM;
 	}
@@ -1699,10 +1698,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	}
 #endif
 
-	cbd_base = (struct bufdesc *)mem_addr;
-
-	/* Set receive and transmit descriptor base.
-	*/
+	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base = cbd_base;
 	fep->tx_bd_base = cbd_base + RX_RING_SIZE;
 
-- 
1.6.2.1

