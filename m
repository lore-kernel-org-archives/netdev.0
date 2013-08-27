From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers:net: Convert
 dma_alloc_coherent(...__GFP_ZERO) to dma_zalloc_coherent
Date: Mon, 26 Aug 2013 22:45:23 -0700
Message-ID: <1377582323.2658.10.camel@joe-AO722>
References: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	users@rt2x00.serialmonkey.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__GFP_ZERO is an uncommon flag and perhaps is better
not used.  static inline dma_zalloc_coherent exists
so convert the uses of dma_alloc_coherent with __GFP_ZERO
to the more common kernel style with zalloc.

Remove memset from the static inline dma_zalloc_coherent
and add just one use of __GFP_ZERO instead.

Trivially reduces the size of the existing uses of
dma_zalloc_coherent.

Realign arguments as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/aeroflex/greth.c              | 12 ++++-----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  6 ++---
 drivers/net/ethernet/broadcom/bnx2.c               |  5 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  5 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  3 +--
 drivers/net/ethernet/broadcom/tg3.c                | 23 ++++++++---------
 drivers/net/ethernet/emulex/benet/be_main.c        | 18 +++++++-------
 drivers/net/ethernet/faraday/ftgmac100.c           |  7 +++---
 drivers/net/ethernet/faraday/ftmac100.c            |  8 +++---
 drivers/net/ethernet/ibm/emac/mal.c                |  4 +--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |  8 +++---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  4 +--
 drivers/net/ethernet/marvell/pxa168_eth.c          | 19 +++++++-------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  6 ++---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 16 ++++++------
 drivers/net/ethernet/pasemi/pasemi_mac.c           |  7 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 29 +++++++++++-----------
 drivers/net/ethernet/sfc/nic.c                     |  5 ++--
 drivers/net/ethernet/sgi/meth.c                    |  5 ++--
 drivers/net/ethernet/tundra/tsi108_eth.c           |  8 +++---
 drivers/net/ethernet/xilinx/ll_temac_main.c        | 12 ++++-----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  | 14 +++++------
 drivers/net/fddi/defxx.c                           |  6 ++---
 drivers/net/irda/ali-ircc.c                        |  8 +++---
 drivers/net/irda/nsc-ircc.c                        |  8 +++---
 drivers/net/irda/smsc-ircc2.c                      |  8 +++---
 drivers/net/irda/via-ircc.c                        |  8 +++---
 drivers/net/irda/w83977af_ir.c                     |  8 +++---
 drivers/net/wireless/b43/dma.c                     |  6 ++---
 drivers/net/wireless/b43legacy/dma.c               |  7 +++---
 include/linux/dma-mapping.h                        |  5 ++--
 31 files changed, 135 insertions(+), 153 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 7ff4b30..e066945 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1464,18 +1464,18 @@ static int greth_of_probe(struct platform_device *ofdev)
 	}
 
 	/* Allocate TX descriptor ring in coherent memory */
-	greth->tx_bd_base = dma_alloc_coherent(greth->dev, 1024,
-					       &greth->tx_bd_base_phys,
-					       GFP_KERNEL | __GFP_ZERO);
+	greth->tx_bd_base = dma_zalloc_coherent(greth->dev, 1024,
+						&greth->tx_bd_base_phys,
+						GFP_KERNEL);
 	if (!greth->tx_bd_base) {
 		err = -ENOMEM;
 		goto error3;
 	}
 
 	/* Allocate RX descriptor ring in coherent memory */
-	greth->rx_bd_base = dma_alloc_coherent(greth->dev, 1024,
-					       &greth->rx_bd_base_phys,
-					       GFP_KERNEL | __GFP_ZERO);
+	greth->rx_bd_base = dma_zalloc_coherent(greth->dev, 1024,
+						&greth->rx_bd_base_phys,
+						GFP_KERNEL);
 	if (!greth->rx_bd_base) {
 		err = -ENOMEM;
 		goto error4;
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 190219e..98b6870 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -948,8 +948,7 @@ static int bcm_enet_open(struct net_device *dev)
 
 	/* allocate rx dma ring */
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma,
-			       GFP_KERNEL | __GFP_ZERO);
+	p = dma_zalloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out_freeirq_tx;
@@ -960,8 +959,7 @@ static int bcm_enet_open(struct net_device *dev)
 
 	/* allocate tx dma ring */
 	size = priv->tx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma,
-			       GFP_KERNEL | __GFP_ZERO);
+	p = dma_zalloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out_free_rx_ring;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 4148058..e838a3f 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -853,9 +853,8 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bp->status_stats_size = status_blk_size +
 				sizeof(struct statistics_block);
 
-	status_blk = dma_alloc_coherent(&bp->pdev->dev, bp->status_stats_size,
-					&bp->status_blk_mapping,
-					GFP_KERNEL | __GFP_ZERO);
+	status_blk = dma_zalloc_coherent(&bp->pdev->dev, bp->status_stats_size,
+					 &bp->status_blk_mapping, GFP_KERNEL);
 	if (status_blk == NULL)
 		goto alloc_mem_err;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 12202f8..3e77a1b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2069,9 +2069,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 			    bool is_pf);
 
-#define BNX2X_ILT_ZALLOC(x, y, size)				\
-	x = dma_alloc_coherent(&bp->pdev->dev, size, y,		\
-			       GFP_KERNEL | __GFP_ZERO)
+#define BNX2X_ILT_ZALLOC(x, y, size)					\
+	x = dma_zalloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL)
 
 #define BNX2X_ILT_FREE(x, y, size) \
 	do { \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 38be494..affb764 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -51,8 +51,7 @@ extern int int_mode;
 
 #define BNX2X_PCI_ALLOC(x, y, size) \
 	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, \
-				       GFP_KERNEL | __GFP_ZERO); \
+		x = dma_zalloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
 		if (x == NULL) \
 			goto alloc_mem_err; \
 		DP(NETIF_MSG_HW, "BNX2X_PCI_ALLOC: Physical %Lx Virtual %p\n", \
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 95b8995..2e55ee2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8591,10 +8591,10 @@ static int tg3_mem_rx_acquire(struct tg3 *tp)
 		if (!i && tg3_flag(tp, ENABLE_RSS))
 			continue;
 
-		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
-						   TG3_RX_RCB_RING_BYTES(tp),
-						   &tnapi->rx_rcb_mapping,
-						   GFP_KERNEL | __GFP_ZERO);
+		tnapi->rx_rcb = dma_zalloc_coherent(&tp->pdev->dev,
+						    TG3_RX_RCB_RING_BYTES(tp),
+						    &tnapi->rx_rcb_mapping,
+						    GFP_KERNEL);
 		if (!tnapi->rx_rcb)
 			goto err_out;
 	}
@@ -8643,10 +8643,9 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 {
 	int i;
 
-	tp->hw_stats = dma_alloc_coherent(&tp->pdev->dev,
-					  sizeof(struct tg3_hw_stats),
-					  &tp->stats_mapping,
-					  GFP_KERNEL | __GFP_ZERO);
+	tp->hw_stats = dma_zalloc_coherent(&tp->pdev->dev,
+					   sizeof(struct tg3_hw_stats),
+					   &tp->stats_mapping, GFP_KERNEL);
 	if (!tp->hw_stats)
 		goto err_out;
 
@@ -8654,10 +8653,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		struct tg3_napi *tnapi = &tp->napi[i];
 		struct tg3_hw_status *sblk;
 
-		tnapi->hw_status = dma_alloc_coherent(&tp->pdev->dev,
-						      TG3_HW_STATUS_SIZE,
-						      &tnapi->status_mapping,
-						      GFP_KERNEL | __GFP_ZERO);
+		tnapi->hw_status = dma_zalloc_coherent(&tp->pdev->dev,
+						       TG3_HW_STATUS_SIZE,
+						       &tnapi->status_mapping,
+						       GFP_KERNEL);
 		if (!tnapi->hw_status)
 			goto err_out;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 08f6417..ecefc8b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -145,8 +145,8 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	q->len = len;
 	q->entry_size = entry_size;
 	mem->size = len * entry_size;
-	mem->va = dma_alloc_coherent(&adapter->pdev->dev, mem->size, &mem->dma,
-				     GFP_KERNEL | __GFP_ZERO);
+	mem->va = dma_zalloc_coherent(&adapter->pdev->dev, mem->size, &mem->dma,
+				      GFP_KERNEL);
 	if (!mem->va)
 		return -ENOMEM;
 	return 0;
@@ -2683,8 +2683,8 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	memset(mac, 0, ETH_ALEN);
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
-	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
-				    GFP_KERNEL | __GFP_ZERO);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_KERNEL);
 	if (cmd.va == NULL)
 		return -1;
 
@@ -3889,9 +3889,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
 
 	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
-	rx_filter->va = dma_alloc_coherent(&adapter->pdev->dev, rx_filter->size,
-					   &rx_filter->dma,
-					   GFP_KERNEL | __GFP_ZERO);
+	rx_filter->va = dma_zalloc_coherent(&adapter->pdev->dev,
+					    rx_filter->size, &rx_filter->dma,
+					    GFP_KERNEL);
 	if (rx_filter->va == NULL) {
 		status = -ENOMEM;
 		goto free_mbox;
@@ -3937,8 +3937,8 @@ static int be_stats_init(struct be_adapter *adapter)
 		/* BE3 and Skyhawk */
 		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
 
-	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
-				     GFP_KERNEL | __GFP_ZERO);
+	cmd->va = dma_zalloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
+				      GFP_KERNEL);
 	if (cmd->va == NULL)
 		return -1;
 	return 0;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 934e1ae..212f44b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -778,10 +778,9 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 {
 	int i;
 
-	priv->descs = dma_alloc_coherent(priv->dev,
-					 sizeof(struct ftgmac100_descs),
-					 &priv->descs_dma_addr,
-					 GFP_KERNEL | __GFP_ZERO);
+	priv->descs = dma_zalloc_coherent(priv->dev,
+					  sizeof(struct ftgmac100_descs),
+					  &priv->descs_dma_addr, GFP_KERNEL);
 	if (!priv->descs)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 4658f4c..8be5b40 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -732,10 +732,10 @@ static int ftmac100_alloc_buffers(struct ftmac100 *priv)
 {
 	int i;
 
-	priv->descs = dma_alloc_coherent(priv->dev,
-					 sizeof(struct ftmac100_descs),
-					 &priv->descs_dma_addr,
-					 GFP_KERNEL | __GFP_ZERO);
+	priv->descs = dma_zalloc_coherent(priv->dev,
+					  sizeof(struct ftmac100_descs),
+					  &priv->descs_dma_addr,
+					  GFP_KERNEL);
 	if (!priv->descs)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 856ea66..dac564c 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -637,8 +637,8 @@ static int mal_probe(struct platform_device *ofdev)
 	bd_size = sizeof(struct mal_descriptor) *
 		(NUM_TX_BUFF * mal->num_tx_chans +
 		 NUM_RX_BUFF * mal->num_rx_chans);
-	mal->bd_virt = dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
-					  GFP_KERNEL | __GFP_ZERO);
+	mal->bd_virt = dma_zalloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
+					   GFP_KERNEL);
 	if (mal->bd_virt == NULL) {
 		err = -ENOMEM;
 		goto fail_unmap;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 82a967c..73a8aee 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1019,8 +1019,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
-	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL | __GFP_ZERO);
+	txdr->desc = dma_zalloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
+					 GFP_KERNEL);
 	if (!txdr->desc) {
 		ret_val = 2;
 		goto err_nomem;
@@ -1077,8 +1077,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	}
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
-	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
-					GFP_KERNEL | __GFP_ZERO);
+	rxdr->desc = dma_zalloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
+					 GFP_KERNEL);
 	if (!rxdr->desc) {
 		ret_val = 6;
 		goto err_nomem;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index fce3e92..9f6b236 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -718,8 +718,8 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->size = txdr->count * sizeof(struct ixgb_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
 
-	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL | __GFP_ZERO);
+	txdr->desc = dma_zalloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
+					 GFP_KERNEL);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index db48147..3e69feb 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -583,10 +583,9 @@ static int init_hash_table(struct pxa168_eth_private *pep)
 	 * table is full.
 	 */
 	if (pep->htpr == NULL) {
-		pep->htpr = dma_alloc_coherent(pep->dev->dev.parent,
-					       HASH_ADDR_TABLE_SIZE,
-					       &pep->htpr_dma,
-					       GFP_KERNEL | __GFP_ZERO);
+		pep->htpr = dma_zalloc_coherent(pep->dev->dev.parent,
+						HASH_ADDR_TABLE_SIZE,
+						&pep->htpr_dma, GFP_KERNEL);
 		if (pep->htpr == NULL)
 			return -ENOMEM;
 	} else {
@@ -1024,9 +1023,9 @@ static int rxq_init(struct net_device *dev)
 	pep->rx_desc_count = 0;
 	size = pep->rx_ring_size * sizeof(struct rx_desc);
 	pep->rx_desc_area_size = size;
-	pep->p_rx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						 &pep->rx_desc_dma,
-						 GFP_KERNEL | __GFP_ZERO);
+	pep->p_rx_desc_area = dma_zalloc_coherent(pep->dev->dev.parent, size,
+						  &pep->rx_desc_dma,
+						  GFP_KERNEL);
 	if (!pep->p_rx_desc_area)
 		goto out;
 
@@ -1085,9 +1084,9 @@ static int txq_init(struct net_device *dev)
 	pep->tx_desc_count = 0;
 	size = pep->tx_ring_size * sizeof(struct tx_desc);
 	pep->tx_desc_area_size = size;
-	pep->p_tx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						 &pep->tx_desc_dma,
-						 GFP_KERNEL | __GFP_ZERO);
+	pep->p_tx_desc_area = dma_zalloc_coherent(pep->dev->dev.parent, size,
+						  &pep->tx_desc_dma,
+						  GFP_KERNEL);
 	if (!pep->p_tx_desc_area)
 		goto out;
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 50a1d4a..149355b 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3783,9 +3783,9 @@ static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
 	for (i = 0; i < mgp->num_slices; i++) {
 		ss = &mgp->ss[i];
 		bytes = mgp->max_intr_slots * sizeof(*ss->rx_done.entry);
-		ss->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
-						       &ss->rx_done.bus,
-						       GFP_KERNEL | __GFP_ZERO);
+		ss->rx_done.entry = dma_zalloc_coherent(&pdev->dev, bytes,
+							&ss->rx_done.bus,
+							GFP_KERNEL);
 		if (ss->rx_done.entry == NULL)
 			goto abort;
 		bytes = sizeof(*ss->fw_stats);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index e19f1be..5a0f04c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1491,9 +1491,9 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 	bufsz = adapter->rx_buffer_len;
 
 	size = rx_ring->count * bufsz + PCH_GBE_RESERVE_MEMORY;
-	rx_ring->rx_buff_pool = dma_alloc_coherent(&pdev->dev, size,
-						   &rx_ring->rx_buff_pool_logic,
-						   GFP_KERNEL | __GFP_ZERO);
+	rx_ring->rx_buff_pool =
+		dma_zalloc_coherent(&pdev->dev, size,
+				    &rx_ring->rx_buff_pool_logic, GFP_KERNEL);
 	if (!rx_ring->rx_buff_pool)
 		return -ENOMEM;
 
@@ -1807,9 +1807,8 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
-	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
-					   &tx_ring->dma,
-					   GFP_KERNEL | __GFP_ZERO);
+	tx_ring->desc = dma_zalloc_coherent(&pdev->dev, tx_ring->size,
+					    &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc) {
 		vfree(tx_ring->buffer_info);
 		return -ENOMEM;
@@ -1852,9 +1851,8 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 		return -ENOMEM;
 
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
-	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
-					   &rx_ring->dma,
-					   GFP_KERNEL | __GFP_ZERO);
+	rx_ring->desc =	dma_zalloc_coherent(&pdev->dev, rx_ring->size,
+					    &rx_ring->dma, GFP_KERNEL);
 	if (!rx_ring->desc) {
 		vfree(rx_ring->buffer_info);
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index f21ae7b..c498181 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -440,10 +440,9 @@ static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 	if (pasemi_dma_alloc_ring(&ring->chan, RX_RING_SIZE))
 		goto out_ring_desc;
 
-	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
-					   RX_RING_SIZE * sizeof(u64),
-					   &ring->buf_dma,
-					   GFP_KERNEL | __GFP_ZERO);
+	ring->buffers = dma_zalloc_coherent(&mac->dma_pdev->dev,
+					    RX_RING_SIZE * sizeof(u64),
+					    &ring->buf_dma, GFP_KERNEL);
 	if (!ring->buffers)
 		goto out_ring_desc;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index d4f0e95..55d38e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -446,14 +446,14 @@ int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
 	*(tx_ring->hw_consumer) = 0;
 
 	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
-	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
-				     &rq_phys_addr, GFP_KERNEL | __GFP_ZERO);
+	rq_addr = dma_zalloc_coherent(&adapter->pdev->dev, rq_size,
+				      &rq_phys_addr, GFP_KERNEL);
 	if (!rq_addr)
 		return -ENOMEM;
 
 	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
-	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
-				      &rsp_phys_addr, GFP_KERNEL | __GFP_ZERO);
+	rsp_addr = dma_zalloc_coherent(&adapter->pdev->dev, rsp_size,
+				       &rsp_phys_addr, GFP_KERNEL);
 	if (!rsp_addr) {
 		err = -ENOMEM;
 		goto out_free_rq;
@@ -863,8 +863,8 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 	struct qlcnic_cmd_args cmd;
 	size_t  nic_size = sizeof(struct qlcnic_info_le);
 
-	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
+	nic_info_addr = dma_zalloc_coherent(&adapter->pdev->dev, nic_size,
+					    &nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
@@ -917,8 +917,8 @@ int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 
-	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
+	nic_info_addr = dma_zalloc_coherent(&adapter->pdev->dev, nic_size,
+					    &nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
@@ -970,9 +970,8 @@ int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
 	size_t npar_size = sizeof(struct qlcnic_pci_info_le);
 	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
 
-	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
-					   &pci_info_dma_t,
-					   GFP_KERNEL | __GFP_ZERO);
+	pci_info_addr = dma_zalloc_coherent(&adapter->pdev->dev, pci_size,
+					    &pci_info_dma_t, GFP_KERNEL);
 	if (!pci_info_addr)
 		return -ENOMEM;
 
@@ -1072,8 +1071,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		return -EIO;
 	}
 
-	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
+	stats_addr = dma_zalloc_coherent(&adapter->pdev->dev, stats_size,
+					 &stats_dma_t, GFP_KERNEL);
 	if (!stats_addr)
 		return -ENOMEM;
 
@@ -1128,8 +1127,8 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 	if (mac_stats == NULL)
 		return -ENOMEM;
 
-	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
+	stats_addr = dma_zalloc_coherent(&adapter->pdev->dev, stats_size,
+					 &stats_dma_t, GFP_KERNEL);
 	if (!stats_addr)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 56ed3bc..acf84fa 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -305,9 +305,8 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len)
 {
-	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
-					  &buffer->dma_addr,
-					  GFP_ATOMIC | __GFP_ZERO);
+	buffer->addr = dma_zalloc_coherent(&efx->pci_dev->dev, len,
+					   &buffer->dma_addr, GFP_ATOMIC);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 9f5f35e..770036b 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -212,9 +212,8 @@ static void meth_check_link(struct net_device *dev)
 static int meth_init_tx_ring(struct meth_private *priv)
 {
 	/* Init TX ring */
-	priv->tx_ring = dma_alloc_coherent(NULL, TX_RING_BUFFER_SIZE,
-	                                   &priv->tx_ring_dma,
-					   GFP_ATOMIC | __GFP_ZERO);
+	priv->tx_ring = dma_zalloc_coherent(NULL, TX_RING_BUFFER_SIZE,
+					    &priv->tx_ring_dma, GFP_ATOMIC);
 	if (!priv->tx_ring)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 01bdc6c..f2e76c9 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1308,13 +1308,13 @@ static int tsi108_open(struct net_device *dev)
 		       data->id, dev->irq, dev->name);
 	}
 
-	data->rxring = dma_alloc_coherent(NULL, rxring_size, &data->rxdma,
-					  GFP_KERNEL | __GFP_ZERO);
+	data->rxring = dma_zalloc_coherent(NULL, rxring_size, &data->rxdma,
+					   GFP_KERNEL);
 	if (!data->rxring)
 		return -ENOMEM;
 
-	data->txring = dma_alloc_coherent(NULL, txring_size, &data->txdma,
-					  GFP_KERNEL | __GFP_ZERO);
+	data->txring = dma_zalloc_coherent(NULL, txring_size, &data->txdma,
+					   GFP_KERNEL);
 	if (!data->txring) {
 		pci_free_consistent(0, rxring_size, data->rxring, data->rxdma);
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 58eb448..b88121f 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -243,15 +243,15 @@ static int temac_dma_bd_init(struct net_device *ndev)
 
 	/* allocate the tx and rx ring buffer descriptors. */
 	/* returns a virtual address and a physical address. */
-	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
-					 &lp->tx_bd_p, GFP_KERNEL | __GFP_ZERO);
+	lp->tx_bd_v = dma_zalloc_coherent(ndev->dev.parent,
+					  sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+					  &lp->tx_bd_p, GFP_KERNEL);
 	if (!lp->tx_bd_v)
 		goto out;
 
-	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
-					 &lp->rx_bd_p, GFP_KERNEL | __GFP_ZERO);
+	lp->rx_bd_v = dma_zalloc_coherent(ndev->dev.parent,
+					  sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+					  &lp->rx_bd_p, GFP_KERNEL);
 	if (!lp->rx_bd_v)
 		goto out;
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index fb7d1c2..b2ff038 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -201,17 +201,15 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 	/*
 	 * Allocate the Tx and Rx buffer descriptors.
 	 */
-	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
-					 &lp->tx_bd_p,
-					 GFP_KERNEL | __GFP_ZERO);
+	lp->tx_bd_v = dma_zalloc_coherent(ndev->dev.parent,
+					  sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+					  &lp->tx_bd_p, GFP_KERNEL);
 	if (!lp->tx_bd_v)
 		goto out;
 
-	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
-					 &lp->rx_bd_p,
-					 GFP_KERNEL | __GFP_ZERO);
+	lp->rx_bd_v = dma_zalloc_coherent(ndev->dev.parent,
+					  sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+					  &lp->rx_bd_p, GFP_KERNEL);
 	if (!lp->rx_bd_v)
 		goto out;
 
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 4c8ddc9..0b40e1c 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -1068,9 +1068,9 @@ static int dfx_driver_init(struct net_device *dev, const char *print_name,
 #endif
 					sizeof(PI_CONSUMER_BLOCK) +
 					(PI_ALIGN_K_DESC_BLK - 1);
-	bp->kmalloced = top_v = dma_alloc_coherent(bp->bus_dev, alloc_size,
-						   &bp->kmalloced_dma,
-						   GFP_ATOMIC | __GFP_ZERO);
+	bp->kmalloced = top_v = dma_zalloc_coherent(bp->bus_dev, alloc_size,
+						    &bp->kmalloced_dma,
+						    GFP_ATOMIC);
 	if (top_v == NULL)
 		return DFX_K_FAILURE;
 
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 3adb43c..7bbd318 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -351,16 +351,16 @@ static int ali_ircc_open(int i, chipio_t *info)
 
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
+				    &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
 	
 	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->tx_buff.truesize,
+				    &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 9cf836b..ceeb537 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -430,8 +430,8 @@ static int __init nsc_ircc_open(chipio_t *info)
 
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
+				    &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out2;
@@ -439,8 +439,8 @@ static int __init nsc_ircc_open(chipio_t *info)
 	}
 	
 	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->tx_buff.truesize,
+				    &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out3;
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index aa05dad..0dcdf15 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -562,14 +562,14 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
 
 	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
+				    &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL)
 		goto err_out2;
 
 	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->tx_buff.truesize,
+				    &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL)
 		goto err_out3;
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 2dcc60f..9abaec2 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -361,16 +361,16 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-		dma_alloc_coherent(&pdev->dev, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(&pdev->dev, self->rx_buff.truesize,
+				    &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
 
 	self->tx_buff.head =
-		dma_alloc_coherent(&pdev->dev, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(&pdev->dev, self->tx_buff.truesize,
+				    &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index bb8857a..e641bb2 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -215,16 +215,16 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
+				    &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out1;
 	}
 
 	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
+		dma_zalloc_coherent(NULL, self->tx_buff.truesize,
+				    &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index f7c70b3..c51d2dc 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -431,9 +431,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 	u16 ring_mem_size = (ring->type == B43_DMA_64BIT) ?
 				B43_DMA64_RINGMEMSIZE : B43_DMA32_RINGMEMSIZE;
 
-	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
-					    ring_mem_size, &(ring->dmabase),
-					    GFP_KERNEL | __GFP_ZERO);
+	ring->descbase = dma_zalloc_coherent(ring->dev->dev->dma_dev,
+					     ring_mem_size, &(ring->dmabase),
+					     GFP_KERNEL);
 	if (!ring->descbase)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index faeafe2..42eb26c 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -331,10 +331,9 @@ void free_descriptor_buffer(struct b43legacy_dmaring *ring,
 static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 {
 	/* GFP flags must match the flags in free_ringmemory()! */
-	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
-					    B43legacy_DMA_RINGMEMSIZE,
-					    &(ring->dmabase),
-					    GFP_KERNEL | __GFP_ZERO);
+	ring->descbase = dma_zalloc_coherent(ring->dev->dev->dma_dev,
+					     B43legacy_DMA_RINGMEMSIZE,
+					     &(ring->dmabase), GFP_KERNEL);
 	if (!ring->descbase)
 		return -ENOMEM;
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 94af418..3a8d0a2 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -132,9 +132,8 @@ static inline int dma_set_seg_boundary(struct device *dev, unsigned long mask)
 static inline void *dma_zalloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_handle, gfp_t flag)
 {
-	void *ret = dma_alloc_coherent(dev, size, dma_handle, flag);
-	if (ret)
-		memset(ret, 0, size);
+	void *ret = dma_alloc_coherent(dev, size, dma_handle,
+				       flag | __GFP_ZERO);
 	return ret;
 }
 
-- 
1.8.1.2.459.gbcd45b4.dirty
