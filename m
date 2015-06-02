From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 06/10] net: thunderx: add static
Date: Tue, 2 Jun 2015 11:00:23 -0700
Message-ID: <1433268028-23992-7-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes sparse messages like this:

drivers/net/ethernet/cavium/thunder/nicvf_main.c:1141:26: sparse: symbol
'nicvf_get_stats64' was not declared. Should it be static?

Also remove unused declarations

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |  2 --
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 28 ++++++++++------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  6 ++---
 4 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 6479ce2..a3b43e5 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -413,10 +413,8 @@ int nicvf_set_real_num_queues(struct net_device *netdev,
 int nicvf_open(struct net_device *netdev);
 int nicvf_stop(struct net_device *netdev);
 int nicvf_send_msg_to_pf(struct nicvf *vf, union nic_mbx *mbx);
-void nicvf_config_cpi(struct nicvf *nic);
 void nicvf_config_rss(struct nicvf *nic);
 void nicvf_set_rss_key(struct nicvf *nic);
-void nicvf_free_skb(struct nicvf *nic, struct sk_buff *skb);
 void nicvf_set_ethtool_ops(struct net_device *netdev);
 void nicvf_update_stats(struct nicvf *nic);
 void nicvf_update_lmac_stats(struct nicvf *nic);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 54bba86..02da802 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -50,10 +50,6 @@ module_param(cpi_alg, int, S_IRUGO);
 MODULE_PARM_DESC(cpi_alg,
 		 "PFC algorithm (0=none, 1=VLAN, 2=VLAN16, 3=IP Diffserv)");
 
-static int nicvf_enable_msix(struct nicvf *nic);
-static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev);
-static void nicvf_read_bgx_stats(struct nicvf *nic, struct bgx_stats_msg *bgx);
-
 static inline void nicvf_set_rx_frame_cnt(struct nicvf *nic,
 					  struct sk_buff *skb)
 {
@@ -174,6 +170,14 @@ static int nicvf_check_pf_ready(struct nicvf *nic)
 	return 1;
 }
 
+static void nicvf_read_bgx_stats(struct nicvf *nic, struct bgx_stats_msg *bgx)
+{
+	if (bgx->rx)
+		nic->bgx_stats.rx_stats[bgx->idx] = bgx->stats;
+	else
+		nic->bgx_stats.tx_stats[bgx->idx] = bgx->stats;
+}
+
 static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 {
 	union nic_mbx mbx = {};
@@ -255,7 +259,7 @@ static int nicvf_hw_set_mac_addr(struct nicvf *nic, struct net_device *netdev)
 	return nicvf_send_msg_to_pf(nic, &mbx);
 }
 
-void nicvf_config_cpi(struct nicvf *nic)
+static void nicvf_config_cpi(struct nicvf *nic)
 {
 	union nic_mbx mbx = {};
 
@@ -267,7 +271,7 @@ void nicvf_config_cpi(struct nicvf *nic)
 	nicvf_send_msg_to_pf(nic, &mbx);
 }
 
-void nicvf_get_rss_size(struct nicvf *nic)
+static void nicvf_get_rss_size(struct nicvf *nic)
 {
 	union nic_mbx mbx = {};
 
@@ -575,7 +579,7 @@ static int nicvf_poll(struct napi_struct *napi, int budget)
  *
  * As of now only CQ errors are handled
  */
-void nicvf_handle_qs_err(unsigned long data)
+static void nicvf_handle_qs_err(unsigned long data)
 {
 	struct nicvf *nic = (struct nicvf *)data;
 	struct queue_set *qs = nic->qs;
@@ -1043,14 +1047,6 @@ static int nicvf_set_mac_address(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static void nicvf_read_bgx_stats(struct nicvf *nic, struct bgx_stats_msg *bgx)
-{
-	if (bgx->rx)
-		nic->bgx_stats.rx_stats[bgx->idx] = bgx->stats;
-	else
-		nic->bgx_stats.tx_stats[bgx->idx] = bgx->stats;
-}
-
 void nicvf_update_lmac_stats(struct nicvf *nic)
 {
 	int stat = 0;
@@ -1141,7 +1137,7 @@ void nicvf_update_stats(struct nicvf *nic)
 		nicvf_update_sq_stats(nic, qidx);
 }
 
-struct rtnl_link_stats64 *nicvf_get_stats64(struct net_device *netdev,
+static struct rtnl_link_stats64 *nicvf_get_stats64(struct net_device *netdev,
 					    struct rtnl_link_stats64 *stats)
 {
 	struct nicvf *nic = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 1962466..7f0e108 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -228,7 +228,7 @@ static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 
 /* Refill receive buffer descriptors with new buffers.
  */
-void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
+static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 {
 	struct queue_set *qs = nic->qs;
 	int rbdr_idx = qs->rbdr_cnt;
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 83476f0..633ec05 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -52,7 +52,7 @@ struct bgx {
 	struct pci_dev		*pdev;
 };
 
-struct bgx *bgx_vnic[MAX_BGX_THUNDER];
+static struct bgx *bgx_vnic[MAX_BGX_THUNDER];
 static int lmac_count; /* Total no of LMACs in system */
 
 static int bgx_xaui_check_link(struct lmac *lmac);
@@ -253,7 +253,7 @@ static void bgx_sgmii_change_link_state(struct lmac *lmac)
 	bgx_reg_write(bgx, lmac->lmacid, BGX_CMRX_CFG, cmr_cfg);
 }
 
-void bgx_lmac_handler(struct net_device *netdev)
+static void bgx_lmac_handler(struct net_device *netdev)
 {
 	struct lmac *lmac = container_of(netdev, struct lmac, netdev);
 	struct phy_device *phydev = lmac->phydev;
@@ -655,7 +655,7 @@ static int bgx_lmac_enable(struct bgx *bgx, u8 lmacid)
 	return 0;
 }
 
-void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
+static void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
 {
 	struct lmac *lmac;
 	u64 cmrx_cfg;
-- 
2.4.1
