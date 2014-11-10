From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH v1 net-next 2/2] bonding: Introduce 4 AD link speed to fix agg_bandwidth
Date: Mon, 10 Nov 2014 15:16:41 +0800
Message-ID: <1415603801-21285-3-git-send-email-Jianhua.Xie@freescale.com>
References: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	Jianhua Xie <jianhua.xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0144.outbound.protection.outlook.com ([157.56.110.144]:52672
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752059AbaKJHSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 02:18:39 -0500
In-Reply-To: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

This patch adds 2.5Gbps/20Gbps/40Gbps/56Gbps bitmask micros, and
fixes aggregated bandwidth calculation based on 2.5Gbps/20Gbps/
40Gbps/56Gbps slave links.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 8e5ab5c..ee4fe05 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -87,7 +87,11 @@
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
-#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
+#define     AD_LINK_SPEED_BITMASK_2500MBPS    0x10
+#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x20
+#define     AD_LINK_SPEED_BITMASK_20000MBPS   0x40
+#define     AD_LINK_SPEED_BITMASK_40000MBPS   0x80
+#define     AD_LINK_SPEED_BITMASK_56000MBPS   0x100
 
 /* compare MAC addresses */
 #define MAC_ADDRESS_EQUAL(A, B)	\
@@ -245,7 +249,11 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_BITMASK_10MBPS,
  *     %AD_LINK_SPEED_BITMASK_100MBPS,
  *     %AD_LINK_SPEED_BITMASK_1000MBPS,
+ *     %AD_LINK_SPEED_BITMASK_2500MBPS,
  *     %AD_LINK_SPEED_BITMASK_10000MBPS
+ *     %AD_LINK_SPEED_BITMASK_20000MBPS
+ *     %AD_LINK_SPEED_BITMASK_40000MBPS
+ *     %AD_LINK_SPEED_BITMASK_56000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -273,10 +281,26 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_BITMASK_1000MBPS;
 			break;
 
+		case SPEED_2500:
+			speed = AD_LINK_SPEED_BITMASK_2500MBPS;
+			break;
+
 		case SPEED_10000:
 			speed = AD_LINK_SPEED_BITMASK_10000MBPS;
 			break;
 
+		case SPEED_20000:
+			speed = AD_LINK_SPEED_BITMASK_20000MBPS;
+			break;
+
+		case SPEED_40000:
+			speed = AD_LINK_SPEED_BITMASK_40000MBPS;
+			break;
+
+		case SPEED_56000:
+			speed = AD_LINK_SPEED_BITMASK_56000MBPS;
+			break;
+
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
 			speed = 0;
@@ -637,9 +661,21 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_BITMASK_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
+		case AD_LINK_SPEED_BITMASK_2500MBPS:
+			bandwidth = aggregator->num_of_ports * 2500;
+			break;
 		case AD_LINK_SPEED_BITMASK_10000MBPS:
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
+		case AD_LINK_SPEED_BITMASK_20000MBPS:
+			bandwidth = aggregator->num_of_ports * 20000;
+			break;
+		case AD_LINK_SPEED_BITMASK_40000MBPS:
+			bandwidth = aggregator->num_of_ports * 40000;
+			break;
+		case AD_LINK_SPEED_BITMASK_56000MBPS:
+			bandwidth = aggregator->num_of_ports * 56000;
+			break;
 		default:
 			bandwidth = 0; /* to silence the compiler */
 		}
-- 
2.1.0.27.g96db324
