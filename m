From: David Daney <david.daney@cavium.com>
Subject: [PATCH] netdev/phy: Use mdiobus_read() so that proper locks are taken.
Date: Fri, 30 Sep 2011 14:51:22 -0700
Message-ID: <1317419482-25655-1-git-send-email-david.daney@cavium.com>
Cc: linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:18529 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703Ab1I3VwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 17:52:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accesses to the mdio busses must be done with the mdio_lock to ensure
proper operation.  Conveniently we have the helper function
mdiobus_read() to do that for us.  Lets use it in get_phy_id() instead
of accessing the bus without the lock held.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/phy_device.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index ff109fe..83a5a5a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -213,7 +213,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
-	phy_reg = bus->read(bus, addr, MII_PHYSID1);
+	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
 
 	if (phy_reg < 0)
 		return -EIO;
@@ -221,7 +221,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 	*phy_id = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = bus->read(bus, addr, MII_PHYSID2);
+	phy_reg = mdiobus_read(bus, addr, MII_PHYSID2);
 
 	if (phy_reg < 0)
 		return -EIO;
-- 
1.7.2.3
