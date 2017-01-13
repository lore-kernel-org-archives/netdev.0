From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH] net: phy: dp83867: allow RGMII_TXID/RGMII_RXID interface types
Date: Fri, 13 Jan 2017 09:32:34 -0500
Message-ID: <1484317954-27871-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently dp83867 driver returns error if phy interface type
PHY_INTERFACE_MODE_RGMII_RXID is used to set the rx only internal
delay. Similarly issue happens for PHY_INTERFACE_MODE_RGMII_TXID.
Fix this by checking also the interface type if a particular delay
value is missing in the phy dt bindings. Also update the DT document
accordingly.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 - I had sent this earlier and some how it didn't get through and
   I haven't seen any comment for this. So sending this again.
 - Applies to master.

 Documentation/devicetree/bindings/net/ti,dp83867.txt | 6 ++++--
 drivers/net/phy/dp83867.c                            | 8 ++++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index 85bf945..afe9630 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -3,9 +3,11 @@
 Required properties:
 	- reg - The ID number for the phy, usually a small integer
 	- ti,rx-internal-delay - RGMII Receive Clock Delay - see dt-bindings/net/ti-dp83867.h
-		for applicable values
+		for applicable values. Required only if interface type is
+		PHY_INTERFACE_MODE_RGMII_ID or PHY_INTERFACE_MODE_RGMII_RXID
 	- ti,tx-internal-delay - RGMII Transmit Clock Delay - see dt-bindings/net/ti-dp83867.h
-		for applicable values
+		for applicable values. Required only if interface type is
+		PHY_INTERFACE_MODE_RGMII_ID or PHY_INTERFACE_MODE_RGMII_TXID
 	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
 		for applicable values
 
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index e84ae08..ca1b462 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -132,12 +132,16 @@ static int dp83867_of_init(struct phy_device *phydev)
 
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
-	if (ret)
+	if (ret &&
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	     phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID))
 		return ret;
 
 	ret = of_property_read_u32(of_node, "ti,tx-internal-delay",
 				   &dp83867->tx_id_delay);
-	if (ret)
+	if (ret &&
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	     phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID))
 		return ret;
 
 	return of_property_read_u32(of_node, "ti,fifo-depth",
-- 
1.9.1
