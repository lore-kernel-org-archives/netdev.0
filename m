From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 06/22] net: dnet: Use phy_find_first() helper
Date: Wed,  6 Jan 2016 20:11:11 +0100
Message-ID: <1452107487-475-7-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42367 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbcAFTNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:13:31 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the open coded search for the first phy with a call to the
existing helper function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
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
