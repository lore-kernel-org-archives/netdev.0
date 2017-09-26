From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/5] net: dsa: use phy_ethtool_nway_reset
Date: Tue, 26 Sep 2017 17:15:35 -0400
Message-ID: <20170926211535.21273-6-vivien.didelot@savoirfairelinux.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use phy_ethtool_nway_reset now that dsa_slave_nway_reset does exactly
the same.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d2b632cae468..bf8800de13c1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -450,14 +450,6 @@ dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 		ds->ops->get_regs(ds, p->dp->index, regs, _p);
 }
 
-static int dsa_slave_nway_reset(struct net_device *dev)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-
-	return genphy_restart_aneg(dev->phydev);
-}
-
 static u32 dsa_slave_get_link(struct net_device *dev)
 {
 	if (!dev->phydev)
@@ -888,7 +880,7 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_drvinfo		= dsa_slave_get_drvinfo,
 	.get_regs_len		= dsa_slave_get_regs_len,
 	.get_regs		= dsa_slave_get_regs,
-	.nway_reset		= dsa_slave_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_link		= dsa_slave_get_link,
 	.get_eeprom_len		= dsa_slave_get_eeprom_len,
 	.get_eeprom		= dsa_slave_get_eeprom,
-- 
2.14.1
