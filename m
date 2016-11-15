From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 02/15] net: nb8800: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:31 -0800
Message-ID: <20161115180644.3941-3-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Jarod Wilson <jarod@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index b59aa3541270..07ff6492402a 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1037,16 +1037,6 @@ static const struct net_device_ops nb8800_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int nb8800_nway_reset(struct net_device *dev)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return genphy_restart_aneg(phydev);
-}
-
 static void nb8800_get_pauseparam(struct net_device *dev,
 				  struct ethtool_pauseparam *pp)
 {
@@ -1165,7 +1155,7 @@ static void nb8800_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops nb8800_ethtool_ops = {
-	.nway_reset		= nb8800_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_pauseparam		= nb8800_get_pauseparam,
 	.set_pauseparam		= nb8800_set_pauseparam,
-- 
2.9.3
