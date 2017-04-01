From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V4 net-next 18/18] net: hns: Some checkpatch.pl script & warning fixes
Date: Sat, 1 Apr 2017 12:03:48 +0100
Message-ID: <20170401110348.15908-19-salil.mehta@huawei.com>
References: <20170401110348.15908-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170401110348.15908-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes some checkpatch.pl script caught errors and
warnings during the compilation time.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
Change Log:
Patch V3: Adressed the comment by Joe Perches
          * Link ->  https://lkml.org/lkml/2017/3/31/538
---
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 11 +++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  9 +++++----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  1 -
 6 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 0943138..04211ac 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -103,7 +103,6 @@ enum hnae_led_state {
 #define HNS_RX_FLAG_L4ID_TCP 0x1
 #define HNS_RX_FLAG_L4ID_SCTP 0x3
 
-
 #define HNS_TXD_ASID_S 0
 #define HNS_TXD_ASID_M (0xff << HNS_TXD_ASID_S)
 #define HNS_TXD_BUFNUM_S 8
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 035db86..74bd260 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -86,12 +86,11 @@ static void hns_gmac_disable(void *mac_drv, enum mac_commom_mode mode)
 		dsaf_set_dev_bit(drv, GMAC_PORT_EN_REG, GMAC_PORT_RX_EN_B, 0);
 }
 
-/**
-*hns_gmac_get_en - get port enable
-*@mac_drv:mac device
-*@rx:rx enable
-*@tx:tx enable
-*/
+/* hns_gmac_get_en - get port enable
+ * @mac_drv:mac device
+ * @rx:rx enable
+ * @tx:tx enable
+ */
 static void hns_gmac_get_en(void *mac_drv, u32 *rx, u32 *tx)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 4db02e2..4507e82 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -68,7 +68,7 @@ enum dsaf_roce_qos_sl {
 };
 
 #define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
-#define HNS_DSAF_IS_DEBUG(dev) (dev->dsaf_mode == DSAF_MODE_DISABLE_SP)
+#define HNS_DSAF_IS_DEBUG(dev) ((dev)->dsaf_mode == DSAF_MODE_DISABLE_SP)
 
 enum hal_dsaf_mode {
 	HRD_DSAF_NO_DSAF_MODE	= 0x0,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 9b66057..c20a0f4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -471,7 +471,6 @@ static void hns_rcb_ring_pair_get_cfg(struct ring_pair_cb *ring_pair_cb)
 static int hns_rcb_get_port_in_comm(
 	struct rcb_common_cb *rcb_common, int ring_idx)
 {
-
 	return ring_idx / (rcb_common->max_q_per_vf * rcb_common->max_vfn);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index e39c794..c6700b9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -512,7 +512,8 @@ static void hns_nic_reuse_page(struct sk_buff *skb, int i,
 	int last_offset;
 	bool twobufs;
 
-	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048);
+	twobufs = ((PAGE_SIZE < 8192) &&
+		hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048);
 
 	desc = &ring->desc[ring->next_to_clean];
 	size = le16_to_cpu(desc->rx.size);
@@ -922,8 +923,8 @@ static int is_valid_clean_head(struct hnae_ring *ring, int h)
 
 /* netif_tx_lock will turn down the performance, set only when necessary */
 #ifdef CONFIG_NET_POLL_CONTROLLER
-#define NETIF_TX_LOCK(ring) spin_lock(&ring->lock)
-#define NETIF_TX_UNLOCK(ring) spin_unlock(&ring->lock)
+#define NETIF_TX_LOCK(ring) spin_lock(&(ring)->lock)
+#define NETIF_TX_UNLOCK(ring) spin_unlock(&(ring)->lock)
 #else
 #define NETIF_TX_LOCK(ring)
 #define NETIF_TX_UNLOCK(ring)
@@ -2012,7 +2013,7 @@ static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
 static void hns_nic_service_event_complete(struct hns_nic_priv *priv)
 {
 	WARN_ON(!test_bit(NIC_STATE_SERVICE_SCHED, &priv->state));
-
+	/* make sure to commit the things */
 	smp_mb__before_atomic();
 	clear_bit(NIC_STATE_SERVICE_SCHED, &priv->state);
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 36f33bd..b8fab14 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1242,7 +1242,6 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
-- 
2.7.4
