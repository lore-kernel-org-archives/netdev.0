From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 2/3] net: mv643xx_eth: simplify phy_ethtool_get_wol call
Date: Mon, 10 Mar 2014 21:51:00 +0100
Message-ID: <1394484661-4554-3-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1394484661-4554-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394484661-4554-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With phy_ethtool_get_wol now clearing struct ethtool_wolinfo, we can
simplify routines calling it.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v1->v2:
- initial

Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a2565ce22b7c..729464ecce2a 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1336,10 +1336,7 @@ static void
 mv643xx_eth_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	wol->supported = 0;
-	wol->wolopts = 0;
-	if (mp->phy)
-		phy_ethtool_get_wol(mp->phy, wol);
+	phy_ethtool_get_wol(mp->phy, wol);
 }
 
 static int
-- 
1.8.5.3
