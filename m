From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] net: ethernet: faraday: Use phy_find_first() instead of open coding it
Date: Sun, 10 Jan 2016 12:04:32 -0800
Message-ID: <1452456272-1795-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use phy_find_first() to find the first phy device instead of
open coding it.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bb116ad646f6..84384e1585a5 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -834,20 +834,9 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 {
 	struct net_device *netdev = priv->netdev;
-	struct phy_device *phydev = NULL;
-	int i;
-
-	/* search for connect PHY device */
-	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		struct phy_device *tmp = mdiobus_get_phy(priv->mii_bus, i);
-
-		if (tmp) {
-			phydev = tmp;
-			break;
-		}
-	}
+	struct phy_device *phydev;
 
-	/* now we are supposed to have a proper phydev, to attach to... */
+	phydev = phy_find_first(priv->mii_bus);
 	if (!phydev) {
 		netdev_info(netdev, "%s: no PHY found\n", netdev->name);
 		return -ENODEV;
-- 
2.1.4
