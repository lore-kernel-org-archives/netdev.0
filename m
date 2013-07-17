From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Subject: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Wed, 17 Jul 2013 09:50:06 +0300
Message-ID: <1374043806-17284-2-git-send-email-laura.vasilescu@rosedu.org>
References: <1374043806-17284-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: jeffrey.t.kirsher@intel.com, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:49254 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3GQGuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 02:50:23 -0400
Received: by mail-qa0-f45.google.com with SMTP id ci6so2778816qab.18
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 23:50:23 -0700 (PDT)
In-Reply-To: <1374043806-17284-1-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   32 ++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 85fe7b5..7e18dfa 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2771,6 +2771,35 @@ static void igb_ethtool_complete(struct net_device *netdev)
 	pm_runtime_put(&adapter->pdev->dev);
 }
 
+static u32 igb_get_rss_table_size(struct net_device *netdev)
+{
+	return IGB_RETA_SIZE;
+}
+
+static int igb_get_rss_table(struct net_device *netdev, u32 *rxfh_indir_tbl)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+
+	for (i = 0; i < IGB_RETA_SIZE; i++)
+		rxfh_indir_tbl[i] = rd32(E1000_RETA(i));
+
+	return 0;
+}
+
+static int igb_set_rss_table(struct net_device *netdev, const u32 *rxfh_indir_tbl)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+
+	for (i = 0; i < IGB_RETA_SIZE; i++)
+		wr32(E1000_RETA(i), rxfh_indir_tbl[i]);
+
+	return 0;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings		= igb_get_settings,
 	.set_settings		= igb_set_settings,
@@ -2804,6 +2833,9 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_eee		= igb_set_eee,
 	.get_module_info	= igb_get_module_info,
 	.get_module_eeprom	= igb_get_module_eeprom,
+	.get_rxfh_indir_size	= igb_get_rss_table_size,
+	.get_rxfh_indir		= igb_get_rss_table,
+	.set_rxfh_indir		= igb_set_rss_table,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
 };
-- 
1.7.10.4
