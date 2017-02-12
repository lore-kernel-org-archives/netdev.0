From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: nuvoton: w90p910: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 21:38:29 +0100
Message-ID: <1486931909-18330-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: mcuos.com@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34786 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdBLUih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 15:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 119f6dc..9709c8c 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -874,16 +874,18 @@ static void w90p910_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 }
 
-static int w90p910_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int w90p910_get_link_ksettings(struct net_device *dev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
-	return mii_ethtool_gset(&ether->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&ether->mii, cmd);
 }
 
-static int w90p910_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int w90p910_set_link_ksettings(struct net_device *dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
-	return mii_ethtool_sset(&ether->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&ether->mii, cmd);
 }
 
 static int w90p910_nway_reset(struct net_device *dev)
@@ -899,11 +901,11 @@ static u32 w90p910_get_link(struct net_device *dev)
 }
 
 static const struct ethtool_ops w90p910_ether_ethtool_ops = {
-	.get_settings	= w90p910_get_settings,
-	.set_settings	= w90p910_set_settings,
 	.get_drvinfo	= w90p910_get_drvinfo,
 	.nway_reset	= w90p910_nway_reset,
 	.get_link	= w90p910_get_link,
+	.get_link_ksettings = w90p910_get_link_ksettings,
+	.set_link_ksettings = w90p910_set_link_ksettings,
 };
 
 static const struct net_device_ops w90p910_ether_netdev_ops = {
-- 
1.7.4.4
