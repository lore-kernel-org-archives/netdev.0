From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/3] bonding: fix 802.3ad support for 14G speed
Date: Thu,  8 Jun 2017 11:18:12 +0200
Message-ID: <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41410 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdFHJSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:18:48 -0400
In-Reply-To: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 14 Gbps enum definition, and fixes
aggregated bandwidth calculation based on above slave links.

Fixes: 0d7e2d2166f6 ("IB/ipoib: add get_link_ksettings in ethtool")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/bonding/bond_3ad.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index d1b09be63ba4..e5386ab706ec 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -92,6 +92,7 @@ enum ad_link_speed_type {
 	AD_LINK_SPEED_2500MBPS,
 	AD_LINK_SPEED_5000MBPS,
 	AD_LINK_SPEED_10000MBPS,
+	AD_LINK_SPEED_14000MBPS,
 	AD_LINK_SPEED_20000MBPS,
 	AD_LINK_SPEED_25000MBPS,
 	AD_LINK_SPEED_40000MBPS,
@@ -263,6 +264,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_2500MBPS,
  *     %AD_LINK_SPEED_5000MBPS,
  *     %AD_LINK_SPEED_10000MBPS
+ *     %AD_LINK_SPEED_14000MBPS,
  *     %AD_LINK_SPEED_20000MBPS
  *     %AD_LINK_SPEED_25000MBPS
  *     %AD_LINK_SPEED_40000MBPS
@@ -308,6 +310,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_10000MBPS;
 			break;
 
+		case SPEED_14000:
+			speed = AD_LINK_SPEED_14000MBPS;
+			break;
+
 		case SPEED_20000:
 			speed = AD_LINK_SPEED_20000MBPS;
 			break;
@@ -725,6 +731,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_10000MBPS:
 			bandwidth = nports * 10000;
 			break;
+		case AD_LINK_SPEED_14000MBPS:
+			bandwidth = nports * 14000;
+			break;
 		case AD_LINK_SPEED_20000MBPS:
 			bandwidth = nports * 20000;
 			break;
-- 
2.8.1
