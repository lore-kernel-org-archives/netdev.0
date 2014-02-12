From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 09/10] Documentation: add Device tree bindings for Broadcom GENET
Date: Tue, 11 Feb 2014 20:07:32 -0800
Message-ID: <1392178053-3143-10-git-send-email-f.fainelli@gmail.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:42795 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaBLEIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:08:07 -0500
In-Reply-To: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
Ethernet controller. A bunch of examples are provided to illustrate the
versatile aspect of the hardare.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../devicetree/bindings/net/broadcom-bcmgenet.txt  | 111 +++++++++++++++++++++
 1 file changed, 111 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
new file mode 100644
index 0000000..93c58e9
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -0,0 +1,111 @@
+* Broadcom BCM7xxx Ethernet Controller (GENET)
+
+Required properties:
+- compatible: should be "brcm,genet-v1", "brcm,genet-v2", "brcm,genet-v3",
+  "brcm,genet-v4".
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device
+- mdio bus node: this node should always be present regarless of the PHY
+  configuration of the GENET instance
+- phy-mode: The interface between the SoC and the PHY (a string that
+  of_get_phy_mode() can understand).
+
+MDIO bus node required properties:
+
+- compatible: should be "brcm,genet-v<N>-mdio"
+- reg: address and length relative to the parent node base register address
+- address-cells: address cell for MDIO bus addressing, should be 1
+- size-cells: size of the cells for MDIO bus addressing, should be 0
+
+Optional properties:
+- phy-handle: A phandle to a phy node defining the PHY address (as the reg
+  property, a single integer), used to describe configurations where a PHY
+  (internal or external) is used.
+
+- fixed-link: When the GENET interface is connected to a MoCA hardware block
+  or when operating in a RGMII to RGMII type of connection, or when the
+  MDIO bus is voluntarily disabled, this property should be used to describe
+  the "fixed link", the property is described as follows:
+
+  fixed-link: <a b c d e> where a is emulated phy id - choose any,
+  but unique to the all specified fixed-links, b is duplex - 0 half,
+  1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
+  pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.
+
+Internal Gigabit PHY example:
+
+ethernet@f0b60000 {
+	phy-mode = "internal";
+	phy-handle = <&phy1>;
+	mac-address = [ 00 10 18 36 23 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	device_type = "ethernet";
+	reg = <0xf0b60000 0xfc4c>;
+	interrupts = <0x0 0x14 0x0 0x0 0x15 0x0>;
+
+	mdio@b60e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xb60e14 0x8>;
+
+		phy1: ethernet-phy@1 {
+			device_type = "ethernet-phy";
+			max-speed = <1000>;
+			reg = <0x1>;
+			compatible = "brcm,28nm-gphy", "ethernet-phy-ieee802.3-c22";
+		};
+	};
+};
+
+MoCA interface / MAC to MAC example:
+
+ethernet@f0b80000 {
+	phy-mode = "moca";
+	fixed-link = <1 0 1000 0 0>;
+	mac-address = [ 00 10 18 36 24 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	device_type = "ethernet";
+	reg = <0xf0b80000 0xfc4c>;
+	interrupts = <0x0 0x16 0x0 0x0 0x17 0x0>;
+
+	mdio@b80e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xb80e14 0x8>;
+	};
+};
+
+
+External MDIO-connected Gigabit PHY/switch:
+
+ethernet@f0ba0000 {
+	phy-mode = "rgmii";
+	phy-handle = <&phy0>;
+	mac-address = [ 00 10 18 36 26 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	device_type = "ethernet";
+	reg = <0xf0ba0000 0xfc4c>;
+	interrupts = <0x0 0x18 0x0 0x0 0x19 0x0>;
+
+	mdio@ba0e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xba0e14 0x8>;
+
+		phy0: ethernet-phy@0 {
+			device_type = "ethernet-phy";
+			max-speed = <1000>;
+			reg = <0x0>;
+			compatible = "brcm,bcm53125", "ethernet-phy-ieee802.3-c22";
+		};
+	};
+};
-- 
1.8.3.2
