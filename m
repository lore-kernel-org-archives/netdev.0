From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/26] bonding: add 802.3ad support for 100G speeds
Date: Tue,  1 Dec 2015 14:48:39 +0100
Message-ID: <1448977744-17930-2-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36099 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044AbbLANtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:09 -0500
Received: by wmww144 with SMTP id w144so173656954wmw.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:08 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to other speeds, add 100G to bonding 802.3ad code.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_3ad.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 940e2eb..4cbb8b2 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -93,7 +93,8 @@ enum ad_link_speed_type {
 	AD_LINK_SPEED_10000MBPS,
 	AD_LINK_SPEED_20000MBPS,
 	AD_LINK_SPEED_40000MBPS,
-	AD_LINK_SPEED_56000MBPS
+	AD_LINK_SPEED_56000MBPS,
+	AD_LINK_SPEED_100000MBPS,
 };
 
 /* compare MAC addresses */
@@ -258,6 +259,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  *     %AD_LINK_SPEED_20000MBPS
  *     %AD_LINK_SPEED_40000MBPS
  *     %AD_LINK_SPEED_56000MBPS
+ *     %AD_LINK_SPEED_100000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -305,6 +307,10 @@ static u16 __get_link_speed(struct port *port)
 			speed = AD_LINK_SPEED_56000MBPS;
 			break;
 
+		case SPEED_100000:
+			speed = AD_LINK_SPEED_100000MBPS;
+			break;
+
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
 			speed = 0;
@@ -681,6 +687,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 		case AD_LINK_SPEED_56000MBPS:
 			bandwidth = aggregator->num_of_ports * 56000;
 			break;
+		case AD_LINK_SPEED_100000MBPS:
+			bandwidth = aggregator->num_of_ports * 100000;
+			break;
 		default:
 			bandwidth = 0; /* to silence the compiler */
 		}
-- 
1.9.3
