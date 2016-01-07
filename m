From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: lantiq_etop.c: Use helper to find first phy
Date: Thu,  7 Jan 2016 21:55:51 +0100
Message-ID: <1452200152-15793-2-git-send-email-andrew@lunn.ch>
References: <1452200152-15793-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43502 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbcAGU4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 15:56:05 -0500
In-Reply-To: <1452200152-15793-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the helper to find the first phy device.
This also fixes the compile breakage.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/lantiq_etop.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index fb61f7f96bb4..b630ef1e9646 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -375,15 +375,9 @@ static int
 ltq_etop_mdio_probe(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = NULL;
-	int phy_addr;
+	struct phy_device *phydev;
 
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (priv->mii_bus->phy_map[phy_addr]) {
-			phydev = priv->mii_bus->phy_map[phy_addr];
-			break;
-		}
-	}
+	phydev = phy_find_first(priv->mii_bus);
 
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
-- 
2.6.4
