From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] net: ti: cpmac: Fix build error due to missed API change
Date: Sat,  9 Jan 2016 13:19:39 -0800
Message-ID: <1452374379-18644-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
a bus") introduces an API to access mii_bus structures, but missed to
update the TI cpamc driver. This results in the following error message.

drivers/net/ethernet/ti/cpmac.c: In function 'cpmac_probe':
drivers/net/ethernet/ti/cpmac.c:1119:18: error:
	'struct mii_bus' has no member named 'phy_map'

Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/ti/cpmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 0b483301767d..7eef45e6d70a 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1116,7 +1116,7 @@ static int cpmac_probe(struct platform_device *pdev)
 		for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
 			if (!(pdata->phy_mask & (1 << phy_id)))
 				continue;
-			if (!cpmac_mii->phy_map[phy_id])
+			if (!mdiobus_get_phy(cpmac_mii, phy_id))
 				continue;
 			strncpy(mdio_bus_id, cpmac_mii->id, MII_BUS_ID_SIZE);
 			break;
-- 
2.1.4
