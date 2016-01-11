From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] net: bfin_mac: Use phy_find_first() instead of open-coding it
Date: Sun, 10 Jan 2016 20:43:49 -0800
Message-ID: <1452487429-6197-1-git-send-email-linux@roeck-us.net>
Cc: adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use phy_find_first() to find the first phy device instead of
open-coding it.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/adi/bfin_mac.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 5ddfd0ed61d4..74139cb7f849 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -380,9 +380,8 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 static int mii_probe(struct net_device *dev, int phy_mode)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	struct phy_device *phydev = NULL;
+	struct phy_device *phydev;
 	unsigned short sysctl;
-	int i;
 	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
@@ -396,19 +395,7 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
-	/* search for connected PHY device */
-	for (i = 0; i < PHY_MAX_ADDR; ++i) {
-		struct phy_device *const tmp_phydev =
-			mdiobus_get_phy(lp->mii_bus, i);
-
-		if (!tmp_phydev)
-			continue; /* no PHY here... */
-
-		phydev = tmp_phydev;
-		break; /* found it */
-	}
-
-	/* now we are supposed to have a proper phydev, to attach to... */
+	phydev = phy_find_first(lp->mii_bus);
 	if (!phydev) {
 		netdev_err(dev, "no phy device found\n");
 		return -ENODEV;
-- 
2.1.4
