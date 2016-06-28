From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: lpc_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 28 Jun 2016 23:59:45 +0200
Message-ID: <1467151185-31403-2-git-send-email-tremyfr@gmail.com>
References: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Philippe Reynes <tremyfr@gmail.com>
To: vz@mleia.com,
	slemieux.tyco@gmail.com,
	davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index b003501..01b50ff 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1245,35 +1245,13 @@ static void lpc_eth_ethtool_setmsglevel(struct net_device *ndev, u32 level)
 	pldat->msg_enable = level;
 }
 
-static int lpc_eth_ethtool_getsettings(struct net_device *ndev,
-	struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int lpc_eth_ethtool_setsettings(struct net_device *ndev,
-	struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static const struct ethtool_ops lpc_eth_ethtool_ops = {
 	.get_drvinfo	= lpc_eth_ethtool_getdrvinfo,
-	.get_settings	= lpc_eth_ethtool_getsettings,
-	.set_settings	= lpc_eth_ethtool_setsettings,
 	.get_msglevel	= lpc_eth_ethtool_getmsglevel,
 	.set_msglevel	= lpc_eth_ethtool_setmsglevel,
 	.get_link	= ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops lpc_netdev_ops = {
-- 
1.7.4.4
