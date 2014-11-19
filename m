From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH 2/2] bonding: Introduce 4 AD link speed to fix agg_bandwidth
Date: Wed, 19 Nov 2014 16:48:59 +0800
Message-ID: <1416386939-24591-3-git-send-email-Jianhua.Xie@freescale.com>
References: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	Jianhua Xie <jianhua.xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0144.outbound.protection.outlook.com ([157.56.111.144]:48160
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753871AbaKSIue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 03:50:34 -0500
In-Reply-To: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

This patch adds [2.5|20|40|56] Gbps enum definition, and fixes
aggregated bandwidth calculation based on above slave links.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6bc27d9..8baa87d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -88,7 +88,11 @@ enum ad_link_speed_type {
 	AD_LINK_SPEED_10MBPS,
 	AD_LINK_SPEED_100MBPS,
 	AD_LINK_SPEED_1000MBPS,
-	AD_LINK_SPEED_10000MBPS
+	AD_LINK_SPEED_2500MBPS,
+	AD_LINK_SPEED_10000MBPS,
+	AD_LINK_SPEED_20000MBPS,
+	AD_LINK_SPEED_40000MBPS,
+	AD_LINK_SPEED_56000MBPS
 };
 
 /* compare MAC addresses */
@@ -247,7 +251,11 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_10MBPS,
  *     %AD_LINK_SPEED_100MBPS,
  *     %AD_LINK_SPEED_1000MBPS,
+ *     %AD_LINK_SPEED_2500MBPS,
  *     %AD_LINK_SPEED_10000MBPS
+ *     %AD_LINK_SPEED_20000MBPS
+ *     %AD_LINK_SPEED_40000MBPS
+ *     %AD_LINK_SPEED_56000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -275,10 +283,26 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_1000MBPS;
 			break;
 
+		case SPEED_2500:
+			speed = AD_LINK_SPEED_2500MBPS;
+			break;
+
 		case SPEED_10000:
 			speed = AD_LINK_SPEED_10000MBPS;
 			break;
 
+		case SPEED_20000:
+			speed = AD_LINK_SPEED_20000MBPS;
+			break;
+
+		case SPEED_40000:
+			speed = AD_LINK_SPEED_40000MBPS;
+			break;
+
+		case SPEED_56000:
+			speed = AD_LINK_SPEED_56000MBPS;
+			break;
+
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
 			speed = 0;
@@ -639,9 +663,21 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
+		case AD_LINK_SPEED_2500MBPS:
+			bandwidth = aggregator->num_of_ports * 2500;
+			break;
 		case AD_LINK_SPEED_10000MBPS:
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
+		case AD_LINK_SPEED_20000MBPS:
+			bandwidth = aggregator->num_of_ports * 20000;
+			break;
+		case AD_LINK_SPEED_40000MBPS:
+			bandwidth = aggregator->num_of_ports * 40000;
+			break;
+		case AD_LINK_SPEED_56000MBPS:
+			bandwidth = aggregator->num_of_ports * 56000;
+			break;
 		default:
 			bandwidth = 0; /* to silence the compiler */
 		}
-- 
2.1.0.27.g96db324
