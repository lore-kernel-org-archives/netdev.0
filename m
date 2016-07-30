From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: octeon: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sat, 30 Jul 2016 16:14:44 +0200
Message-ID: <1469888084-2887-2-git-send-email-tremyfr@gmail.com>
References: <1469888084-2887-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: gregkh@linuxfoundation.org, aaro.koskinen@iki.fi, nevola@gmail.com,
 andrew@lunn.ch, davem@davemloft.net, bhumirks@gmail.com,
 okash.khawaja@gmail.com, david.daney@cavium.com,
 cristina.moraru09@gmail.com, aybuke.147@gmail.com,
 kevin@darbyshire-bryant.me.uk, bhaktipriya96@gmail.com, joe@perches.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469888084-2887-1-git-send-email-tremyfr@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

There was a check on CAP_NET_ADMIN in cvm_oct_set_settings, but this
check is already done in dev_ethtool, so no need to repeat it before
calling the generic function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/staging/octeon/ethernet-mdio.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 661b97b..1fde9c8 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -34,25 +34,6 @@ static void cvm_oct_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, "Builtin", sizeof(info->bus_info));
 }
 
-static int cvm_oct_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (dev->phydev)
-		return phy_ethtool_gset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
-static int cvm_oct_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	if (dev->phydev)
-		return phy_ethtool_sset(dev->phydev, cmd);
-
-	return -EINVAL;
-}
-
 static int cvm_oct_nway_reset(struct net_device *dev)
 {
 	if (!capable(CAP_NET_ADMIN))
@@ -66,10 +47,10 @@ static int cvm_oct_nway_reset(struct net_device *dev)
 
 const struct ethtool_ops cvm_oct_ethtool_ops = {
 	.get_drvinfo = cvm_oct_get_drvinfo,
-	.get_settings = cvm_oct_get_settings,
-	.set_settings = cvm_oct_set_settings,
 	.nway_reset = cvm_oct_nway_reset,
 	.get_link = ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
