From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: bcmgenet: support restarting auto-negotiation
Date: Tue, 25 Nov 2014 21:16:36 -0800
Message-ID: <1416978996-24808-4-git-send-email-f.fainelli@gmail.com>
References: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:51188 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbaKZFQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:16:44 -0500
Received: by mail-pd0-f181.google.com with SMTP id z10so2029060pdj.26
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:16:43 -0800 (PST)
In-Reply-To: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hook a nway_reset ethtool callback to allow restarting the
auto-negotiation process when asked to. We defer to the PHY library call
to do the heavy lifting.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index bf44e0e23799..f2fadb053d52 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -799,6 +799,13 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	return phy_ethtool_set_eee(priv->phydev, e);
 }
 
+static int bcmgenet_nway_reset(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	return genphy_restart_aneg(priv->phydev);
+}
+
 /* standard ethtool support functions. */
 static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
@@ -814,6 +821,7 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.set_wol		= bcmgenet_set_wol,
 	.get_eee		= bcmgenet_get_eee,
 	.set_eee		= bcmgenet_set_eee,
+	.nway_reset		= bcmgenet_nway_reset,
 };
 
 /* Power down the unimac, based on mode. */
-- 
2.1.0
