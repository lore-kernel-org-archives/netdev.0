From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] PHY: DP83867: Remove looking in parent device for OF properties
Date: Mon,  7 Dec 2015 04:38:58 +0100
Message-ID: <1449459538-24105-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54862 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbbLGDjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 22:39:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device tree properties for a phy device are expected to be in the phy
node. The current code for the DP83867 also tries to look in the
parent node. The devices binding documentation does not mention this,
no current device tree file makes use of this, and it is not behaviour
we want. So remove looking in the parent device.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/dp83867.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 32f10662f4ac..4ebf601073d9 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -107,10 +107,7 @@ static int dp83867_of_init(struct phy_device *phydev)
 	struct device_node *of_node = dev->of_node;
 	int ret;
 
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
-
-	if (!phydev->dev.of_node)
+	if (!of_node)
 		return -ENODEV;
 
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
-- 
2.6.2
