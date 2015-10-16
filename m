From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC device
Date: Fri, 16 Oct 2015 22:49:04 +0200
Message-ID: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41999 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbbJPUtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 16:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
the bus' parent." broke finding PHY properties in the MAC device tree
node. The parent device is now the MDIO bus, not the MAC. Use
attached_dev towards the MAC device tree node.

Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

Compile tested only.

Dinh, please could you test it and report back if it works or not.

 drivers/net/phy/micrel.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 499185eaf413..9e2083a1a5a9 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -25,6 +25,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/phy.h>
+#include <linux/netdevice.h>
 #include <linux/micrel_phy.h>
 #include <linux/of.h>
 #include <linux/clk.h>
@@ -340,8 +341,9 @@ static int ksz9021_config_init(struct phy_device *phydev)
 	const struct device *dev = &phydev->dev;
 	const struct device_node *of_node = dev->of_node;
 
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
+	if (!of_node && phydev->attached_dev &&
+	    phydev->attached_dev->dev.of_node)
+		of_node = phydev->attached_dev->dev.of_node;
 
 	if (of_node) {
 		ksz9021_load_values_from_of(phydev, of_node,
-- 
2.5.1
