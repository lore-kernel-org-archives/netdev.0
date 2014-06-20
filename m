From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 27/30] net: fec: reorder ethtool ops to match order in
 struct declaration
Date: Fri, 20 Jun 2014 13:14:01 +0100
Message-ID: <E1Wxxhh-0005Yb-45@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36399 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967448AbaFTMOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:14:03 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows us to merge two separate preprocessor conditionals together.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 317c58ff9b95..c05f33896002 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2015,21 +2015,19 @@ static int fec_enet_nway_reset(struct net_device *dev)
 }
 
 static const struct ethtool_ops fec_enet_ethtool_ops = {
-#if !defined(CONFIG_M5272)
-	.get_pauseparam		= fec_enet_get_pauseparam,
-	.set_pauseparam		= fec_enet_set_pauseparam,
-#endif
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
-	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= fec_enet_get_ts_info,
 	.nway_reset		= fec_enet_nway_reset,
+	.get_link		= ethtool_op_get_link,
 #ifndef CONFIG_M5272
-	.get_ethtool_stats	= fec_enet_get_ethtool_stats,
+	.get_pauseparam		= fec_enet_get_pauseparam,
+	.set_pauseparam		= fec_enet_set_pauseparam,
 	.get_strings		= fec_enet_get_strings,
+	.get_ethtool_stats	= fec_enet_get_ethtool_stats,
 	.get_sset_count		= fec_enet_get_sset_count,
 #endif
+	.get_ts_info		= fec_enet_get_ts_info,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.8.3.1
