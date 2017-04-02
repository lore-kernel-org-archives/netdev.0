From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 03/13] ftgmac100: Reorder struct fields and comment
Date: Sun,  2 Apr 2017 13:35:13 +1000
Message-ID: <20170402033523.9482-4-benh@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48942 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdDBDfo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 23:35:44 -0400
In-Reply-To: <20170402033523.9482-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder the fields in struct ftgmac in slightly more logical
groups. Will make more sense as I add/remove some.

No code change.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 6501aa7..02e0534 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -50,34 +50,39 @@ struct ftgmac100_descs {
 };
 
 struct ftgmac100 {
+	/* Registers */
 	struct resource *res;
 	void __iomem *base;
 
 	struct ftgmac100_descs *descs;
 	dma_addr_t descs_dma_addr;
 
+	/* Rx ring */
 	struct page *rx_pages[RX_QUEUE_ENTRIES];
-
 	unsigned int rx_pointer;
+	u32 rxdes0_edorr_mask;
+
+	/* Tx ring */
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
 	unsigned int tx_pending;
-
+	u32 txdes0_edotr_mask;
 	spinlock_t tx_lock;
 
+	/* Component structures */
 	struct net_device *netdev;
 	struct device *dev;
 	struct ncsi_dev *ndev;
 	struct napi_struct napi;
-
 	struct mii_bus *mii_bus;
+
+	/* Link management */
 	int old_speed;
-	int int_mask_all;
 	bool use_ncsi;
-	bool enabled;
 
-	u32 rxdes0_edorr_mask;
-	u32 txdes0_edotr_mask;
+	/* Misc */
+	int int_mask_all;
+	bool enabled;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-- 
2.9.3
