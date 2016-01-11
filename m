From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] ethernet: amd: au1000: Remove pointless warning
Date: Mon, 11 Jan 2016 01:13:21 +0100
Message-ID: <1452471201-26335-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45105 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757375AbcAKANa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2016 19:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The warning about being able to read any MDIO device, not just the
attached ethernet devices PHY applies to all MDIO drivers. So remove
it. This also removes a reference to a member in phy_device which has
moved.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/amd/au1000_eth.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index c8640418fc37..d3977d032b48 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -344,9 +344,6 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 
 static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
-	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
-	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus)
-	 */
 	struct net_device *const dev = bus->priv;
 
 	/* make sure the MAC associated with this
-- 
2.6.4
