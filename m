From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3 net-next] bcm63xx_enet: implement reset autoneg ethtool callback
Date: Tue,  4 Jun 2013 22:53:33 +0100
Message-ID: <1370382815-17904-2-git-send-email-florian@openwrt.org>
References: <1370382815-17904-1-git-send-email-florian@openwrt.org>
Cc: ralf@linux-mips.org, blogic@openwrt.org, linux-mips@linux-mips.org,
	cernekee@gmail.com, mbizon@freebox.fr, jogo@openwrt.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:46764 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab3FDVxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 17:53:44 -0400
Received: by mail-we0-f179.google.com with SMTP id w59so710688wes.10
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 14:53:43 -0700 (PDT)
In-Reply-To: <1370382815-17904-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>

Implement the rset_nway ethtool callback which uses libphy generic
autonegotiation restart function.

Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index e46466c..bc1a994 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1328,6 +1328,20 @@ static void bcm_enet_get_ethtool_stats(struct net_device *netdev,
 	mutex_unlock(&priv->mib_update_lock);
 }
 
+static int bcm_enet_nway_reset(struct net_device *dev)
+{
+	struct bcm_enet_priv *priv;
+
+	priv = netdev_priv(dev);
+	if (priv->has_phy) {
+		if (!priv->phydev)
+			return -ENODEV;
+		return genphy_restart_aneg(priv->phydev);
+	}
+
+	return -EOPNOTSUPP;
+}
+
 static int bcm_enet_get_settings(struct net_device *dev,
 				 struct ethtool_cmd *cmd)
 {
@@ -1470,6 +1484,7 @@ static const struct ethtool_ops bcm_enet_ethtool_ops = {
 	.get_strings		= bcm_enet_get_strings,
 	.get_sset_count		= bcm_enet_get_sset_count,
 	.get_ethtool_stats      = bcm_enet_get_ethtool_stats,
+	.nway_reset		= bcm_enet_nway_reset,
 	.get_settings		= bcm_enet_get_settings,
 	.set_settings		= bcm_enet_set_settings,
 	.get_drvinfo		= bcm_enet_get_drvinfo,
-- 
1.7.10.4
