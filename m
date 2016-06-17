From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: et131x: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 17 Jun 2016 23:32:15 +0200
Message-ID: <1466199135-13459-2-git-send-email-tremyfr@gmail.com>
References: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: mark.einon@gmail.com, davem@davemloft.net, andrew@lunn.ch,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com,
	f.fainelli@gmail.com, fw@strlen.de, wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/agere/et131x.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index d194992..cd7e2e5 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -2790,18 +2790,6 @@ static void et131x_handle_send_pkts(struct et131x_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
 }
 
-static int et131x_get_settings(struct net_device *netdev,
-			       struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(netdev->phydev, cmd);
-}
-
-static int et131x_set_settings(struct net_device *netdev,
-			       struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(netdev->phydev, cmd);
-}
-
 static int et131x_get_regs_len(struct net_device *netdev)
 {
 #define ET131X_REGS_LEN 256
@@ -2974,12 +2962,12 @@ static void et131x_get_drvinfo(struct net_device *netdev,
 }
 
 static struct ethtool_ops et131x_ethtool_ops = {
-	.get_settings	= et131x_get_settings,
-	.set_settings	= et131x_set_settings,
 	.get_drvinfo	= et131x_get_drvinfo,
 	.get_regs_len	= et131x_get_regs_len,
 	.get_regs	= et131x_get_regs,
 	.get_link	= ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /* et131x_hwaddr_init - set up the MAC Address */
-- 
1.7.4.4
