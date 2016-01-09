From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next 2/2] net: bfin_mac: Fix build error due to missed API change
Date: Sat,  9 Jan 2016 08:37:07 -0800
Message-ID: <1452357427-30578-2-git-send-email-linux@roeck-us.net>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
a bus") introduces an API to access mii_bus structures, but missed to
update the bfin_mac driver. This results in the following error message

drivers/net/ethernet/adi/bfin_mac.c: In function 'mii_probe':
drivers/net/ethernet/adi/bfin_mac.c:401:52: error:
	'struct mii_bus' has no member named 'phy_map'

Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/adi/bfin_mac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 8c5132624510..1281cae5b70f 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -398,7 +398,8 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 
 	/* search for connected PHY device */
 	for (i = 0; i < PHY_MAX_ADDR; ++i) {
-		struct phy_device *const tmp_phydev = lp->mii_bus->phy_map[i];
+		struct phy_device *const tmp_phydev =
+			mdiobus_get_phy(lp->mii_bus, i);
 
 		if (!tmp_phydev)
 			continue; /* no PHY here... */
-- 
2.1.4
