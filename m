From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH] net: phy: dp83867: Fix device tree entries
Date: Mon, 8 Jun 2015 14:30:55 -0500
Message-ID: <1433791855-8265-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <davem@davemloft.net>,
	Dan Murphy <dmurphy@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46652 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbbFHTa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 15:30:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the device tree entries to modify the '_' to '-'.
Also changes the names of the internal delay properties
from -int- to -internal- as the -int- appeared as a keyword.

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---

v1 - Fixed device tree entries and added data sheet reference per http://www.spinics.net/lists/netdev/msg331941.html

 Documentation/devicetree/bindings/net/ti,dp83867.txt | 18 ++++++++++++------
 drivers/net/phy/dp83867.c                            |  6 +++---
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index 46bb67a..58d935b 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -2,18 +2,24 @@
 
 Required properties:
 	- reg - The ID number for the phy, usually a small integer
-	- ti,rx_int_delay - RGMII Recieve Clock Delay - see dt-bindings/net/ti-dp83867.h
+	- ti,rx-internal-delay - RGMII Recieve Clock Delay - see dt-bindings/net/ti-dp83867.h
 		for applicable values
-	- ti,tx_int_delay - RGMII Transmit Clock Delay - see dt-bindings/net/ti-dp83867.h
+	- ti,tx-internal-delay - RGMII Transmit Clock Delay - see dt-bindings/net/ti-dp83867.h
 		for applicable values
-	- ti,fifo_depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
+	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
 		for applicable values
 
+Default child nodes are standard Ethernet PHY device
+nodes as described in Documentation/devicetree/bindings/net/phy.txt
+
 Example:
 
 	ethernet-phy@0 {
 		reg = <0>;
-		ti,rx_int_delay = <DP83867_RGMIIDCTL_2_25_NS>;
-		ti,tx_int_delay = <DP83867_RGMIIDCTL_2_75_NS>;
-		ti,fifo_depth = <DP83867_PHYCR_FIFO_DEPTH_4_B_NIB>;
+		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_25_NS>;
+		ti,tx-internal-delay = <DP83867_RGMIIDCTL_2_75_NS>;
+		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_4_B_NIB>;
 	};
+
+Datasheet can be found:
+http://www.ti.com/product/DP83867IR/datasheet
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index ef0b4eb..c7a12e2 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -113,17 +113,17 @@ static int dp83867_of_init(struct phy_device *phydev)
 	if (!phydev->dev.of_node)
 		return -ENODEV;
 
-	ret = of_property_read_u32(of_node, "ti,rx_int_delay",
+	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
 	if (ret)
 		return ret;
 
-	ret = of_property_read_u32(of_node, "ti,tx_int_delay",
+	ret = of_property_read_u32(of_node, "ti,tx-internal-delay",
 				   &dp83867->tx_id_delay);
 	if (ret)
 		return ret;
 
-	ret = of_property_read_u32(of_node, "ti,fifo_depth",
+	ret = of_property_read_u32(of_node, "ti,fifo-depth",
 				   &dp83867->fifo_depth);
 	if (ret)
 		return ret;
-- 
1.9.1
