From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH] phylib: Make PHYs children of their MDIO bus, not the bus' parent.
Date: Fri, 21 Aug 2015 16:16:03 -0700
Message-ID: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35977 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbHUXQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 19:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

commit 18ee49ddb0d2 ("phylib: rename mii_bus::dev to mii_bus::parent")
changed the parent of PHY devices from the bus to the bus parent.

Then, commit 4dea547fef1b ("phylib: rework to prepare for OF
registration of PHYs") moved the code into phy_device.c

At this point, it is somewhat unclear why the change was seen as
necessary.  But, when we look at the device model tree in
/sys/devices, it is clearly incorrect.  The PHYs should be children of
their MDIO bus.

Change the PHY's parent device to be the MDIO bus device.

Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0302483..55f0178 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -176,7 +176,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	if (c45_ids)
 		dev->c45_ids = *c45_ids;
 	dev->bus = bus;
-	dev->dev.parent = bus->parent;
+	dev->dev.parent = &bus->dev;
 	dev->dev.bus = &mdio_bus_type;
 	dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
 	dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
-- 
1.7.11.7
