From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] drivers/net/bna: Use kcalloc
Date: Mon, 23 Nov 2009 23:24:12 -0800
Message-ID: <7a4958f646ab4e857757da8f9ba2249b0366bd55.1259047344.git.joe@perches.com>
References: <cover.1259047344.git.joe@perches.com>
Cc: adapter_linux_open_src_team@brocade.com, netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1120 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754250AbZKXHYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 02:24:07 -0500
In-Reply-To: <cover.1259047344.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bna/bnad.c |   45 +++++++++++++++++++--------------------------
 1 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 28df975..edc4a3a 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1186,9 +1186,8 @@ static int bnad_alloc_ibs(struct bnad *bnad)
 	int err;
 
 	bnad->ib_num = bnad->txq_num + bnad->cq_num;
-	bnad->ib_table =
-		kzalloc(bnad->ib_num * sizeof(struct bnad_ib_entry),
-			GFP_KERNEL);
+	bnad->ib_table = kcalloc(bnad->ib_num, sizeof(struct bnad_ib_entry),
+				 GFP_KERNEL);
 	if (!bnad->ib_table)
 		return -ENOMEM;
 
@@ -1250,7 +1249,7 @@ static int bnad_alloc_q(struct bnad *bnad, struct bna_qpt *qpt,
 		return -ENOMEM;
 	BNA_SET_DMA_ADDR(dma_addr, &qpt->hw_qpt_ptr);
 
-	q->qpt_ptr = kzalloc(qpt->page_count * sizeof(void *), GFP_KERNEL);
+	q->qpt_ptr = kcalloc(qpt->page_count, sizeof(void *), GFP_KERNEL);
 	if (!q->qpt_ptr)
 		return -ENOMEM;
 	qpt->qpt_ptr = q->qpt_ptr;
@@ -1386,9 +1385,8 @@ static int bnad_txqs_init(struct bnad *bnad)
 {
 	int i, err = 0;
 
-	bnad->txq_table =
-		kzalloc(bnad->txq_num * sizeof(struct bnad_txq_info),
-			GFP_KERNEL);
+	bnad->txq_table = kcalloc(bnad->txq_num, sizeof(struct bnad_txq_info),
+				  GFP_KERNEL);
 	if (!bnad->txq_table)
 		return -ENOMEM;
 
@@ -1425,9 +1423,8 @@ static int bnad_rxqs_init(struct bnad *bnad)
 {
 	int i, err = 0;
 
-	bnad->rxq_table =
-		kzalloc(bnad->rxq_num * sizeof(struct bnad_rxq_info),
-			GFP_KERNEL);
+	bnad->rxq_table = kcalloc(bnad->rxq_num, sizeof(struct bnad_rxq_info),
+				  GFP_KERNEL);
 	if (!bnad->rxq_table)
 		return -EINVAL;
 
@@ -1470,8 +1467,8 @@ static int bnad_cqs_init(struct bnad *bnad)
 {
 	int i, err = 0;
 
-	bnad->cq_table =
-		kzalloc(bnad->cq_num * sizeof(struct bnad_cq_info), GFP_KERNEL);
+	bnad->cq_table = kcalloc(bnad->cq_num, sizeof(struct bnad_cq_info),
+				 GFP_KERNEL);
 	if (!bnad->cq_table)
 		return -ENOMEM;
 
@@ -1633,16 +1630,14 @@ void bnad_rxf_init(struct bnad *bnad, uint rxf_id, u8 rit_offset, int rss)
 
 static int bnad_init_funcs(struct bnad *bnad)
 {
-	bnad->txf_table =
-		kzalloc(sizeof(struct bnad_txf_info) * bnad->txf_num,
-			GFP_KERNEL);
+	bnad->txf_table = kcalloc(bnad->txf_num, sizeof(struct bnad_txf_info),
+				  GFP_KERNEL);
 	if (!bnad->txf_table)
 		return -ENOMEM;
 	bnad_txf_init(bnad, BNAD_TX_FUNC_ID);
 
-	bnad->rxf_table =
-		kzalloc(sizeof(struct bnad_rxf_info) * bnad->rxf_num,
-			GFP_KERNEL);
+	bnad->rxf_table = kcalloc(bnad->rxf_num, sizeof(struct bnad_rxf_info),
+				  GFP_KERNEL);
 	if (!bnad->rxf_table)
 		return -ENOMEM;
 	bnad_rxf_init(bnad, BNAD_RX_FUNC_ID, BNAD_RIT_OFFSET,
@@ -1866,9 +1861,8 @@ static int bnad_init(struct bnad *bnad)
 	if (err)
 		goto finished;
 
-	bnad->rit =
-		kzalloc(bnad->cq_num * sizeof(struct bna_rit_entry),
-			GFP_KERNEL);
+	bnad->rit = kcalloc(bnad->cq_num, sizeof(struct bna_rit_entry),
+			    GFP_KERNEL);
 	if (!bnad->rit)
 		goto finished;
 
@@ -2421,9 +2415,8 @@ static void bnad_set_rx_mode_locked(struct net_device *netdev)
 		struct dev_mc_list *mc;
 		int i;
 
-		mcaddr_list =
-			kzalloc((netdev->mc_count + 1) * sizeof(struct mac),
-				GFP_ATOMIC);
+		mcaddr_list = kcalloc((netdev->mc_count + 1),
+				      sizeof(struct mac), GFP_ATOMIC);
 		if (!mcaddr_list)
 			return;
 
@@ -2663,8 +2656,8 @@ static void bnad_enable_msix(struct bnad *bnad)
 	if (!(bnad->config & BNAD_CF_MSIX) || bnad->msix_table)
 		return;
 
-	bnad->msix_table =
-		kzalloc(bnad->msix_num * sizeof(struct msix_entry), GFP_KERNEL);
+	bnad->msix_table = kcalloc(bnad->msix_num, sizeof(struct msix_entry),
+				   GFP_KERNEL);
 	if (!bnad->msix_table)
 		goto intx_mode;
 
-- 
1.6.5.2.153.g6e31f

