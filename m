From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: realtek: 8139cp: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 22 Feb 2017 08:50:27 +0100
Message-ID: <1487749827-20191-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, fgao@ikuai8.com, jarod@redhat.com,
        edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/realtek/8139cp.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 672f6b6..72233ab 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1406,27 +1406,29 @@ static int cp_get_sset_count (struct net_device *dev, int sset)
 	}
 }
 
-static int cp_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int cp_get_link_ksettings(struct net_device *dev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	int rc;
 	unsigned long flags;
 
 	spin_lock_irqsave(&cp->lock, flags);
-	rc = mii_ethtool_gset(&cp->mii_if, cmd);
+	rc = mii_ethtool_get_link_ksettings(&cp->mii_if, cmd);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
 	return rc;
 }
 
-static int cp_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int cp_set_link_ksettings(struct net_device *dev,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	int rc;
 	unsigned long flags;
 
 	spin_lock_irqsave(&cp->lock, flags);
-	rc = mii_ethtool_sset(&cp->mii_if, cmd);
+	rc = mii_ethtool_set_link_ksettings(&cp->mii_if, cmd);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
 	return rc;
@@ -1578,8 +1580,6 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 	.get_drvinfo		= cp_get_drvinfo,
 	.get_regs_len		= cp_get_regs_len,
 	.get_sset_count		= cp_get_sset_count,
-	.get_settings		= cp_get_settings,
-	.set_settings		= cp_set_settings,
 	.nway_reset		= cp_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= cp_get_msglevel,
@@ -1593,6 +1593,8 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 	.get_eeprom		= cp_get_eeprom,
 	.set_eeprom		= cp_set_eeprom,
 	.get_ringparam		= cp_get_ringparam,
+	.get_link_ksettings	= cp_get_link_ksettings,
+	.set_link_ksettings	= cp_set_link_ksettings,
 };
 
 static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
