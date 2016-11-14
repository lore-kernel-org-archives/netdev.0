From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v2 1/2] ethtool-copy.h:sync with net
Date: Mon, 14 Nov 2016 10:29:46 +0100
Message-ID: <1479115787-1265-2-git-send-email-allan.nielsen@microsemi.com>
References: <1479115787-1265-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0074.outbound.protection.outlook.com ([104.47.38.74]:20629
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932176AbcKNJoe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 04:44:34 -0500
In-Reply-To: <1479115787-1265-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

This covers kernel changes upto:

commit f5a4732f85613b3fb43f8bc33a017e3db3b3605a
Author: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date:   Wed Nov 9 16:33:09 2016 +0530

    ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE

    For operation in cabling environments that are incompatible with 1000BAST-T,
    PHY device may provide an automatic link speed downshift operation. When
    enabled, the device automatically changes its 1000BAST-T auto-negotiation
    to the next slower speed after a configured number of failed attempts at
    1000BAST-T.
    This feature is useful in setting up in networks using older cable
    installations that include only pairs A and B, and not pairs C and D.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 ethtool-copy.h | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 70748f5..2e2448f 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -247,6 +247,19 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+#define DOWNSHIFT_DEV_DEFAULT_COUNT	0xff
+#define DOWNSHIFT_DEV_DISABLE		0
+
+enum phy_tunable_id {
+	ETHTOOL_PHY_ID_UNSPEC,
+	ETHTOOL_PHY_DOWNSHIFT,
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
@@ -547,6 +560,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
+ * @ETH_SS_PHY_TUNABLES: PHY tunable names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -557,6 +571,7 @@ enum ethtool_stringset {
 	ETH_SS_RSS_HASH_FUNCS,
 	ETH_SS_TUNABLES,
 	ETH_SS_PHY_STATS,
+	ETH_SS_PHY_TUNABLES,
 };
 
 /**
@@ -1312,7 +1327,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.7.3
