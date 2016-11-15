From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 05/15] net: smsc911x: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:34 -0800
Message-ID: <20161115180644.3941-6-f.fainelli@gmail.com>
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
 drivers/net/ethernet/smsc/smsc911x.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index cdb343f0c6e0..be09573c6ced 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1956,11 +1956,6 @@ static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
 		sizeof(info->bus_info));
 }
 
-static int smsc911x_ethtool_nwayreset(struct net_device *dev)
-{
-	return phy_start_aneg(dev->phydev);
-}
-
 static u32 smsc911x_ethtool_getmsglevel(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
@@ -2132,7 +2127,7 @@ static int smsc911x_ethtool_set_eeprom(struct net_device *dev,
 static const struct ethtool_ops smsc911x_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_drvinfo = smsc911x_ethtool_getdrvinfo,
-	.nway_reset = smsc911x_ethtool_nwayreset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_msglevel = smsc911x_ethtool_getmsglevel,
 	.set_msglevel = smsc911x_ethtool_setmsglevel,
 	.get_regs_len = smsc911x_ethtool_getregslen,
-- 
2.9.3
