From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 2/7] net: hns3: Add hns3_get_handle macro in hns3 driver
Date: Mon, 9 Oct 2017 15:43:56 +0800
Message-ID: <1507535041-204956-3-git-send-email-linyunsheng@huawei.com>
References: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are many places that will need to get the handle
of netdev, so add a macro to get the handle of netdev.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c    | 18 ++++------
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 39 ++++++++--------------
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  3 ++
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 38 ++++++++-------------
 4 files changed, 35 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c
index 9832172..925619a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c
@@ -13,8 +13,7 @@
 static
 int hns3_dcbnl_ieee_getets(struct net_device *ndev, struct ieee_ets *ets)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->ieee_getets)
 		return h->kinfo.dcb_ops->ieee_getets(h, ets);
@@ -25,8 +24,7 @@ int hns3_dcbnl_ieee_getets(struct net_device *ndev, struct ieee_ets *ets)
 static
 int hns3_dcbnl_ieee_setets(struct net_device *ndev, struct ieee_ets *ets)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->ieee_setets)
 		return h->kinfo.dcb_ops->ieee_setets(h, ets);
@@ -37,8 +35,7 @@ int hns3_dcbnl_ieee_setets(struct net_device *ndev, struct ieee_ets *ets)
 static
 int hns3_dcbnl_ieee_getpfc(struct net_device *ndev, struct ieee_pfc *pfc)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->ieee_getpfc)
 		return h->kinfo.dcb_ops->ieee_getpfc(h, pfc);
@@ -49,8 +46,7 @@ int hns3_dcbnl_ieee_getpfc(struct net_device *ndev, struct ieee_pfc *pfc)
 static
 int hns3_dcbnl_ieee_setpfc(struct net_device *ndev, struct ieee_pfc *pfc)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->ieee_setpfc)
 		return h->kinfo.dcb_ops->ieee_setpfc(h, pfc);
@@ -61,8 +57,7 @@ int hns3_dcbnl_ieee_setpfc(struct net_device *ndev, struct ieee_pfc *pfc)
 /* DCBX configuration */
 static u8 hns3_dcbnl_getdcbx(struct net_device *ndev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->getdcbx)
 		return h->kinfo.dcb_ops->getdcbx(h);
@@ -73,8 +68,7 @@ static u8 hns3_dcbnl_getdcbx(struct net_device *ndev)
 /* return 0 if successful, otherwise fail */
 static u8 hns3_dcbnl_setdcbx(struct net_device *ndev, u8 mode)
 {
-	struct hns3_nic_priv *priv = netdev_priv(ndev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(ndev);
 
 	if (h->kinfo.dcb_ops->setdcbx)
 		return h->kinfo.dcb_ops->setdcbx(h, mode);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index c315065..c2a0537 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -198,8 +198,7 @@ static void hns3_vector_gl_rl_init(struct hns3_enet_tqp_vector *tqp_vector)
 
 static int hns3_nic_set_real_num_queue(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	struct hnae3_knic_private_info *kinfo = &h->kinfo;
 	unsigned int queue_size = kinfo->rss_size * kinfo->num_tc;
 	int ret;
@@ -307,8 +306,7 @@ static int hns3_nic_net_stop(struct net_device *netdev)
 
 void hns3_set_multicast_list(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	struct netdev_hw_addr *ha = NULL;
 
 	if (h->ae_algo->ops->set_mc_addr) {
@@ -321,8 +319,7 @@ void hns3_set_multicast_list(struct net_device *netdev)
 static int hns3_nic_uc_sync(struct net_device *netdev,
 			    const unsigned char *addr)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo->ops->add_uc_addr)
 		return h->ae_algo->ops->add_uc_addr(h, addr);
@@ -333,8 +330,7 @@ static int hns3_nic_uc_sync(struct net_device *netdev,
 static int hns3_nic_uc_unsync(struct net_device *netdev,
 			      const unsigned char *addr)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo->ops->rm_uc_addr)
 		return h->ae_algo->ops->rm_uc_addr(h, addr);
@@ -345,8 +341,7 @@ static int hns3_nic_uc_unsync(struct net_device *netdev,
 static int hns3_nic_mc_sync(struct net_device *netdev,
 			    const unsigned char *addr)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo->ops->add_mc_addr)
 		return h->ae_algo->ops->add_mc_addr(h, addr);
@@ -357,8 +352,7 @@ static int hns3_nic_mc_sync(struct net_device *netdev,
 static int hns3_nic_mc_unsync(struct net_device *netdev,
 			      const unsigned char *addr)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo->ops->rm_mc_addr)
 		return h->ae_algo->ops->rm_mc_addr(h, addr);
@@ -368,8 +362,7 @@ static int hns3_nic_mc_unsync(struct net_device *netdev,
 
 void hns3_nic_set_rx_mode(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo->ops->set_promisc_mode) {
 		if (netdev->flags & IFF_PROMISC)
@@ -1025,8 +1018,7 @@ static netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb,
 
 static int hns3_nic_net_set_mac_address(struct net_device *netdev, void *p)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	struct sockaddr *mac_addr = p;
 	int ret;
 
@@ -1208,8 +1200,7 @@ static void hns3_nic_udp_tunnel_del(struct net_device *netdev,
 
 static int hns3_setup_tc(struct net_device *netdev, u8 tc)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	struct hnae3_knic_private_info *kinfo = &h->kinfo;
 	unsigned int i;
 	int ret;
@@ -1259,8 +1250,7 @@ static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
 static int hns3_vlan_rx_add_vid(struct net_device *netdev,
 				__be16 proto, u16 vid)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	int ret = -EIO;
 
 	if (h->ae_algo->ops->set_vlan_filter)
@@ -1272,8 +1262,7 @@ static int hns3_vlan_rx_add_vid(struct net_device *netdev,
 static int hns3_vlan_rx_kill_vid(struct net_device *netdev,
 				 __be16 proto, u16 vid)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	int ret = -EIO;
 
 	if (h->ae_algo->ops->set_vlan_filter)
@@ -1285,8 +1274,7 @@ static int hns3_vlan_rx_kill_vid(struct net_device *netdev,
 static int hns3_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
 				u8 qos, __be16 vlan_proto)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	int ret = -EIO;
 
 	if (h->ae_algo->ops->set_vf_vlan_filter)
@@ -1298,8 +1286,7 @@ static int hns3_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
 
 static int hns3_nic_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	bool if_running = netif_running(netdev);
 	int ret;
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index 481eada..dd8d40c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -587,6 +587,9 @@ static inline void hns3_write_reg(void __iomem *base, u32 reg, u32 value)
 #define hns3_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos; pos = pos->next)
 
+#define hns3_get_handle(ndev) \
+	(((struct hns3_nic_priv *)netdev_priv(ndev))->ae_handle)
+
 void hns3_ethtool_set_ops(struct net_device *netdev);
 
 int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index d636399..a892a15 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -102,8 +102,7 @@ static void hns3_driv_to_eth_caps(u32 caps, struct ethtool_link_ksettings *cmd,
 
 static int hns3_get_sset_count(struct net_device *netdev, int stringset)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	const struct hnae3_ae_ops *ops = h->ae_algo->ops;
 
 	if (!ops->get_sset_count)
@@ -164,8 +163,7 @@ static u8 *hns3_get_strings_tqps(struct hnae3_handle *handle, u8 *data)
 
 static void hns3_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	const struct hnae3_ae_ops *ops = h->ae_algo->ops;
 	char *buff = (char *)data;
 
@@ -220,8 +218,7 @@ static u64 *hns3_get_stats_tqps(struct hnae3_handle *handle, u64 *data)
 void hns3_get_stats(struct net_device *netdev, struct ethtool_stats *stats,
 		    u64 *data)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	u64 *p = data;
 
 	if (!h->ae_algo->ops->get_stats || !h->ae_algo->ops->update_stats) {
@@ -262,10 +259,7 @@ static void hns3_get_drvinfo(struct net_device *netdev,
 
 static u32 hns3_get_link(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h;
-
-	h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo && h->ae_algo->ops && h->ae_algo->ops->get_status)
 		return h->ae_algo->ops->get_status(h);
@@ -277,7 +271,8 @@ static void hns3_get_ringparam(struct net_device *netdev,
 			       struct ethtool_ringparam *param)
 {
 	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	int queue_num = priv->ae_handle->kinfo.num_tqps;
+	struct hnae3_handle *h = priv->ae_handle;
+	int queue_num = h->kinfo.num_tqps;
 
 	param->tx_max_pending = HNS3_RING_MAX_PENDING;
 	param->rx_max_pending = HNS3_RING_MAX_PENDING;
@@ -289,8 +284,7 @@ static void hns3_get_ringparam(struct net_device *netdev,
 static void hns3_get_pauseparam(struct net_device *netdev,
 				struct ethtool_pauseparam *param)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (h->ae_algo && h->ae_algo->ops && h->ae_algo->ops->get_pauseparam)
 		h->ae_algo->ops->get_pauseparam(h, &param->autoneg,
@@ -300,8 +294,7 @@ static void hns3_get_pauseparam(struct net_device *netdev,
 static int hns3_get_link_ksettings(struct net_device *netdev,
 				   struct ethtool_link_ksettings *cmd)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 	u32 supported_caps;
 	u32 advertised_caps;
 	u8 media_type = HNAE3_MEDIA_TYPE_UNKNOWN;
@@ -392,8 +385,7 @@ static int hns3_get_link_ksettings(struct net_device *netdev,
 
 static u32 hns3_get_rss_key_size(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (!h->ae_algo || !h->ae_algo->ops ||
 	    !h->ae_algo->ops->get_rss_key_size)
@@ -404,8 +396,7 @@ static u32 hns3_get_rss_key_size(struct net_device *netdev)
 
 static u32 hns3_get_rss_indir_size(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (!h->ae_algo || !h->ae_algo->ops ||
 	    !h->ae_algo->ops->get_rss_indir_size)
@@ -417,8 +408,7 @@ static u32 hns3_get_rss_indir_size(struct net_device *netdev)
 static int hns3_get_rss(struct net_device *netdev, u32 *indir, u8 *key,
 			u8 *hfunc)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->get_rss)
 		return -EOPNOTSUPP;
@@ -429,8 +419,7 @@ static int hns3_get_rss(struct net_device *netdev, u32 *indir, u8 *key,
 static int hns3_set_rss(struct net_device *netdev, const u32 *indir,
 			const u8 *key, const u8 hfunc)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->set_rss)
 		return -EOPNOTSUPP;
@@ -454,8 +443,7 @@ static int hns3_get_rxnfc(struct net_device *netdev,
 			  struct ethtool_rxnfc *cmd,
 			  u32 *rule_locs)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_handle *h = hns3_get_handle(netdev);
 
 	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->get_tc_size)
 		return -EOPNOTSUPP;
-- 
1.9.1
