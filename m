From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH RFC net-next 2/5] bonding: Introduce 2.5Gbps AD link speed
Date: Thu, 6 Nov 2014 19:52:49 +0800
Message-ID: <1415274772-8029-3-git-send-email-Jianhua.Xie@freescale.com>
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
Received: from mail-bn1on0138.outbound.protection.outlook.com ([157.56.110.138]:40992
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751021AbaKFMIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 07:08:44 -0500
In-Reply-To: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

This patch inserts 2500Mbps bitmask, fixes aggregated bandwidth
calculation based on 2.5Gbps slave links.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 15821f3..250232e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -87,7 +87,8 @@
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
-#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
+#define     AD_LINK_SPEED_BITMASK_2500MBPS    0x10
+#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x20
 
 /* compare MAC addresses */
 #define MAC_ADDRESS_EQUAL(A, B)	\
@@ -245,6 +246,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_BITMASK_10MBPS,
  *     %AD_LINK_SPEED_BITMASK_100MBPS,
  *     %AD_LINK_SPEED_BITMASK_1000MBPS,
+ *     %AD_LINK_SPEED_BITMASK_2500MBPS,
  *     %AD_LINK_SPEED_BITMASK_10000MBPS
  */
 static u16 __get_link_speed(struct port *port)
@@ -273,6 +275,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_BITMASK_1000MBPS;
 			break;
 
+		case SPEED_2500:
+			speed = AD_LINK_SPEED_BITMASK_2500MBPS;
+			break;
+
 		case SPEED_10000:
 			speed = AD_LINK_SPEED_BITMASK_10000MBPS;
 			break;
@@ -637,6 +643,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_BITMASK_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
+		case AD_LINK_SPEED_BITMASK_2500MBPS:
+			bandwidth = aggregator->num_of_ports * 2500;
+			break;
 		case AD_LINK_SPEED_BITMASK_10000MBPS:
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
-- 
2.1.0.27.g96db324
