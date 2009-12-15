From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH] bcm63xx_enet: fix compilation failure after get_stats_count removal
Date: Tue, 15 Dec 2009 17:45:06 +0100
Message-ID: <200912151745.06131.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, David Miller <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:58803 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbZLOQwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 11:52:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This build failure is present in both 2.6.32 and net-next-2.6. Thanks!
---
From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH] bcm63xx_enet: fix compilation failure after get_stats_count removal

This patch converts bcm63xx_enet to uset get_sset_count
like the other drivers do.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
Cc: stable@kernel.org
---
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 1f6c548..0bd47d3 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -1245,9 +1245,15 @@ static void bcm_enet_get_drvinfo(struct net_device *netdev,
 	drvinfo->n_stats = BCM_ENET_STATS_LEN;
 }
 
-static int bcm_enet_get_stats_count(struct net_device *netdev)
+static int bcm_enet_get_sset_count(struct net_device *netdev,
+					int string_set)
 {
-	return BCM_ENET_STATS_LEN;
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return BCM_ENET_STATS_LEN;
+	default:
+		return -EINVAL;
+	}
 }
 
 static void bcm_enet_get_strings(struct net_device *netdev,
@@ -1473,7 +1479,7 @@ static int bcm_enet_set_pauseparam(struct net_device *dev,
 
 static struct ethtool_ops bcm_enet_ethtool_ops = {
 	.get_strings		= bcm_enet_get_strings,
-	.get_stats_count	= bcm_enet_get_stats_count,
+	.get_sset_count		= bcm_enet_get_sset_count,
 	.get_ethtool_stats      = bcm_enet_get_ethtool_stats,
 	.get_settings		= bcm_enet_get_settings,
 	.set_settings		= bcm_enet_set_settings,
-- 
1.6.3.3

