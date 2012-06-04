From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/3] ethernet: Remove casts to same type
Date: Mon,  4 Jun 2012 15:44:16 -0700
Message-ID: <82c92922869273da4df9b738cc784aac482d88a1.1338849366.git.joe@perches.com>
References: <cover.1338849364.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39140 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756253Ab2FDWoa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 18:44:30 -0400
In-Reply-To: <cover.1338849364.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding casts of objects to the same type is unnecessary
and confusing for a human reader.

For example, this cast:

        int y;
        int *p = (int *)&y;

I used the coccinelle script below to find and remove these
unnecessary casts.  I manually removed the conversions this
script produces of casts with __force, __iomem and __user.

@@
type T;
T *p;
@@

-       (T *)p
+       p

A function in atl1e_main.c was passed a const pointer
when it actually modified elements of the structure.

Change the argument to a non-const pointer.

A function in stmmac needed a __force to avoid a sparse
warning.  Added it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/8390/apne.c                   |    2 +-
 drivers/net/ethernet/aeroflex/greth.c              |    8 ++--
 drivers/net/ethernet/amd/declance.c                |    4 +-
 drivers/net/ethernet/apple/macmace.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |    6 ++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    9 ++---
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   35 ++++++++-----------
 drivers/net/ethernet/atheros/atlx/atl1.c           |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    3 +-
 drivers/net/ethernet/broadcom/cnic.c               |   12 +++---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c       |    4 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |    5 +--
 drivers/net/ethernet/dec/tulip/de4x5.c             |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/hp/hp100.c                    |    6 ++--
 drivers/net/ethernet/i825xx/lp486e.c               |    8 ++--
 drivers/net/ethernet/i825xx/sun3_82586.c           |    4 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    4 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 +-
 drivers/net/ethernet/neterion/s2io.c               |   14 ++++----
 drivers/net/ethernet/neterion/vxge/vxge-config.c   |    8 ++--
 drivers/net/ethernet/neterion/vxge/vxge-config.h   |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    8 ++--
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c  |    5 +--
 drivers/net/ethernet/sgi/ioc3-eth.c                |    4 +-
 drivers/net/ethernet/smsc/smsc9420.c               |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 drivers/net/ethernet/sun/sunqe.c                   |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 34 files changed, 87 insertions(+), 97 deletions(-)

diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
index 9239592..912ed7a 100644
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -454,7 +454,7 @@ apne_block_input(struct net_device *dev, int count, struct sk_buff *skb, int rin
 	buf[count-1] = inb(NE_BASE + NE_DATAPORT);
       }
     } else {
-      ptrc = (char*)buf;
+      ptrc = buf;
       for (cnt = 0; cnt < count; cnt++)
         *ptrc++ = inb(NE_BASE + NE_DATAPORT);
     }
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 3485011..9c77c73 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1014,7 +1014,7 @@ static int greth_set_mac_add(struct net_device *dev, void *p)
 	struct greth_regs *regs;
 
 	greth = netdev_priv(dev);
-	regs = (struct greth_regs *) greth->regs;
+	regs = greth->regs;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -1036,7 +1036,7 @@ static void greth_set_hash_filter(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
 	struct greth_private *greth = netdev_priv(dev);
-	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+	struct greth_regs *regs = greth->regs;
 	u32 mc_filter[2];
 	unsigned int bitnr;
 
@@ -1055,7 +1055,7 @@ static void greth_set_multicast_list(struct net_device *dev)
 {
 	int cfg;
 	struct greth_private *greth = netdev_priv(dev);
-	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+	struct greth_regs *regs = greth->regs;
 
 	cfg = GRETH_REGLOAD(regs->control);
 	if (dev->flags & IFF_PROMISC)
@@ -1414,7 +1414,7 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 		goto error1;
 	}
 
-	regs = (struct greth_regs *) greth->regs;
+	regs = greth->regs;
 	greth->irq = ofdev->archdata.irqs[0];
 
 	dev_set_drvdata(greth->dev, dev);
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 75299f5..7203b52 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -623,7 +623,7 @@ static int lance_rx(struct net_device *dev)
 			skb_put(skb, len);	/* make room */
 
 			cp_from_buf(lp->type, skb->data,
-				    (char *)lp->rx_buf_ptr_cpu[entry], len);
+				    lp->rx_buf_ptr_cpu[entry], len);
 
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
@@ -919,7 +919,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	*lib_ptr(ib, btx_ring[entry].length, lp->type) = (-len);
 	*lib_ptr(ib, btx_ring[entry].misc, lp->type) = 0;
 
-	cp_to_buf(lp->type, (char *)lp->tx_buf_ptr_cpu[entry], skb->data, len);
+	cp_to_buf(lp->type, lp->tx_buf_ptr_cpu[entry], skb->data, len);
 
 	/* Now, give the packet to the lance */
 	*lib_ptr(ib, btx_ring[entry].tmd1, lp->type) =
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index ab7ff86..a92ddee7 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -228,7 +228,7 @@ static int __devinit mace_probe(struct platform_device *pdev)
 	 * bits are reversed.
 	 */
 
-	addr = (void *)MACE_PROM;
+	addr = MACE_PROM;
 
 	for (j = 0; j < 6; ++j) {
 		u8 v = bitrev8(addr[j<<4]);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index ff9c738..801f012 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -602,7 +602,7 @@ int atl1c_phy_reset(struct atl1c_hw *hw)
 
 int atl1c_phy_init(struct atl1c_hw *hw)
 {
-	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
+	struct atl1c_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	int ret_val;
 	u16 mii_bmcr_data = BMCR_RESET;
@@ -696,7 +696,7 @@ int atl1c_get_speed_and_duplex(struct atl1c_hw *hw, u16 *speed, u16 *duplex)
 /* select one link mode to get lower power consumption */
 int atl1c_phy_to_ps_link(struct atl1c_hw *hw)
 {
-	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
+	struct atl1c_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	int ret = 0;
 	u16 autoneg_advertised = ADVERTISED_10baseT_Half;
@@ -768,7 +768,7 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw)
 
 int atl1c_power_saving(struct atl1c_hw *hw, u32 wufc)
 {
-	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
+	struct atl1c_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 master_ctrl, mac_ctrl, phy_ctrl;
 	u32 wol_ctrl, speed;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9cc1570..85717cb 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -989,12 +989,12 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 	}
 	for (i = 0; i < AT_MAX_TRANSMIT_QUEUE; i++) {
 		tpd_ring[i].buffer_info =
-			(struct atl1c_buffer *) (tpd_ring->buffer_info + count);
+			(tpd_ring->buffer_info + count);
 		count += tpd_ring[i].count;
 	}
 
 	rfd_ring->buffer_info =
-		(struct atl1c_buffer *) (tpd_ring->buffer_info + count);
+		(tpd_ring->buffer_info + count);
 	count += rfd_ring->count;
 	rx_desc_count += rfd_ring->count;
 
@@ -1227,7 +1227,7 @@ static void atl1c_start_mac(struct atl1c_adapter *adapter)
  */
 static int atl1c_reset_mac(struct atl1c_hw *hw)
 {
-	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
+	struct atl1c_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 ctrl_data = 0;
 
@@ -1531,8 +1531,7 @@ static inline void atl1c_clear_phy_int(struct atl1c_adapter *adapter)
 static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 				enum atl1c_trans_queue type)
 {
-	struct atl1c_tpd_ring *tpd_ring = (struct atl1c_tpd_ring *)
-				&adapter->tpd_ring[type];
+	struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
 	struct atl1c_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index 6e61f9f..82b2386 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -268,7 +268,7 @@ static int atl1e_set_eeprom(struct net_device *netdev,
 	if (eeprom_buff == NULL)
 		return -ENOMEM;
 
-	ptr = (u32 *)eeprom_buff;
+	ptr = eeprom_buff;
 
 	if (eeprom->offset & 3) {
 		/* need read/modify/write of first changed EEPROM word */
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 1220e51..0aed82e 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -641,8 +641,7 @@ static int __devinit atl1e_sw_init(struct atl1e_adapter *adapter)
  */
 static void atl1e_clean_tx_ring(struct atl1e_adapter *adapter)
 {
-	struct atl1e_tx_ring *tx_ring = (struct atl1e_tx_ring *)
-				&adapter->tx_ring;
+	struct atl1e_tx_ring *tx_ring = &adapter->tx_ring;
 	struct atl1e_tx_buffer *tx_buffer = NULL;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 index, ring_count;
@@ -686,7 +685,7 @@ static void atl1e_clean_tx_ring(struct atl1e_adapter *adapter)
 static void atl1e_clean_rx_ring(struct atl1e_adapter *adapter)
 {
 	struct atl1e_rx_ring *rx_ring =
-		(struct atl1e_rx_ring *)&adapter->rx_ring;
+		&adapter->rx_ring;
 	struct atl1e_rx_page_desc *rx_page_desc = rx_ring->rx_page_desc;
 	u16 i, j;
 
@@ -884,14 +883,12 @@ failed:
 	return err;
 }
 
-static inline void atl1e_configure_des_ring(const struct atl1e_adapter *adapter)
+static inline void atl1e_configure_des_ring(struct atl1e_adapter *adapter)
 {
 
-	struct atl1e_hw *hw = (struct atl1e_hw *)&adapter->hw;
-	struct atl1e_rx_ring *rx_ring =
-			(struct atl1e_rx_ring *)&adapter->rx_ring;
-	struct atl1e_tx_ring *tx_ring =
-			(struct atl1e_tx_ring *)&adapter->tx_ring;
+	struct atl1e_hw *hw = &adapter->hw;
+	struct atl1e_rx_ring *rx_ring = &adapter->rx_ring;
+	struct atl1e_tx_ring *tx_ring = &adapter->tx_ring;
 	struct atl1e_rx_page_desc *rx_page_desc = NULL;
 	int i, j;
 
@@ -932,7 +929,7 @@ static inline void atl1e_configure_des_ring(const struct atl1e_adapter *adapter)
 
 static inline void atl1e_configure_tx(struct atl1e_adapter *adapter)
 {
-	struct atl1e_hw *hw = (struct atl1e_hw *)&adapter->hw;
+	struct atl1e_hw *hw = &adapter->hw;
 	u32 dev_ctrl_data = 0;
 	u32 max_pay_load = 0;
 	u32 jumbo_thresh = 0;
@@ -975,7 +972,7 @@ static inline void atl1e_configure_tx(struct atl1e_adapter *adapter)
 
 static inline void atl1e_configure_rx(struct atl1e_adapter *adapter)
 {
-	struct atl1e_hw *hw = (struct atl1e_hw *)&adapter->hw;
+	struct atl1e_hw *hw = &adapter->hw;
 	u32 rxf_len  = 0;
 	u32 rxf_low  = 0;
 	u32 rxf_high = 0;
@@ -1224,8 +1221,7 @@ static inline void atl1e_clear_phy_int(struct atl1e_adapter *adapter)
 
 static bool atl1e_clean_tx_irq(struct atl1e_adapter *adapter)
 {
-	struct atl1e_tx_ring *tx_ring = (struct atl1e_tx_ring *)
-					&adapter->tx_ring;
+	struct atl1e_tx_ring *tx_ring = &adapter->tx_ring;
 	struct atl1e_tx_buffer *tx_buffer = NULL;
 	u16 hw_next_to_clean = AT_READ_REGW(&adapter->hw, REG_TPD_CONS_IDX);
 	u16 next_to_clean = atomic_read(&tx_ring->next_to_clean);
@@ -1384,15 +1380,14 @@ static struct atl1e_rx_page *atl1e_get_rx_page(struct atl1e_adapter *adapter,
 		(struct atl1e_rx_page_desc *) adapter->rx_ring.rx_page_desc;
 	u8 rx_using = rx_page_desc[que].rx_using;
 
-	return (struct atl1e_rx_page *)&(rx_page_desc[que].rx_page[rx_using]);
+	return &(rx_page_desc[que].rx_page[rx_using]);
 }
 
 static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 		   int *work_done, int work_to_do)
 {
 	struct net_device *netdev  = adapter->netdev;
-	struct atl1e_rx_ring *rx_ring = (struct atl1e_rx_ring *)
-					 &adapter->rx_ring;
+	struct atl1e_rx_ring *rx_ring = &adapter->rx_ring;
 	struct atl1e_rx_page_desc *rx_page_desc =
 		(struct atl1e_rx_page_desc *) rx_ring->rx_page_desc;
 	struct sk_buff *skb = NULL;
@@ -1576,7 +1571,7 @@ static struct atl1e_tpd_desc *atl1e_get_tpd(struct atl1e_adapter *adapter)
 		tx_ring->next_to_use = 0;
 
 	memset(&tx_ring->desc[next_to_use], 0, sizeof(struct atl1e_tpd_desc));
-	return (struct atl1e_tpd_desc *)&tx_ring->desc[next_to_use];
+	return &tx_ring->desc[next_to_use];
 }
 
 static struct atl1e_tx_buffer *
@@ -2061,8 +2056,8 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (wufc) {
 		/* get link status */
-		atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
-		atl1e_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
+		atl1e_read_phy_reg(hw, MII_BMSR, &mii_bmsr_data);
+		atl1e_read_phy_reg(hw, MII_BMSR, &mii_bmsr_data);
 
 		mii_advertise_data = ADVERTISE_10HALF;
 
@@ -2086,7 +2081,7 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 				for (i = 0; i < AT_SUSPEND_LINK_TIMEOUT; i++) {
 					msleep(100);
 					atl1e_read_phy_reg(hw, MII_BMSR,
-							(u16 *)&mii_bmsr_data);
+							&mii_bmsr_data);
 					if (mii_bmsr_data & BMSR_LSTATUS)
 						break;
 				}
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 5d10884..149a294 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1061,7 +1061,7 @@ static s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
-		(struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
+		(tpd_ring->buffer_info + tpd_ring->count);
 
 	/*
 	 * real ring DMA buffer
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ac7b744..ff5d3c1 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -872,8 +872,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 			bnapi = &bp->bnx2_napi[i];
 
-			sblk = (void *) (status_blk +
-					 BNX2_SBLK_MSIX_ALIGN_SIZE * i);
+			sblk = (status_blk + BNX2_SBLK_MSIX_ALIGN_SIZE * i);
 			bnapi->status_blk.msix = sblk;
 			bnapi->hw_tx_cons_ptr =
 				&sblk->status_tx_quick_consumer_index;
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index c95e7b5..65e66ca 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -2585,7 +2585,7 @@ static void cnic_bnx2x_kwqe_err(struct cnic_dev *dev, struct kwqe *kwqe)
 		return;
 	}
 
-	cqes[0] = (struct kcqe *) &kcqe;
+	cqes[0] = &kcqe;
 	cnic_reply_bnx2x_kcqes(dev, ulp_type, cqes, 1);
 }
 
@@ -4665,9 +4665,9 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 
 	cp->kcq1.sw_prod_idx = 0;
 	cp->kcq1.hw_prod_idx_ptr =
-		(u16 *) &sblk->status_completion_producer_index;
+		&sblk->status_completion_producer_index;
 
-	cp->kcq1.status_idx_ptr = (u16 *) &sblk->status_idx;
+	cp->kcq1.status_idx_ptr = &sblk->status_idx;
 
 	/* Initialize the kernel complete queue context. */
 	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
@@ -4693,9 +4693,9 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 		u32 sb = BNX2_L2CTX_L5_STATUSB_NUM(sb_id);
 
 		cp->kcq1.hw_prod_idx_ptr =
-			(u16 *) &msblk->status_completion_producer_index;
-		cp->kcq1.status_idx_ptr = (u16 *) &msblk->status_idx;
-		cp->kwq_con_idx_ptr = (u16 *) &msblk->status_cmd_consumer_index;
+			&msblk->status_completion_producer_index;
+		cp->kcq1.status_idx_ptr = &msblk->status_idx;
+		cp->kwq_con_idx_ptr = &msblk->status_cmd_consumer_index;
 		cp->int_num = sb_id << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT;
 		cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
 		cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index cfc22a6..6a68e8d 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -67,10 +67,10 @@ bfa_cb_image_get_chunk(enum bfi_asic_gen asic_gen, u32 off)
 {
 	switch (asic_gen) {
 	case BFI_ASIC_GEN_CT:
-		return (u32 *)(bfi_image_ct_cna + off);
+		return (bfi_image_ct_cna + off);
 		break;
 	case BFI_ASIC_GEN_CT2:
-		return (u32 *)(bfi_image_ct2_cna + off);
+		return (bfi_image_ct2_cna + off);
 		break;
 	default:
 		return NULL;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 65e4b28..55cf72a 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -575,7 +575,7 @@ static void t3_process_tid_release_list(struct work_struct *work)
 		if (!skb) {
 			spin_lock_bh(&td->tid_release_lock);
 			p->ctx = (void *)td->tid_release_list;
-			td->tid_release_list = (struct t3c_tid_entry *)p;
+			td->tid_release_list = p;
 			break;
 		}
 		mk_tid_release(skb, p - td->tid_maps.tid_tab);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e111d97..8596aca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -753,7 +753,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		end = (void *)q->desc + part1;
 	}
 	if ((uintptr_t)end & 8)           /* 0-pad to multiple of 16 */
-		*(u64 *)end = 0;
+		*end = 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 25e3308..9dad561 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -418,7 +418,7 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		 * restart a TX Ethernet Queue which was stopped for lack of
 		 * free TX Queue Descriptors ...
 		 */
-		const struct cpl_sge_egr_update *p = (void *)cpl;
+		const struct cpl_sge_egr_update *p = cpl;
 		unsigned int qid = EGR_QID(be32_to_cpu(p->opcode_qid));
 		struct sge *s = &adapter->sge;
 		struct sge_txq *tq;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 0bd585b..f2d1ecd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -934,7 +934,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 		end = (void *)tq->desc + part1;
 	}
 	if ((uintptr_t)end & 8)           /* 0-pad to multiple of 16 */
-		*(u64 *)end = 0;
+		*end = 0;
 }
 
 /**
@@ -1323,8 +1323,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		if (unlikely((void *)sgl == (void *)tq->stat)) {
 			sgl = (void *)tq->desc;
-			end = (void *)((void *)tq->desc +
-				       ((void *)end - (void *)tq->stat));
+			end = ((void *)tq->desc + ((void *)end - (void *)tq->stat));
 		}
 
 		write_sgl(skb, tq, sgl, end, 0, addr);
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index d3cd489..f879e92 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -3973,7 +3973,7 @@ DevicePresent(struct net_device *dev, u_long aprom_addr)
 	    tmp = srom_rd(aprom_addr, i);
 	    *p++ = cpu_to_le16(tmp);
 	}
-	de4x5_dbg_srom((struct de4x5_srom *)&lp->srom);
+	de4x5_dbg_srom(&lp->srom);
     }
 }
 
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9ac14f8..21c6574 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -185,7 +185,7 @@ static void mem_disp(u8 *addr, int size)
 	for (; (u32) i < (u32) addr + size4Aling; i += 4)
 		printk("%08x ", *((u32 *) (i)));
 	for (; (u32) i < (u32) addr + size; i++)
-		printk("%02x", *((u8 *) (i)));
+		printk("%02x", *((i)));
 	if (notAlign == 1)
 		printk("\r\n");
 }
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index d496673..3f4391b 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1217,7 +1217,7 @@ static int hp100_init_rxpdl(struct net_device *dev,
 
 	ringptr->pdl = pdlptr + 1;
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr + 1);
-	ringptr->skb = (void *) NULL;
+	ringptr->skb = NULL;
 
 	/*
 	 * Write address and length of first PDL Fragment (which is used for
@@ -1243,7 +1243,7 @@ static int hp100_init_txpdl(struct net_device *dev,
 
 	ringptr->pdl = pdlptr;	/* +1; */
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr);	/* +1 */
-	ringptr->skb = (void *) NULL;
+	ringptr->skb = NULL;
 
 	return roundup(MAX_TX_FRAG * 2 + 2, 4);
 }
@@ -1628,7 +1628,7 @@ static void hp100_clean_txring(struct net_device *dev)
 		/* Conversion to new PCI API : NOP */
 		pci_unmap_single(lp->pci_dev, (dma_addr_t) lp->txrhead->pdl[1], lp->txrhead->pdl[2], PCI_DMA_TODEVICE);
 		dev_kfree_skb_any(lp->txrhead->skb);
-		lp->txrhead->skb = (void *) NULL;
+		lp->txrhead->skb = NULL;
 		lp->txrhead = lp->txrhead->next;
 		lp->txrcommit--;
 	}
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
index 6c2952c..3735bfa 100644
--- a/drivers/net/ethernet/i825xx/lp486e.c
+++ b/drivers/net/ethernet/i825xx/lp486e.c
@@ -629,10 +629,10 @@ init_i596(struct net_device *dev) {
 
 	memcpy ((void *)lp->eth_addr, dev->dev_addr, 6);
 	lp->set_add.command = CmdIASetup;
-	i596_add_cmd(dev, (struct i596_cmd *)&lp->set_add);
+	i596_add_cmd(dev, &lp->set_add);
 
 	lp->tdr.command = CmdTDR;
-	i596_add_cmd(dev, (struct i596_cmd *)&lp->tdr);
+	i596_add_cmd(dev, &lp->tdr);
 
 	if (lp->scb.command && i596_timeout(dev, "i82596 init", 200))
 		return 1;
@@ -737,7 +737,7 @@ i596_cleanup_cmd(struct net_device *dev) {
 
 	lp = netdev_priv(dev);
 	while (lp->cmd_head) {
-		cmd = (struct i596_cmd *)lp->cmd_head;
+		cmd = lp->cmd_head;
 
 		lp->cmd_head = pa_to_va(lp->cmd_head->pa_next);
 		lp->cmd_backlog--;
@@ -1281,7 +1281,7 @@ static void set_multicast_list(struct net_device *dev) {
 			lp->i596_config[8] |= 0x01;
 		}
 
-		i596_add_cmd(dev, (struct i596_cmd *) &lp->set_conf);
+		i596_add_cmd(dev, &lp->set_conf);
 	}
 }
 
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index cae17f4..353f57f6 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -571,7 +571,7 @@ static int init586(struct net_device *dev)
 	}
 #endif
 
-	ptr = alloc_rfa(dev,(void *)ptr); /* init receive-frame-area */
+	ptr = alloc_rfa(dev,ptr); /* init receive-frame-area */
 
 	/*
 	 * alloc xmit-buffs / init xmit_cmds
@@ -584,7 +584,7 @@ static int init586(struct net_device *dev)
 		ptr = (char *) ptr + XMIT_BUFF_SIZE;
 		p->xmit_buffs[i] = (struct tbd_struct *)ptr; /* TBD */
 		ptr = (char *) ptr + sizeof(struct tbd_struct);
-		if((void *)ptr > (void *)dev->mem_end)
+		if(ptr > (void *)dev->mem_end)
 		{
 			printk("%s: not enough shared-mem for your configuration!\n",dev->name);
 			return 1;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 04d901d..ec85bf1 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1894,7 +1894,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 		goto out_free;
 	}
 
-	rx_desc = (struct rx_desc *)rxq->rx_desc_area;
+	rx_desc = rxq->rx_desc_area;
 	for (i = 0; i < rxq->rx_ring_size; i++) {
 		int nexti;
 
@@ -1999,7 +1999,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	txq->tx_desc_area_size = size;
 
-	tx_desc = (struct tx_desc *)txq->tx_desc_area;
+	tx_desc = txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
 		struct tx_desc *txd = tx_desc + i;
 		int nexti;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 1db023b..5948972 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1032,7 +1032,7 @@ static int rxq_init(struct net_device *dev)
 	}
 	memset((void *)pep->p_rx_desc_area, 0, size);
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct rx_desc *)pep->p_rx_desc_area;
+	p_rx_desc = pep->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
 		p_rx_desc[i].next_desc_ptr = pep->rx_desc_dma +
 		    ((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
@@ -1095,7 +1095,7 @@ static int txq_init(struct net_device *dev)
 	}
 	memset((void *)pep->p_tx_desc_area, 0, pep->tx_desc_area_size);
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct tx_desc *)pep->p_tx_desc_area;
+	p_tx_desc = pep->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
 		p_tx_desc[i].next_desc_ptr = pep->tx_desc_dma +
 		    ((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index b45d0e7..766b8c5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -779,7 +779,7 @@ static int qp_res_start_move_to(struct mlx4_dev *dev, int slave, int qpn,
 			r->com.to_state = state;
 			r->com.state = RES_QP_BUSY;
 			if (qp)
-				*qp = (struct res_qp *)r;
+				*qp = r;
 		}
 	}
 
@@ -832,7 +832,7 @@ static int mr_res_start_move_to(struct mlx4_dev *dev, int slave, int index,
 			r->com.to_state = state;
 			r->com.state = RES_MPT_BUSY;
 			if (mpt)
-				*mpt = (struct res_mpt *)r;
+				*mpt = r;
 		}
 	}
 
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index bb36758..e7cd587 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -6946,9 +6946,9 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 				if (sp->rxd_mode == RXD_MODE_3B)
 					ba = &ring->ba[j][k];
 				if (set_rxd_buffer_pointer(sp, rxdp, ba, &skb,
-							   (u64 *)&temp0_64,
-							   (u64 *)&temp1_64,
-							   (u64 *)&temp2_64,
+							   &temp0_64,
+							   &temp1_64,
+							   &temp2_64,
 							   size) == -ENOMEM) {
 					return 0;
 				}
@@ -7149,7 +7149,7 @@ static int s2io_card_up(struct s2io_nic *sp)
 	int i, ret = 0;
 	struct config_param *config;
 	struct mac_info *mac_control;
-	struct net_device *dev = (struct net_device *)sp->dev;
+	struct net_device *dev = sp->dev;
 	u16 interruptible;
 
 	/* Initialize the H/W I/O registers */
@@ -7325,7 +7325,7 @@ static void s2io_tx_watchdog(struct net_device *dev)
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 {
 	struct s2io_nic *sp = ring_data->nic;
-	struct net_device *dev = (struct net_device *)ring_data->dev;
+	struct net_device *dev = ring_data->dev;
 	struct sk_buff *skb = (struct sk_buff *)
 		((unsigned long)rxdp->Host_Control);
 	int ring_no = ring_data->ring_no;
@@ -7508,7 +7508,7 @@ aggregate:
 
 static void s2io_link(struct s2io_nic *sp, int link)
 {
-	struct net_device *dev = (struct net_device *)sp->dev;
+	struct net_device *dev = sp->dev;
 	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	if (link != sp->last_link_state) {
@@ -8280,7 +8280,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 		return -1;
 	}
 
-	*ip = (struct iphdr *)((u8 *)buffer + ip_off);
+	*ip = (struct iphdr *)(buffer + ip_off);
 	ip_len = (u8)((*ip)->ihl);
 	ip_len <<= 2;
 	*tcp = (struct tcphdr *)((unsigned long)*ip + ip_len);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index 98e2c10..32d0682 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -2346,7 +2346,7 @@ void __vxge_hw_blockpool_blocks_add(struct __vxge_hw_blockpool *blockpool)
 
 	for (i = 0; i < nreq; i++)
 		vxge_os_dma_malloc_async(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			(blockpool->hldev)->pdev,
 			blockpool->hldev, VXGE_HW_BLOCK_SIZE);
 }
 
@@ -2428,13 +2428,13 @@ __vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
 			break;
 
 		pci_unmap_single(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			(blockpool->hldev)->pdev,
 			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
 			((struct __vxge_hw_blockpool_entry *)p)->length,
 			PCI_DMA_BIDIRECTIONAL);
 
 		vxge_os_dma_free(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			(blockpool->hldev)->pdev,
 			((struct __vxge_hw_blockpool_entry *)p)->memblock,
 			&((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
 
@@ -4059,7 +4059,7 @@ __vxge_hw_vpath_sw_reset(struct __vxge_hw_device *hldev, u32 vp_id)
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct __vxge_hw_virtualpath *vpath;
 
-	vpath = (struct __vxge_hw_virtualpath *)&hldev->virtual_paths[vp_id];
+	vpath = &hldev->virtual_paths[vp_id];
 
 	if (vpath->ringh) {
 		status = __vxge_hw_ring_reset(vpath->ringh);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.h b/drivers/net/ethernet/neterion/vxge/vxge-config.h
index 5046a64..9e0c1ee 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.h
@@ -1922,7 +1922,7 @@ realloc:
 		/* misaligned, free current one and try allocating
 		 * size + VXGE_CACHE_LINE_SIZE memory
 		 */
-		kfree((void *) vaddr);
+		kfree(vaddr);
 		size += VXGE_CACHE_LINE_SIZE;
 		realloc_flag = 1;
 		goto realloc;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 51387c3..2578eb1 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -1134,7 +1134,7 @@ static void vxge_set_multicast(struct net_device *dev)
 		"%s:%d", __func__, __LINE__);
 
 	vdev = netdev_priv(dev);
-	hldev = (struct __vxge_hw_device  *)vdev->devh;
+	hldev = vdev->devh;
 
 	if (unlikely(!is_vxge_card_up(vdev)))
 		return;
@@ -3989,16 +3989,16 @@ static void __devinit vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
 			continue;
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s: MTU size - %d", vdev->ndev->name,
-			((struct __vxge_hw_device  *)(vdev->devh))->
+			((vdev->devh))->
 				config.vp_config[i].mtu);
 		vxge_debug_init(VXGE_TRACE,
 			"%s: VLAN tag stripping %s", vdev->ndev->name,
-			((struct __vxge_hw_device  *)(vdev->devh))->
+			((vdev->devh))->
 				config.vp_config[i].rpa_strip_vlan_tag
 			? "Enabled" : "Disabled");
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s: Max frags : %d", vdev->ndev->name,
-			((struct __vxge_hw_device  *)(vdev->devh))->
+			((vdev->devh))->
 				config.vp_config[i].fifo.max_frags);
 		break;
 	}
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
index 5954fa2..99749bd 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
@@ -533,8 +533,7 @@ __vxge_hw_device_handle_error(struct __vxge_hw_device *hldev, u32 vp_id,
 
 	/* notify driver */
 	if (hldev->uld_callbacks->crit_err)
-		hldev->uld_callbacks->crit_err(
-			(struct __vxge_hw_device *)hldev,
+		hldev->uld_callbacks->crit_err(hldev,
 			type, vp_id);
 out:
 
@@ -1322,7 +1321,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
 	/* check whether it is not the end */
 	if (!own || *t_code == VXGE_HW_RING_T_CODE_FRM_DROP) {
 
-		vxge_assert(((struct vxge_hw_ring_rxd_1 *)rxdp)->host_control !=
+		vxge_assert((rxdp)->host_control !=
 				0);
 
 		++ring->cmpl_cnt;
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index ac149d9..b5ba308 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -583,7 +583,7 @@ static inline void ioc3_rx(struct net_device *dev)
 	unsigned long *rxr;
 	u32 w0, err;
 
-	rxr = (unsigned long *) ip->rxr;		/* Ring base */
+	rxr = ip->rxr;		/* Ring base */
 	rx_entry = ip->rx_ci;				/* RX consume index */
 	n_entry = ip->rx_pi;
 
@@ -903,7 +903,7 @@ static void ioc3_alloc_rings(struct net_device *dev)
 	if (ip->rxr == NULL) {
 		/* Allocate and initialize rx ring.  4kb = 512 entries  */
 		ip->rxr = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
-		rxr = (unsigned long *) ip->rxr;
+		rxr = ip->rxr;
 		if (!rxr)
 			printk("ioc3_alloc_rings(): get_zeroed_page() failed!\n");
 
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index fd33b21..1fcd914e 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1640,8 +1640,7 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_free_io_4;
 
 	/* descriptors are aligned due to the nature of pci_alloc_consistent */
-	pd->tx_ring = (struct smsc9420_dma_desc *)
-	    (pd->rx_ring + RX_RING_SIZE);
+	pd->tx_ring = (pd->rx_ring + RX_RING_SIZE);
 	pd->tx_dma_addr = pd->rx_dma_addr +
 	    sizeof(struct smsc9420_dma_desc) * RX_RING_SIZE;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 3dd8f08..df4774d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -190,7 +190,7 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	iounmap((void *)priv->ioaddr);
+	iounmap((void __force __iomem *)priv->ioaddr);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 7d4a040..aeded7f 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -441,7 +441,7 @@ static void qe_rx(struct sunqe *qep)
 			} else {
 				skb_reserve(skb, 2);
 				skb_put(skb, len);
-				skb_copy_to_linear_data(skb, (unsigned char *) this_qbuf,
+				skb_copy_to_linear_data(skb, this_qbuf,
 						 len);
 				skb->protocol = eth_type_trans(skb, qep->dev);
 				netif_rx(skb);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index ea3e0a2..a46c198 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -486,7 +486,7 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
 	velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
 	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
-	velocity_set_int_opt((int *) &opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
+	velocity_set_int_opt(&opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
 	opts->numrx = (opts->numrx & ~3);
 }
 
-- 
1.7.8.111.gad25c.dirty
