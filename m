From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH RFC net-next 5/5] bonding: Introduce 56Gbps AD link speed
Date: Thu, 6 Nov 2014 19:52:52 +0800
Message-ID: <1415274772-8029-6-git-send-email-Jianhua.Xie@freescale.com>
References: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	"Veaceslav Falico" <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0132.outbound.protection.outlook.com ([157.56.110.132]:31058
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751141AbaKFMKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 07:10:31 -0500
In-Reply-To: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

This patch inserts 56Gbps bitmask, fixes aggregated bandwidth
calculation based on 56Gbps slave links.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 065c4cc..32513dc 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -91,6 +91,7 @@
 #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x20
 #define     AD_LINK_SPEED_BITMASK_20000MBPS   0x40
 #define     AD_LINK_SPEED_BITMASK_40000MBPS   0x80
+#define     AD_LINK_SPEED_BITMASK_56000MBPS   0x100
 
 /* compare MAC addresses */
 #define MAC_ADDRESS_EQUAL(A, B)	\
@@ -252,6 +253,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_BITMASK_10000MBPS
  *     %AD_LINK_SPEED_BITMASK_20000MBPS
  *     %AD_LINK_SPEED_BITMASK_40000MBPS
+ *     %AD_LINK_SPEED_BITMASK_56000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -295,6 +297,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_BITMASK_40000MBPS;
 			break;
 
+		case SPEED_56000:
+			speed = AD_LINK_SPEED_BITMASK_56000MBPS;
+			break;
+
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
 			speed = 0;
@@ -667,6 +673,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_BITMASK_40000MBPS:
 			bandwidth = aggregator->num_of_ports * 40000;
 			break;
+		case AD_LINK_SPEED_BITMASK_56000MBPS:
+			bandwidth = aggregator->num_of_ports * 56000;
+			break;
 		default:
 			bandwidth = 0; /* to silence the compiler */
 		}
-- 
2.1.0.27.g96db324
