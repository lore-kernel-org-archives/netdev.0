From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [net-next] net: phy: marvell: Show complete link partner advertising
Date: Mon, 12 Jun 2017 14:54:57 +0200
Message-ID: <20170612133237.E20945085BC@solo.franken.de>
To: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Bogendoerfer <tbogendoerfer@suse.de>

Give back all modes advertised by the link partner. This change brings
the marvell phy driver in line with all other phy drivers.

Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
---
 drivers/net/phy/marvell.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 4c5246fed69b..8400403b3f62 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1139,7 +1139,6 @@ static int marvell_read_status_page_an(struct phy_device *phydev,
 	int status;
 	int lpa;
 	int lpagb;
-	int adv;
 
 	status = phy_read(phydev, MII_M1011_PHY_STATUS);
 	if (status < 0)
@@ -1153,12 +1152,6 @@ static int marvell_read_status_page_an(struct phy_device *phydev,
 	if (lpagb < 0)
 		return lpagb;
 
-	adv = phy_read(phydev, MII_ADVERTISE);
-	if (adv < 0)
-		return adv;
-
-	lpa &= adv;
-
 	if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
 		phydev->duplex = DUPLEX_FULL;
 	else
-- 
1.8.5.6
