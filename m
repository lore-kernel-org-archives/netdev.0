From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/5] net: dsa: use phy_ethtool_get_link_ksettings
Date: Tue, 26 Sep 2017 17:15:33 -0400
Message-ID: <20170926211535.21273-4-vivien.didelot@savoirfairelinux.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41200 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937221AbdIZVTZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 17:19:25 -0400
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use phy_ethtool_get_link_ksettings now that dsa_slave_get_link_ksettings
does exactly the same.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4ea1c6eb0da8..bb0f64f47ae7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -420,17 +420,6 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 /* ethtool operations *******************************************************/
-static int
-dsa_slave_get_link_ksettings(struct net_device *dev,
-			     struct ethtool_link_ksettings *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-
-	phy_ethtool_ksettings_get(dev->phydev, cmd);
-
-	return 0;
-}
 
 static int
 dsa_slave_set_link_ksettings(struct net_device *dev,
@@ -921,8 +910,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_wol		= dsa_slave_get_wol,
 	.set_eee		= dsa_slave_set_eee,
 	.get_eee		= dsa_slave_get_eee,
-	.get_link_ksettings	= dsa_slave_get_link_ksettings,
 	.set_link_ksettings	= dsa_slave_set_link_ksettings,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.get_rxnfc		= dsa_slave_get_rxnfc,
 	.set_rxnfc		= dsa_slave_set_rxnfc,
 };
-- 
2.14.1
