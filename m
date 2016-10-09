From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] staging: net: netlogic: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun,  9 Oct 2016 15:58:39 +0200
Message-ID: <1476021519-8250-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: gregkh@linuxfoundation.org, nevola@gmail.com, andrew@lunn.ch,
 davem@davemloft.net, amitoj1606@gmail.com, Julia.Lawall@lip6.fr,
 janani.rvchndrn@gmail.com, poojashamili@gmail.com, bhumirks@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/staging/netlogic/xlr_net.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index 552a7dc..cdf01b9 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -172,29 +172,31 @@ static struct phy_device *xlr_get_phydev(struct xlr_net_priv *priv)
 /*
  * Ethtool operation
  */
-static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int xlr_get_link_ksettings(struct net_device *ndev,
+				  struct ethtool_link_ksettings *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
 	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (!phydev)
 		return -ENODEV;
-	return phy_ethtool_gset(phydev, ecmd);
+	return phy_ethtool_ksettings_get(phydev, ecmd);
 }
 
-static int xlr_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int xlr_set_link_ksettings(struct net_device *ndev,
+				  const struct ethtool_link_ksettings *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
 	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (!phydev)
 		return -ENODEV;
-	return phy_ethtool_sset(phydev, ecmd);
+	return phy_ethtool_ksettings_set(phydev, ecmd);
 }
 
 static const struct ethtool_ops xlr_ethtool_ops = {
-	.get_settings = xlr_get_settings,
-	.set_settings = xlr_set_settings,
+	.get_link_ksettings = xlr_get_link_ksettings,
+	.set_link_ksettings = xlr_set_link_ksettings,
 };
 
 /*
-- 
1.7.4.4
