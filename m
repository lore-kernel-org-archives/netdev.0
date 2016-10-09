From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dsa: slave: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  9 Oct 2016 17:00:53 +0200
Message-ID: <1476025253-5571-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 net/dsa/slave.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6b1282c..68714a5 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -641,7 +641,8 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 
 /* ethtool operations *******************************************************/
 static int
-dsa_slave_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+dsa_slave_get_link_ksettings(struct net_device *dev,
+			     struct ethtool_link_ksettings *cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	int err;
@@ -650,19 +651,20 @@ dsa_slave_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (p->phy != NULL) {
 		err = phy_read_status(p->phy);
 		if (err == 0)
-			err = phy_ethtool_gset(p->phy, cmd);
+			err = phy_ethtool_ksettings_get(p->phy, cmd);
 	}
 
 	return err;
 }
 
 static int
-dsa_slave_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+dsa_slave_set_link_ksettings(struct net_device *dev,
+			     const struct ethtool_link_ksettings *cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
 	if (p->phy != NULL)
-		return phy_ethtool_sset(p->phy, cmd);
+		return phy_ethtool_ksettings_set(p->phy, cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -990,8 +992,6 @@ void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
 }
 
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
-	.get_settings		= dsa_slave_get_settings,
-	.set_settings		= dsa_slave_set_settings,
 	.get_drvinfo		= dsa_slave_get_drvinfo,
 	.get_regs_len		= dsa_slave_get_regs_len,
 	.get_regs		= dsa_slave_get_regs,
@@ -1007,6 +1007,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_wol		= dsa_slave_get_wol,
 	.set_eee		= dsa_slave_set_eee,
 	.get_eee		= dsa_slave_get_eee,
+	.get_link_ksettings	= dsa_slave_get_link_ksettings,
+	.set_link_ksettings	= dsa_slave_set_link_ksettings,
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-- 
1.7.4.4
