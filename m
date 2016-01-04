From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 06/24] net: dnet: Use phy_find_first() helper
Date: Mon,  4 Jan 2016 18:36:44 +0100
Message-ID: <1451929022-5580-7-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34935 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbcADRhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:37:07 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the open coded search for the first phy with a call to the
existing helper function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/dnet.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 136b6010f704..0ec367521354 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -255,15 +255,9 @@ static int dnet_mii_probe(struct net_device *dev)
 {
 	struct dnet *bp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
-	int phy_addr;
 
 	/* find the first phy */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (bp->mii_bus->phy_map[phy_addr]) {
-			phydev = bp->mii_bus->phy_map[phy_addr];
-			break;
-		}
-	}
+	phydev = phy_find_first(bp->mii_bus);
 
 	if (!phydev) {
 		printk(KERN_ERR "%s: no PHY found\n", dev->name);
-- 
2.6.4
