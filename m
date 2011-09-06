From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/4] ethtool: Clean up definitions of rule
 location arrays in RX NFC
Date: Wed, 07 Sep 2011 00:49:12 +0100
Message-ID: <1315352952.12033.2.camel@bwh-desktop>
References: <1315352693.2788.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45592 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab1IFXtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:49:16 -0400
In-Reply-To: <1315352693.2788.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the description of ethtool_rxnfc::rule_locs; it is an array
of currently used locations, not all possible valid locations.

Add note that drivers must not use ethtool_rxnfc::rule_locs.

The rule_locs argument to ethtool_ops::get_rxnfc is either NULL or a
pointer to an array of u32, so change the parameter type accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    5 ++---
 drivers/net/ethernet/sfc/ethtool.c                 |    2 +-
 drivers/net/ethernet/sun/niu.c                     |    4 ++--
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    2 +-
 include/linux/ethtool.h                            |    7 ++++---
 8 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 767c229..ce14f11 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2241,7 +2241,7 @@ static int bnx2x_set_phys_id(struct net_device *dev,
 }
 
 static int bnx2x_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
-			   void *rules __always_unused)
+			   u32 *rules __always_unused)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 90b4921..40b395f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1902,7 +1902,7 @@ static int set_rss_table(struct net_device *dev,
 }
 
 static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
-		     void *rules)
+		     u32 *rules)
 {
 	const struct port_info *pi = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 25a8c2a..4223830 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1712,7 +1712,7 @@ static int gfar_set_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 }
 
 static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-		void *rule_locs)
+		u32 *rule_locs)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	int ret = 0;
@@ -1728,7 +1728,7 @@ static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 		ret = gfar_get_cls(priv, cmd);
 		break;
 	case ETHTOOL_GRXCLSRLALL:
-		ret = gfar_get_cls_all(priv, cmd, (u32 *) rule_locs);
+		ret = gfar_get_cls_all(priv, cmd, rule_locs);
 		break;
 	default:
 		ret = -EINVAL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 82d4244..bad2d27 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2283,7 +2283,7 @@ static int ixgbe_get_ethtool_fdir_all(struct ixgbe_adapter *adapter,
 }
 
 static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-			   void *rule_locs)
+			   u32 *rule_locs)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int ret = -EOPNOTSUPP;
@@ -2301,8 +2301,7 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 		ret = ixgbe_get_ethtool_fdir_entry(adapter, cmd);
 		break;
 	case ETHTOOL_GRXCLSRLALL:
-		ret = ixgbe_get_ethtool_fdir_all(adapter, cmd,
-						 (u32 *)rule_locs);
+		ret = ixgbe_get_ethtool_fdir_all(adapter, cmd, rule_locs);
 		break;
 	default:
 		break;
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 93f1fb9..9536925 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -824,7 +824,7 @@ static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 
 static int
 efx_ethtool_get_rxnfc(struct net_device *net_dev,
-		      struct ethtool_rxnfc *info, void *rules __always_unused)
+		      struct ethtool_rxnfc *info, u32 *rules __always_unused)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 3c9ef1c..8037059 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -7306,7 +7306,7 @@ static int niu_get_ethtool_tcam_all(struct niu *np,
 }
 
 static int niu_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-		       void *rule_locs)
+		       u32 *rule_locs)
 {
 	struct niu *np = netdev_priv(dev);
 	int ret = 0;
@@ -7325,7 +7325,7 @@ static int niu_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 		ret = niu_get_ethtool_tcam_entry(np, cmd);
 		break;
 	case ETHTOOL_GRXCLSRLALL:
-		ret = niu_get_ethtool_tcam_all(np, cmd, (u32 *)rule_locs);
+		ret = niu_get_ethtool_tcam_all(np, cmd, rule_locs);
 		break;
 	default:
 		ret = -EINVAL;
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 27400ed..e662cbc 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -558,7 +558,7 @@ out:
 
 static int
 vmxnet3_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
-		  void *rules)
+		  u32 *rules)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	switch (info->cmd) {
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 58407e3..3df1f3b 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -479,7 +479,7 @@ struct ethtool_rx_flow_spec {
  * @data: Command-dependent value
  * @fs: Flow classification rule
  * @rule_cnt: Number of rules to be affected
- * @rule_locs: Array of valid rule locations
+ * @rule_locs: Array of used rule locations
  *
  * For %ETHTOOL_GRXFH and %ETHTOOL_SRXFH, @data is a bitmask indicating
  * the fields included in the flow hash, e.g. %RXH_IP_SRC.  The following
@@ -497,7 +497,8 @@ struct ethtool_rx_flow_spec {
  * For %ETHTOOL_GRXCLSRLALL, @rule_cnt specifies the array size of the
  * user buffer for @rule_locs on entry.  On return, @data is the size
  * of the rule table and @rule_locs contains the locations of the
- * defined rules.
+ * defined rules.  Drivers must use the second parameter to get_rxnfc()
+ * instead of @rule_locs.
  *
  * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
  * @fs.@location specifies the location to use and must not be ignored.
@@ -936,7 +937,7 @@ struct ethtool_ops {
 	int	(*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
 	int	(*get_rxnfc)(struct net_device *,
-			     struct ethtool_rxnfc *, void *);
+			     struct ethtool_rxnfc *, u32 *rule_locs);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
