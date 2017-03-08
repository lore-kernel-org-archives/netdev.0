From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: fjes: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  8 Mar 2017 23:16:11 +0100
Message-ID: <1489011371-17119-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36772 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdCHWQd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 17:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/fjes/fjes_ethtool.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
index 6575f88..7d10171 100644
--- a/drivers/net/fjes/fjes_ethtool.c
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -175,16 +175,15 @@ static void fjes_get_drvinfo(struct net_device *netdev,
 		 "platform:%s", plat_dev->name);
 }
 
-static int fjes_get_settings(struct net_device *netdev,
-			     struct ethtool_cmd *ecmd)
+static int fjes_get_link_ksettings(struct net_device *netdev,
+				   struct ethtool_link_ksettings *ecmd)
 {
-	ecmd->supported = 0;
-	ecmd->advertising = 0;
-	ecmd->duplex = DUPLEX_FULL;
-	ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->transceiver = XCVR_DUMMY1;
-	ecmd->port = PORT_NONE;
-	ethtool_cmd_speed_set(ecmd, 20000);	/* 20Gb/s */
+	ethtool_link_ksettings_zero_link_mode(ecmd, supported);
+	ethtool_link_ksettings_zero_link_mode(ecmd, advertising);
+	ecmd->base.duplex = DUPLEX_FULL;
+	ecmd->base.autoneg = AUTONEG_DISABLE;
+	ecmd->base.port = PORT_NONE;
+	ecmd->base.speed = 20000;	/* 20Gb/s */
 
 	return 0;
 }
@@ -296,7 +295,6 @@ static int fjes_get_dump_data(struct net_device *netdev,
 }
 
 static const struct ethtool_ops fjes_ethtool_ops = {
-		.get_settings		= fjes_get_settings,
 		.get_drvinfo		= fjes_get_drvinfo,
 		.get_ethtool_stats = fjes_get_ethtool_stats,
 		.get_strings      = fjes_get_strings,
@@ -306,6 +304,7 @@ static int fjes_get_dump_data(struct net_device *netdev,
 		.set_dump		= fjes_set_dump,
 		.get_dump_flag		= fjes_get_dump_flag,
 		.get_dump_data		= fjes_get_dump_data,
+		.get_link_ksettings	= fjes_get_link_ksettings,
 };
 
 void fjes_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
