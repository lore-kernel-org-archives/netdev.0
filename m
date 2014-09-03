From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH 2/4] dt-bindings: Document EMAC Rockchip
Date: Wed,  3 Sep 2014 10:27:14 +0000
Message-ID: <1409740036-8117-2-git-send-email-romain.perier@gmail.com>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:62477 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755985AbaICKZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 06:25:07 -0400
In-Reply-To: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the necessary binding documentation for the EMAC Rockchip platform
driver found in RK3066 and RK3188 SoCs.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 .../devicetree/bindings/net/emac_rockchip.txt      | 53 ++++++++++++++++++++++
 1 file changed, 53 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/emac_rockchip.txt

diff --git a/Documentation/devicetree/bindings/net/emac_rockchip.txt b/Documentation/devicetree/bindings/net/emac_rockchip.txt
new file mode 100644
index 0000000..d3242e4
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/emac_rockchip.txt
@@ -0,0 +1,53 @@
+* ARC EMAC 10/100 Ethernet platform driver for Rockchip Rk3066/RK3188 SoCs
+
+Required properties:
+- compatible: Should be "rockchip,rk3066-emac" or "rockchip,rk3188-emac"
+  according to the target SoC.
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the EMAC interrupts
+- pinctrl-names: pin control state name ("default").
+- pinctrl-0: pin control group list of phandle. It must contain
+  pin control groups for communication with the phy and for the mii bus.
+- rockchip,grf: phandle to the syscon grf used to control speed and mode
+  for emac.
+- phy: see ethernet.txt file in the same directory.
+- phy-mode: see ethernet.txt file in the same directory.
+
+Optional properties:
+- phy-supply: phandle to a regulator if the PHY needs one
+
+Clock handling:
+- The host clock is needed to calculate and set polling period of EMAC.
+  It must be provided by the clock "hclk".
+- The reference clock is needed to get/set data from phy at the right frequency,
+  according to its "phy-mode". It must be provided by the clock "macref".
+
+Child nodes of the driver are the individual PHY devices connected to the
+MDIO bus. They must have a "reg" property given the PHY address on the MDIO bus.
+
+Examples:
+
+ethernet@10204000 {
+	compatible = "rockchip,rk3188-emac";
+	reg = <0xc0fc2000 0x3c>;
+	interrupts = <6>;
+	mac-address = [ 00 11 22 33 44 55 ];
+
+	clocks = <&cru HCLK_EMAC>, <&cru SCLK_MAC>;
+	clock-names = "hclk", "macref";
+
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
+
+	rockchip,grf = <&grf>;
+
+	phy = <&phy0>;
+	phy-mode = "rmii";
+	phy-supply = <&vcc_rmii>;
+
+	#address-cells = <1>;
+	#size-cells = <0>;
+	phy0: ethernet-phy@0 {
+	      reg = <1>;
+	};
+};
-- 
1.9.1
