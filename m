From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v1 5/5] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Wed, 31 Dec 2014 11:51:59 +0200
Message-ID: <1420019519-18139-6-git-send-email-vladz@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:32874 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbaLaJwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 04:52:17 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so26765334wib.5
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 01:52:16 -0800 (PST)
In-Reply-To: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 37 ++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index cc0e5b7..255bbc8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -792,6 +792,40 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static u32 ixgbevf_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return 128;
+}
+
+static u32 ixgbevf_get_rxfh_key_size(struct net_device *netdev)
+{
+	return 40;
+}
+
+static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			    u8 *hfunc)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	int err;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	if (indir) {
+		err = ixgbevf_get_reta(&adapter->hw, indir);
+		if (err)
+			return err;
+	}
+
+	if (key) {
+		err = ixgbevf_get_rss_key(&adapter->hw, key);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings           = ixgbevf_get_settings,
 	.get_drvinfo            = ixgbevf_get_drvinfo,
@@ -809,6 +843,9 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_ethtool_stats      = ixgbevf_get_ethtool_stats,
 	.get_coalesce           = ixgbevf_get_coalesce,
 	.set_coalesce           = ixgbevf_set_coalesce,
+	.get_rxfh_indir_size    = ixgbevf_get_rxfh_indir_size,
+	.get_rxfh_key_size      = ixgbevf_get_rxfh_key_size,
+	.get_rxfh		= ixgbevf_get_rxfh,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
-- 
2.1.0
