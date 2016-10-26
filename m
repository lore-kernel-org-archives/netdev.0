From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: hns: mark symbols static where possible
Date: Wed, 26 Oct 2016 17:42:48 +0800
Message-ID: <1477474968-13123-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        baoyou.xie@linaro.org, xie.baoyou@zte.com.cn, han.fei@zte.com.cn,
        tang.qiang007@zte.com.cn
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com, fabf@skynet.be,
        xieqianqian@huawei.com, lipeng321@huawei.com,
        colin.king@canonical.com, weiyongjun1@huawei.com,
        oulijun@huawei.com, vinod.koul@intel.com, arnd@arndb.de,
        andrew@lunn.ch, tremyfr@gmail.com, xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a few warnings when building kernel with W=1:
drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:76:21: warning: no previous prototype for 'hns_ae_get_handle' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:274:6: warning: no previous prototype for 'hns_ae_stop' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c:330:6: warning: no previous prototype for 'hns_gmac_update_stats' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c:885:13: warning: no previous prototype for 'hns_mac_get_vaddr' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hns/hns_ethtool.c:679:6: warning: no previous prototype for 'hns_get_ringparam' [-Wmissing-prototypes]
....

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
So this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 30 +++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  8 +++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  7 ++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 11 ++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  7 ++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  4 +--
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 13 +++++-----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 24 +++++++++--------
 10 files changed, 58 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index e28d960..a1150e9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -73,8 +73,8 @@ static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
 	return container_of(q, struct ring_pair_cb, q);
 }
 
-struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
-				      u32 port_id)
+static struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
+					     u32 port_id)
 {
 	int vfnum_per_port;
 	int qnum_per_vf;
@@ -271,7 +271,7 @@ static int hns_ae_start(struct hnae_handle *handle)
 	return 0;
 }
 
-void hns_ae_stop(struct hnae_handle *handle)
+static void hns_ae_stop(struct hnae_handle *handle)
 {
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
 
@@ -299,7 +299,7 @@ static void hns_ae_reset(struct hnae_handle *handle)
 	}
 }
 
-void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
+static void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 {
 	u32 flag;
 
@@ -487,8 +487,8 @@ static void hns_ae_get_coalesce_range(struct hnae_handle *handle,
 	*rx_usecs_high  = HNS_RCB_MAX_COALESCED_USECS;
 }
 
-void hns_ae_update_stats(struct hnae_handle *handle,
-			 struct net_device_stats *net_stats)
+static void hns_ae_update_stats(struct hnae_handle *handle,
+				struct net_device_stats *net_stats)
 {
 	int port;
 	int idx;
@@ -570,7 +570,7 @@ void hns_ae_update_stats(struct hnae_handle *handle,
 	net_stats->multicast = mac_cb->hw_stats.rx_mc_pkts;
 }
 
-void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
+static void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
 {
 	int idx;
 	struct hns_mac_cb *mac_cb;
@@ -602,8 +602,8 @@ void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
 		hns_dsaf_get_stats(vf_cb->dsaf_dev, p, vf_cb->port_index);
 }
 
-void hns_ae_get_strings(struct hnae_handle *handle,
-			u32 stringset, u8 *data)
+static void hns_ae_get_strings(struct hnae_handle *handle,
+			       u32 stringset, u8 *data)
 {
 	int port;
 	int idx;
@@ -635,7 +635,7 @@ void hns_ae_get_strings(struct hnae_handle *handle,
 		hns_dsaf_get_strings(stringset, p, port, dsaf_dev);
 }
 
-int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
+static int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
 {
 	u32 sset_count = 0;
 	struct hns_mac_cb *mac_cb;
@@ -684,7 +684,7 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 	return ret;
 }
 
-void hns_ae_update_led_status(struct hnae_handle *handle)
+static void hns_ae_update_led_status(struct hnae_handle *handle)
 {
 	struct hns_mac_cb *mac_cb;
 
@@ -695,8 +695,8 @@ void hns_ae_update_led_status(struct hnae_handle *handle)
 	hns_set_led_opt(mac_cb);
 }
 
-int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
-			   enum hnae_led_state status)
+static int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
+				  enum hnae_led_state status)
 {
 	struct hns_mac_cb *mac_cb;
 
@@ -707,7 +707,7 @@ int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
 	return hns_cpld_led_set_id(mac_cb, status);
 }
 
-void hns_ae_get_regs(struct hnae_handle *handle, void *data)
+static void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 {
 	u32 *p = data;
 	int i;
@@ -732,7 +732,7 @@ void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 		hns_dsaf_get_regs(vf_cb->dsaf_dev, vf_cb->port_index, p);
 }
 
-int hns_ae_get_regs_len(struct hnae_handle *handle)
+static int hns_ae_get_regs_len(struct hnae_handle *handle)
 {
 	u32 total_num;
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 1e1eb92..f0c63c8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -327,7 +327,7 @@ static void hns_gmac_init(void *mac_drv)
 		hns_gmac_set_uc_match(mac_drv, 0);
 }
 
-void hns_gmac_update_stats(void *mac_drv)
+static void hns_gmac_update_stats(void *mac_drv)
 {
 	struct mac_hw_stats *hw_stats = NULL;
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 22e1410..657b975 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -882,8 +882,9 @@ static int hns_mac_get_mode(phy_interface_t phy_if)
 	}
 }
 
-u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
-			      struct hns_mac_cb *mac_cb, u32 mac_mode_idx)
+static u8 __iomem *
+hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
+		  struct hns_mac_cb *mac_cb, u32 mac_mode_idx)
 {
 	u8 __iomem *base = dsaf_dev->io_base;
 	int mac_id = mac_cb->mac_id;
@@ -901,7 +902,8 @@ u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
  * @mac_cb: mac control block
  * return 0 - success , negative --fail
  */
-int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
+static int
+hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 {
 	int ret;
 	u32 mac_mode_idx;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 66b99d2..fb0eb6b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -42,7 +42,7 @@ static const struct acpi_device_id hns_dsaf_acpi_match[] = {
 };
 MODULE_DEVICE_TABLE(acpi, hns_dsaf_acpi_match);
 
-int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
+static int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 {
 	int ret, i;
 	u32 desc_num;
@@ -2085,8 +2085,9 @@ static void hns_dsaf_pfc_unit_cnt(struct dsaf_device *dsaf_dev, int  mac_id,
  * @dsaf_id: dsa fabric id
  * @xge_ge_work_mode
  */
-void hns_dsaf_port_work_rate_cfg(struct dsaf_device *dsaf_dev, int mac_id,
-				 enum dsaf_port_rate_mode rate_mode)
+static void
+hns_dsaf_port_work_rate_cfg(struct dsaf_device *dsaf_dev, int mac_id,
+			    enum dsaf_port_rate_mode rate_mode)
 {
 	u32 port_work_mode;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 67accce..9dbba66 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -243,7 +243,8 @@ static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
  * bit18-19 for com/dfx
  * @enable: false - request reset , true - drop reset
  */
-void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
+static void
+hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
 {
 	u32 reg_addr;
 
@@ -265,7 +266,7 @@ void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
  * bit18-19 for com/dfx
  * @enable: false - request reset , true - drop reset
  */
-void
+static void
 hns_dsaf_srst_chns_acpi(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
 {
 	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
@@ -273,7 +274,7 @@ hns_dsaf_srst_chns_acpi(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
 				   msk, dereset);
 }
 
-void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool dereset)
+static void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool dereset)
 {
 	if (!dereset) {
 		dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_ROCEE_RESET_REQ_REG, 1);
@@ -287,7 +288,7 @@ void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool dereset)
 	}
 }
 
-void hns_dsaf_roce_srst_acpi(struct dsaf_device *dsaf_dev, bool dereset)
+static void hns_dsaf_roce_srst_acpi(struct dsaf_device *dsaf_dev, bool dereset)
 {
 	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
 				   HNS_ROCE_RESET_FUNC, 0, dereset);
@@ -479,7 +480,7 @@ static phy_interface_t hns_mac_get_phy_if_acpi(struct hns_mac_cb *mac_cb)
 	return phy_if;
 }
 
-int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
+static int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
 {
 	if (!mac_cb->cpld_ctrl)
 		return -ENODEV;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 6ea8722..04e674c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -73,7 +73,7 @@ hns_ppe_common_get_ioaddr(struct ppe_common_cb *ppe_common)
  * comm_index: common index
  * retuen 0 - success , negative --fail
  */
-int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
+static int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 {
 	struct ppe_common_cb *ppe_common;
 	int ppe_num;
@@ -104,7 +104,8 @@ int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 	return 0;
 }
 
-void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
+static void
+hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
 {
 	dsaf_dev->ppe_common[comm_index] = NULL;
 }
@@ -337,7 +338,7 @@ static void hns_ppe_uninit_hw(struct hns_ppe_cb *ppe_cb)
 	}
 }
 
-void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
+static void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
 {
 	u32 i;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index ef11077..ded4506 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -612,7 +612,7 @@ void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, u16 *max_vfn,
 	}
 }
 
-int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
+static int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 {
 	switch (dsaf_dev->dsaf_mode) {
 	case DSAF_MODE_ENABLE_FIX:
@@ -648,7 +648,7 @@ int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 	}
 }
 
-void __iomem *hns_rcb_common_get_vaddr(struct rcb_common_cb *rcb_common)
+static void __iomem *hns_rcb_common_get_vaddr(struct rcb_common_cb *rcb_common)
 {
 	struct dsaf_device *dsaf_dev = rcb_common->dsaf_dev;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index 8f4f0e8..3198890 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -306,7 +306,7 @@ static void hns_xgmac_config_max_frame_length(void *mac_drv, u16 newval)
 	dsaf_write_dev(drv, XGMAC_MAC_MAX_PKT_SIZE_REG, newval);
 }
 
-void hns_xgmac_update_stats(void *mac_drv)
+static void hns_xgmac_update_stats(void *mac_drv)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
 	struct mac_hw_stats *hw_stats = &drv->mac_cb->hw_stats;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 059aaed..e5f956c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1082,7 +1082,7 @@ static int hns_nic_net_set_mac_address(struct net_device *ndev, void *p)
 	return 0;
 }
 
-void hns_nic_update_stats(struct net_device *netdev)
+static void hns_nic_update_stats(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1369,7 +1369,7 @@ static int hns_nic_do_ioctl(struct net_device *netdev, struct ifreq *ifr,
 
 /* use only for netconsole to poll with the device without interrupt */
 #ifdef CONFIG_NET_POLL_CONTROLLER
-void hns_nic_poll_controller(struct net_device *ndev)
+static void hns_nic_poll_controller(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	unsigned long flags;
@@ -1482,7 +1482,7 @@ static netdev_features_t hns_nic_fix_features(
  *
  * return void
  */
-void hns_set_multicast_list(struct net_device *ndev)
+static void hns_set_multicast_list(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1500,7 +1500,7 @@ void hns_set_multicast_list(struct net_device *ndev)
 	}
 }
 
-void hns_nic_set_rx_mode(struct net_device *ndev)
+static void hns_nic_set_rx_mode(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1515,8 +1515,9 @@ void hns_nic_set_rx_mode(struct net_device *ndev)
 	hns_set_multicast_list(ndev);
 }
 
-struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
-					      struct rtnl_link_stats64 *stats)
+static struct rtnl_link_stats64 *
+hns_nic_get_stats64(struct net_device *ndev,
+		    struct rtnl_link_stats64 *stats)
 {
 	int idx = 0;
 	u64 tx_bytes = 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 47e59bb..7c06436 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -676,8 +676,8 @@ static void hns_nic_get_drvinfo(struct net_device *net_dev,
  * @dev: net device
  * @param: ethtool parameter
  */
-void hns_get_ringparam(struct net_device *net_dev,
-		       struct ethtool_ringparam *param)
+static void hns_get_ringparam(struct net_device *net_dev,
+			      struct ethtool_ringparam *param)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
@@ -825,7 +825,8 @@ static int hns_set_coalesce(struct net_device *net_dev,
  * @dev: net device
  * @ch: channel info.
  */
-void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
+static void
+hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 
@@ -842,8 +843,8 @@ void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
  * @stats: statistics info.
  * @data: statistics data.
  */
-void hns_get_ethtool_stats(struct net_device *netdev,
-			   struct ethtool_stats *stats, u64 *data)
+static void hns_get_ethtool_stats(struct net_device *netdev,
+				  struct ethtool_stats *stats, u64 *data)
 {
 	u64 *p = data;
 	struct hns_nic_priv *priv = netdev_priv(netdev);
@@ -900,7 +901,7 @@ void hns_get_ethtool_stats(struct net_device *netdev,
  * @stats: string set ID.
  * @data: objects data.
  */
-void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+static void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -990,7 +991,7 @@ void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
  *
  * Return string set count.
  */
-int hns_get_sset_count(struct net_device *netdev, int stringset)
+static int hns_get_sset_count(struct net_device *netdev, int stringset)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1022,7 +1023,7 @@ int hns_get_sset_count(struct net_device *netdev, int stringset)
  *
  * Return 0 on success, negative on failure.
  */
-int hns_phy_led_set(struct net_device *netdev, int value)
+static int hns_phy_led_set(struct net_device *netdev, int value)
 {
 	int retval;
 	struct phy_device *phy_dev = netdev->phydev;
@@ -1044,7 +1045,8 @@ int hns_phy_led_set(struct net_device *netdev, int value)
  *
  * Return 0 on success, negative on failure.
  */
-int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
+static int
+hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1118,8 +1120,8 @@ int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
  * @cmd: ethtool cmd
  * @date: register data
  */
-void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
-		  void *data)
+static void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
+			 void *data)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_ae_ops *ops;
-- 
2.7.4
