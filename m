From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: fealnx: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  2 Jan 2017 20:47:27 +0100
Message-ID: <1483386447-19012-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35851 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdABTrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 14:47:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/fealnx.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 9cb436c..766636a 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1817,25 +1817,27 @@ static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_gset(&np->mii, cmd);
+	rc = mii_ethtool_get_link_ksettings(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
 }
 
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_sset(&np->mii, cmd);
+	rc = mii_ethtool_set_link_ksettings(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
@@ -1865,12 +1867,12 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 static int mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
