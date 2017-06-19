From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH net-next] net: phy: lxt: Export link partner advertising
Date: Mon, 19 Jun 2017 16:00:22 +0200
Message-ID: <20170619141308.9417A508705@solo.franken.de>
To: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Bogendoerfer <tbogendoerfer@suse.de>

Provide link partner advertising information.
Removed testing for gigabit modes, which is useless for a fast ethernet phy.

Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
---
 drivers/net/phy/lxt.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 8d198a1f0031..09d215177fff 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -152,7 +152,6 @@ static int lxt973a2_read_status(struct phy_device *phydev)
 	int adv;
 	int err;
 	int lpa;
-	int lpagb = 0;
 
 	/* Update the link, but return if there was an error */
 	err = lxt973a2_update_link(phydev);
@@ -178,18 +177,15 @@ static int lxt973a2_read_status(struct phy_device *phydev)
 			*/
 		} while (lpa == adv && retry--);
 
+		phydev->lp_advertising = mii_lpa_to_ethtool_lpa_t(lpa);
+
 		lpa &= adv;
 
 		phydev->speed = SPEED_10;
 		phydev->duplex = DUPLEX_HALF;
 		phydev->pause = phydev->asym_pause = 0;
 
-		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
-			phydev->speed = SPEED_1000;
-
-			if (lpagb & LPA_1000FULL)
-				phydev->duplex = DUPLEX_FULL;
-		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
+		if (lpa & (LPA_100FULL | LPA_100HALF)) {
 			phydev->speed = SPEED_100;
 
 			if (lpa & LPA_100FULL)
@@ -222,6 +218,7 @@ static int lxt973a2_read_status(struct phy_device *phydev)
 			phydev->speed = SPEED_10;
 
 		phydev->pause = phydev->asym_pause = 0;
+		phydev->lp_advertising = 0;
 	}
 
 	return 0;
-- 
2.12.3
