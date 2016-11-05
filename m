From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: amd: pcnet32: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  6 Nov 2016 00:26:41 +0100
Message-ID: <1478388401-13029-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: pcnet32@frontier.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/amd/pcnet32.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index adc7ab9..41e58cc 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -677,7 +677,8 @@ static void pcnet32_poll_controller(struct net_device *dev)
 }
 #endif
 
-static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int pcnet32_get_link_ksettings(struct net_device *dev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
@@ -685,14 +686,15 @@ static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (lp->mii) {
 		spin_lock_irqsave(&lp->lock, flags);
-		mii_ethtool_gset(&lp->mii_if, cmd);
+		mii_ethtool_get_link_ksettings(&lp->mii_if, cmd);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		r = 0;
 	}
 	return r;
 }
 
-static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int pcnet32_set_link_ksettings(struct net_device *dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
@@ -700,7 +702,7 @@ static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (lp->mii) {
 		spin_lock_irqsave(&lp->lock, flags);
-		r = mii_ethtool_sset(&lp->mii_if, cmd);
+		r = mii_ethtool_set_link_ksettings(&lp->mii_if, cmd);
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 	return r;
@@ -1440,8 +1442,6 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 }
 
 static const struct ethtool_ops pcnet32_ethtool_ops = {
-	.get_settings		= pcnet32_get_settings,
-	.set_settings		= pcnet32_set_settings,
 	.get_drvinfo		= pcnet32_get_drvinfo,
 	.get_msglevel		= pcnet32_get_msglevel,
 	.set_msglevel		= pcnet32_set_msglevel,
@@ -1455,6 +1455,8 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	.get_regs_len		= pcnet32_get_regs_len,
 	.get_regs		= pcnet32_get_regs,
 	.get_sset_count		= pcnet32_get_sset_count,
+	.get_link_ksettings	= pcnet32_get_link_ksettings,
+	.set_link_ksettings	= pcnet32_set_link_ksettings,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
-- 
1.7.4.4
