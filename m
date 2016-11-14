From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v2 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE
Date: Mon, 14 Nov 2016 10:29:16 +0100
Message-ID: <1479115760-1182-2-git-send-email-allan.nielsen@microsemi.com>
References: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0050.outbound.protection.outlook.com ([104.47.34.50]:10398
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752040AbcKNJ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 04:29:39 -0500
In-Reply-To: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Defines a generic API to get/set phy tunables. The API is using the
existing ethtool_tunable/tunable_type_id types which is already being used
for mac level tunables.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 include/uapi/linux/ethtool.h | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 8e54723..42f696f 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -248,6 +248,16 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+enum phy_tunable_id {
+	ETHTOOL_PHY_ID_UNSPEC,
+
+	/*
+	 * Add your fresh new phy tunable attribute above and remember to update
+	 * phy_tunable_strings[] in net/core/ethtool.c
+	 */
+	__ETHTOOL_PHY_TUNABLE_COUNT,
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -548,6 +558,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
+ * @ETH_SS_PHY_TUNABLES: PHY tunable names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -558,6 +569,7 @@ enum ethtool_stringset {
 	ETH_SS_RSS_HASH_FUNCS,
 	ETH_SS_TUNABLES,
 	ETH_SS_PHY_STATS,
+	ETH_SS_PHY_TUNABLES,
 };
 
 /**
@@ -1313,7 +1325,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.7.3
