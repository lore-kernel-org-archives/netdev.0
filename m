From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 06/15] net: ethernet: smsc9420: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:35 -0800
Message-ID: <20161115180644.3941-7-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index b7bfed4bc96b..3174aebb322f 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -254,14 +254,6 @@ static void smsc9420_ethtool_set_msglevel(struct net_device *netdev, u32 data)
 	pd->msg_enable = data;
 }
 
-static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
-{
-	if (!netdev->phydev)
-		return -ENODEV;
-
-	return phy_start_aneg(netdev->phydev);
-}
-
 static int smsc9420_ethtool_getregslen(struct net_device *dev)
 {
 	/* all smsc9420 registers plus all phy registers */
@@ -417,7 +409,7 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.get_drvinfo = smsc9420_ethtool_get_drvinfo,
 	.get_msglevel = smsc9420_ethtool_get_msglevel,
 	.set_msglevel = smsc9420_ethtool_set_msglevel,
-	.nway_reset = smsc9420_ethtool_nway_reset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = smsc9420_ethtool_get_eeprom_len,
 	.get_eeprom = smsc9420_ethtool_get_eeprom,
-- 
2.9.3
