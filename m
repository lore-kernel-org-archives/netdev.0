From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/3] bonding: fix 802.3ad support for 5G and 50G speeds
Date: Thu,  8 Jun 2017 11:18:11 +0200
Message-ID: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41408 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751422AbdFHJSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:18:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thibaut Collet <thibaut.collet@6wind.com>

This patch adds [5|50] Gbps enum definition, and fixes
aggregated bandwidth calculation based on above slave links.

Fixes: c9a70d43461d ("net-next: ethtool: Added port speed macros.")
Signed-off-by: Thibaut Collet <thibaut.collet@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/bonding/bond_3ad.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b44a6aeb346d..d1b09be63ba4 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -90,10 +90,12 @@ enum ad_link_speed_type {
 	AD_LINK_SPEED_100MBPS,
 	AD_LINK_SPEED_1000MBPS,
 	AD_LINK_SPEED_2500MBPS,
+	AD_LINK_SPEED_5000MBPS,
 	AD_LINK_SPEED_10000MBPS,
 	AD_LINK_SPEED_20000MBPS,
 	AD_LINK_SPEED_25000MBPS,
 	AD_LINK_SPEED_40000MBPS,
+	AD_LINK_SPEED_50000MBPS,
 	AD_LINK_SPEED_56000MBPS,
 	AD_LINK_SPEED_100000MBPS,
 };
@@ -259,10 +261,12 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_100MBPS,
  *     %AD_LINK_SPEED_1000MBPS,
  *     %AD_LINK_SPEED_2500MBPS,
+ *     %AD_LINK_SPEED_5000MBPS,
  *     %AD_LINK_SPEED_10000MBPS
  *     %AD_LINK_SPEED_20000MBPS
  *     %AD_LINK_SPEED_25000MBPS
  *     %AD_LINK_SPEED_40000MBPS
+ *     %AD_LINK_SPEED_50000MBPS
  *     %AD_LINK_SPEED_56000MBPS
  *     %AD_LINK_SPEED_100000MBPS
  */
@@ -296,6 +300,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_2500MBPS;
 			break;
 
+		case SPEED_5000:
+			speed = AD_LINK_SPEED_5000MBPS;
+			break;
+
 		case SPEED_10000:
 			speed = AD_LINK_SPEED_10000MBPS;
 			break;
@@ -312,6 +320,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_40000MBPS;
 			break;
 
+		case SPEED_50000:
+			speed = AD_LINK_SPEED_50000MBPS;
+			break;
+
 		case SPEED_56000:
 			speed = AD_LINK_SPEED_56000MBPS;
 			break;
@@ -707,6 +719,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_2500MBPS:
 			bandwidth = nports * 2500;
 			break;
+		case AD_LINK_SPEED_5000MBPS:
+			bandwidth = nports * 5000;
+			break;
 		case AD_LINK_SPEED_10000MBPS:
 			bandwidth = nports * 10000;
 			break;
@@ -719,6 +734,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_40000MBPS:
 			bandwidth = nports * 40000;
 			break;
+		case AD_LINK_SPEED_50000MBPS:
+			bandwidth = nports * 50000;
+			break;
 		case AD_LINK_SPEED_56000MBPS:
 			bandwidth = nports * 56000;
 			break;
-- 
2.8.1
