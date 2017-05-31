From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Wed, 31 May 2017 15:43:30 -0400
Message-ID: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use of_mdio_parse_addr() in place of an OF read of reg and a bounds
check (which is litterally the exact same thing that
of_mdio_parse_addr() does)

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/phy/mdio_bus.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 8e73f5f36e71..d4782e902e2e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -263,21 +263,10 @@ static void of_mdiobus_link_mdiodev(struct mii_bus *bus,
 
 	for_each_available_child_of_node(bus->dev.of_node, child) {
 		int addr;
-		int ret;
 
-		ret = of_property_read_u32(child, "reg", &addr);
-		if (ret < 0) {
-			dev_err(dev, "%s has invalid MDIO address\n",
-				child->full_name);
+		addr = of_mdio_parse_addr(dev, child);
+		if (addr < 0)
 			continue;
-		}
-
-		/* A MDIO device must have a reg property in the range [0-31] */
-		if (addr >= PHY_MAX_ADDR) {
-			dev_err(dev, "%s MDIO address %i is too large\n",
-				child->full_name, addr);
-			continue;
-		}
 
 		if (addr == mdiodev->addr) {
 			dev->of_node = child;
-- 
2.7.4
