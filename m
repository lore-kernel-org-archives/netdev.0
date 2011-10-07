From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [RFC PATCH net-next] Remove unnecessary driver assignments of ethtool_ringparam fields to zero
Date: Fri,  7 Oct 2011 15:48:38 -0700 (PDT)
Message-ID: <20111007224838.DCD05290054F@tardy>
To: <netdev@vger.kernel.org>, "Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Rasesh Mody" <rmody@brocade.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Alex Duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:41503 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758737Ab1JGWsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 18:48:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Per comments from Ben Hutchings on a previous patch, sweep the floors
a little removing unnecessary assignments of zero to fields of struct
ethtool_ringparam in driver code supporting ethtool -g.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.

 drivers/net/ethernet/3com/typhoon.c                |    4 ----
 drivers/net/ethernet/atheros/atlx/atl1.c           |    4 ----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    2 --
 drivers/net/ethernet/broadcom/bnx2.c               |    2 --
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    5 -----
 drivers/net/ethernet/broadcom/tg3.c                |    2 --
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |    4 ----
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    2 --
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    1 -
 drivers/net/ethernet/intel/e100.c                  |    4 ----
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |    4 ----
 drivers/net/ethernet/intel/e1000e/ethtool.c        |    4 ----
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |    4 ----
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    4 ----
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c     |    4 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    4 ----
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |    4 ----
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 ----
 drivers/net/ethernet/marvell/skge.c                |    4 ----
 drivers/net/ethernet/marvell/sky2.c                |    4 ----
 drivers/net/ethernet/neterion/s2io.c               |    2 --
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 ----
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |    4 ----
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |    3 ---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    3 ---
 drivers/net/ethernet/sfc/ethtool.c                 |    4 ----
 26 files changed, 0 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 607c09e..11f8858 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1148,13 +1148,9 @@ static void
 typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
 	ering->rx_max_pending = RXENT_ENTRIES;
-	ering->rx_mini_max_pending = 0;
-	ering->rx_jumbo_max_pending = 0;
 	ering->tx_max_pending = TXLO_ENTRIES - 1;
 
 	ering->rx_pending = RXENT_ENTRIES;
-	ering->rx_mini_pending = 0;
-	ering->rx_jumbo_pending = 0;
 	ering->tx_pending = TXLO_ENTRIES - 1;
 }
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 43511ab..7381a49 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3473,12 +3473,8 @@ static void atl1_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = ATL1_MAX_RFD;
 	ring->tx_max_pending = ATL1_MAX_TPD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rxdr->count;
 	ring->tx_pending = txdr->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int atl1_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 05b0228..a11a8ad 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1398,8 +1398,6 @@ static void bcm_enet_get_ringparam(struct net_device *dev,
 	/* rx/tx ring is actually only limited by memory */
 	ering->rx_max_pending = 8192;
 	ering->tx_max_pending = 8192;
-	ering->rx_mini_max_pending = 0;
-	ering->rx_jumbo_max_pending = 0;
 	ering->rx_pending = priv->rx_ring_size;
 	ering->tx_pending = priv->tx_ring_size;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ad24d8c..3c221be 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7155,11 +7155,9 @@ bnx2_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	ering->rx_max_pending = MAX_TOTAL_RX_DESC_CNT;
-	ering->rx_mini_max_pending = 0;
 	ering->rx_jumbo_max_pending = MAX_TOTAL_RX_PG_DESC_CNT;
 
 	ering->rx_pending = bp->rx_ring_size;
-	ering->rx_mini_pending = 0;
 	ering->rx_jumbo_pending = bp->rx_pg_ring_size;
 
 	ering->tx_max_pending = MAX_TX_DESC_CNT;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index a49f8cf..1a6e37c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1344,17 +1344,12 @@ static void bnx2x_get_ringparam(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	ering->rx_max_pending = MAX_RX_AVAIL;
-	ering->rx_mini_max_pending = 0;
-	ering->rx_jumbo_max_pending = 0;
 
 	if (bp->rx_ring_size)
 		ering->rx_pending = bp->rx_ring_size;
 	else
 		ering->rx_pending = MAX_RX_AVAIL;
 
-	ering->rx_mini_pending = 0;
-	ering->rx_jumbo_pending = 0;
-
 	ering->tx_max_pending = MAX_TX_AVAIL;
 	ering->tx_pending = bp->tx_ring_size;
 }
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9dbd1af..fe712f9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10514,7 +10514,6 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 	struct tg3 *tp = netdev_priv(dev);
 
 	ering->rx_max_pending = tp->rx_std_ring_mask;
-	ering->rx_mini_max_pending = 0;
 	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		ering->rx_jumbo_max_pending = tp->rx_jmb_ring_mask;
 	else
@@ -10523,7 +10522,6 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 	ering->tx_max_pending = TG3_TX_RING_SIZE - 1;
 
 	ering->rx_pending = tp->rx_pending;
-	ering->rx_mini_pending = 0;
 	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		ering->rx_jumbo_pending = tp->rx_jumbo_pending;
 	else
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index ac6b495..fd3dcc1 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -419,13 +419,9 @@ bnad_get_ringparam(struct net_device *netdev,
 	struct bnad *bnad = netdev_priv(netdev);
 
 	ringparam->rx_max_pending = BNAD_MAX_RXQ_DEPTH;
-	ringparam->rx_mini_max_pending = 0;
-	ringparam->rx_jumbo_max_pending = 0;
 	ringparam->tx_max_pending = BNAD_MAX_TXQ_DEPTH;
 
 	ringparam->rx_pending = bnad->rxq_depth;
-	ringparam->rx_mini_max_pending = 0;
-	ringparam->rx_jumbo_max_pending = 0;
 	ringparam->tx_pending = bnad->txq_depth;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 9993f4f..ca26d97 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -712,12 +712,10 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 	int jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
-	e->rx_mini_max_pending = 0;
 	e->rx_jumbo_max_pending = MAX_RX_JUMBO_BUFFERS;
 	e->tx_max_pending = MAX_CMDQ_ENTRIES;
 
 	e->rx_pending = adapter->params.sge.freelQ_size[!jumbo_fl];
-	e->rx_mini_pending = 0;
 	e->rx_jumbo_pending = adapter->params.sge.freelQ_size[jumbo_fl];
 	e->tx_pending = adapter->params.sge.cmdQ_size[0];
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 29e0e42..4d15c8f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1898,7 +1898,6 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
-	e->rx_mini_max_pending = 0;
 	e->rx_jumbo_max_pending = MAX_RX_JUMBO_BUFFERS;
 	e->tx_max_pending = MAX_TXQ_ENTRIES;
 
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index fe87d3e..ae17cd1 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2502,12 +2502,8 @@ static void e100_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = rfds->max;
 	ring->tx_max_pending = cbs->max;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rfds->count;
 	ring->tx_pending = cbs->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int e100_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 5548d46..2b223ac 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -540,12 +540,8 @@ static void e1000_get_ringparam(struct net_device *netdev,
 		E1000_MAX_82544_RXD;
 	ring->tx_max_pending = (mac_type < e1000_82544) ? E1000_MAX_TXD :
 		E1000_MAX_82544_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rxdr->count;
 	ring->tx_pending = txdr->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int e1000_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index d96d0b0..69c9d21 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -612,12 +612,8 @@ static void e1000_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = E1000_MAX_RXD;
 	ring->tx_max_pending = E1000_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rx_ring->count;
 	ring->tx_pending = tx_ring->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int e1000_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index f227fc5..174540f 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -705,12 +705,8 @@ static void igb_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = IGB_MAX_RXD;
 	ring->tx_max_pending = IGB_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = adapter->rx_ring_count;
 	ring->tx_pending = adapter->tx_ring_count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int igb_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index b0b14d6..0ee8b68 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -259,12 +259,8 @@ static void igbvf_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = IGBVF_MAX_RXD;
 	ring->tx_max_pending = IGBVF_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rx_ring->count;
 	ring->tx_pending = tx_ring->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int igbvf_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index ab404e7..9dfce7d 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -492,12 +492,8 @@ ixgb_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = MAX_RXD;
 	ring->tx_max_pending = MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rxdr->count;
 	ring->tx_pending = txdr->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 10ea29f..18520ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -846,12 +846,8 @@ static void ixgbe_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = IXGBE_MAX_RXD;
 	ring->tx_max_pending = IXGBE_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rx_ring->count;
 	ring->tx_pending = tx_ring->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int ixgbe_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index e1d9e3b..e29ba45 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -281,12 +281,8 @@ static void ixgbevf_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = IXGBEVF_MAX_RXD;
 	ring->tx_max_pending = IXGBEVF_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rx_ring->count;
 	ring->tx_pending = tx_ring->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int ixgbevf_set_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 7325737..f6821aa 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1547,13 +1547,9 @@ mv643xx_eth_get_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
 
 	er->rx_max_pending = 4096;
 	er->tx_max_pending = 4096;
-	er->rx_mini_max_pending = 0;
-	er->rx_jumbo_max_pending = 0;
 
 	er->rx_pending = mp->rx_ring_size;
 	er->tx_pending = mp->tx_ring_size;
-	er->rx_mini_pending = 0;
-	er->rx_jumbo_pending = 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 32db4c8..2977303 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -497,13 +497,9 @@ static void skge_get_ring_param(struct net_device *dev,
 
 	p->rx_max_pending = MAX_RX_RING_SIZE;
 	p->tx_max_pending = MAX_TX_RING_SIZE;
-	p->rx_mini_max_pending = 0;
-	p->rx_jumbo_max_pending = 0;
 
 	p->rx_pending = skge->rx_ring.count;
 	p->tx_pending = skge->tx_ring.count;
-	p->rx_mini_pending = 0;
-	p->rx_jumbo_pending = 0;
 }
 
 static int skge_set_ring_param(struct net_device *dev,
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index a3ce9b6..6895e3b 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4088,13 +4088,9 @@ static void sky2_get_ringparam(struct net_device *dev,
 	struct sky2_port *sky2 = netdev_priv(dev);
 
 	ering->rx_max_pending = RX_MAX_PENDING;
-	ering->rx_mini_max_pending = 0;
-	ering->rx_jumbo_max_pending = 0;
 	ering->tx_max_pending = TX_MAX_PENDING;
 
 	ering->rx_pending = sky2->rx_pending;
-	ering->rx_mini_pending = 0;
-	ering->rx_jumbo_pending = 0;
 	ering->tx_pending = sky2->tx_pending;
 }
 
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 4ec7e3f..bdd3e6a 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5522,14 +5522,12 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
 	}
 
-	ering->rx_mini_max_pending = 0;
 	ering->tx_max_pending = MAX_TX_DESC;
 
 	for (i = 0; i < sp->config.rx_ring_num; i++)
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
 	ering->rx_pending = rx_desc_count;
 	ering->rx_jumbo_pending = rx_desc_count;
-	ering->rx_mini_pending = 0;
 
 	for (i = 0; i < sp->config.tx_fifo_num; i++)
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 84baa59..d7763ab 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4280,13 +4280,9 @@ static void nv_get_ringparam(struct net_device *dev, struct ethtool_ringparam* r
 	struct fe_priv *np = netdev_priv(dev);
 
 	ring->rx_max_pending = (np->desc_ver == DESC_VER_1) ? RING_MAX_DESC_VER_1 : RING_MAX_DESC_VER_2_3;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->tx_max_pending = (np->desc_ver == DESC_VER_1) ? RING_MAX_DESC_VER_1 : RING_MAX_DESC_VER_2_3;
 
 	ring->rx_pending = np->rx_ring_size;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 	ring->tx_pending = np->tx_ring_size;
 }
 
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index ea2d8e4..8c80271 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -273,12 +273,8 @@ static void pch_gbe_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = PCH_GBE_MAX_RXD;
 	ring->tx_max_pending = PCH_GBE_MAX_TXD;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rxdr->count;
 	ring->tx_pending = txdr->count;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index b34fb74..e09ea83 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -413,9 +413,6 @@ netxen_nic_get_ringparam(struct net_device *dev,
 	}
 
 	ring->tx_max_pending = MAX_CMD_DESCRIPTORS;
-
-	ring->rx_mini_max_pending = 0;
-	ring->rx_mini_pending = 0;
 }
 
 static u32
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 11f4df7..5d8bec2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -418,9 +418,6 @@ qlcnic_get_ringparam(struct net_device *dev,
 	ring->rx_max_pending = adapter->max_rxd;
 	ring->rx_jumbo_max_pending = adapter->max_jumbo_rxd;
 	ring->tx_max_pending = MAX_CMD_DESCRIPTORS;
-
-	ring->rx_mini_max_pending = 0;
-	ring->rx_mini_pending = 0;
 }
 
 static u32
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 9536925..f3cd96d 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -682,12 +682,8 @@ static void efx_ethtool_get_ringparam(struct net_device *net_dev,
 
 	ring->rx_max_pending = EFX_MAX_DMAQ_SIZE;
 	ring->tx_max_pending = EFX_MAX_DMAQ_SIZE;
-	ring->rx_mini_max_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = efx->rxq_entries;
 	ring->tx_pending = efx->txq_entries;
-	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static int efx_ethtool_set_ringparam(struct net_device *net_dev,
