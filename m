From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: amd8111e: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  5 Nov 2016 20:17:03 +0100
Message-ID: <1478373423-15837-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com, geert@linux-m68k.org,
        javier@osg.samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33732 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755084AbcKETRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 15:17:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/amd/amd8111e.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 84b4ffb..11cf1e3 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1421,21 +1421,23 @@ static void amd8111e_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	amd8111e_read_regs(lp, buf);
 }
 
-static int amd8111e_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int amd8111e_get_link_ksettings(struct net_device *dev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	spin_lock_irq(&lp->lock);
-	mii_ethtool_gset(&lp->mii_if, ecmd);
+	mii_ethtool_get_link_ksettings(&lp->mii_if, cmd);
 	spin_unlock_irq(&lp->lock);
 	return 0;
 }
 
-static int amd8111e_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int amd8111e_set_link_ksettings(struct net_device *dev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int res;
 	spin_lock_irq(&lp->lock);
-	res = mii_ethtool_sset(&lp->mii_if, ecmd);
+	res = mii_ethtool_set_link_ksettings(&lp->mii_if, cmd);
 	spin_unlock_irq(&lp->lock);
 	return res;
 }
@@ -1482,12 +1484,12 @@ static int amd8111e_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol_
 	.get_drvinfo = amd8111e_get_drvinfo,
 	.get_regs_len = amd8111e_get_regs_len,
 	.get_regs = amd8111e_get_regs,
-	.get_settings = amd8111e_get_settings,
-	.set_settings = amd8111e_set_settings,
 	.nway_reset = amd8111e_nway_reset,
 	.get_link = amd8111e_get_link,
 	.get_wol = amd8111e_get_wol,
 	.set_wol = amd8111e_set_wol,
+	.get_link_ksettings = amd8111e_get_link_ksettings,
+	.set_link_ksettings = amd8111e_set_link_ksettings,
 };
 
 /* This function handles all the  ethtool ioctls. It gives driver info,
-- 
1.7.4.4
