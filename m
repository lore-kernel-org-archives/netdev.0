From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool v5 1/2] ethtool-copy.h:sync with net-next
Date: Thu, 24 Nov 2016 09:56:50 +0100
Message-ID: <1479977811-5603-2-git-send-email-allan.nielsen@microsemi.com>
References: <1479977811-5603-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linville@tuxdriver.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0057.outbound.protection.outlook.com ([104.47.40.57]:35760
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935768AbcKXI5M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 03:57:12 -0500
In-Reply-To: <1479977811-5603-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes upto:

commit 607c7029146790201e90b58c4235ddff0304d6e0
Author: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date:   Thu Nov 17 13:07:22 2016 +0100

    ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables

    For operation in cabling environments that are incompatible with
    1000BASE-T, PHY device may provide an automatic link speed downshift
    operation. When enabled, the device automatically changes its 1000BASE-T
    auto-negotiation to the next slower speed after a configured number of
    failed attempts at 1000BASE-T.  This feature is useful in setting up in
    networks using older cable installations that include only pairs A and B,
    and not pairs C and D.

    Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
    Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
    Reviewed-by: Andrew Lunn <andrew@lunn.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 ethtool-copy.h | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 70748f5..3d299e3 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -117,8 +117,7 @@ struct ethtool_cmd {
 static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
-
-	ep->speed = (__u16)speed;
+	ep->speed = (__u16)(speed & 0xFFFF);
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
@@ -247,6 +246,19 @@ struct ethtool_tunable {
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
@@ -547,6 +559,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
+ * @ETH_SS_PHY_TUNABLES: PHY tunable names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -557,6 +570,7 @@ enum ethtool_stringset {
 	ETH_SS_RSS_HASH_FUNCS,
 	ETH_SS_TUNABLES,
 	ETH_SS_PHY_STATS,
+	ETH_SS_PHY_TUNABLES,
 };
 
 /**
@@ -1312,7 +1326,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.7.3
