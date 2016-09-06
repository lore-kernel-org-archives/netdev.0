From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v5 1/6] net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
Date: Tue,  6 Sep 2016 23:38:43 +0200
Message-ID: <20160906213848.17785-2-martin.blumenstingl@googlemail.com>
References: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sboyd@codeaurora.org, manabian@gmail.com, arnd@arndb.de,
        davem@davemloft.net, b.galvani@gmail.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33976 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754429AbcIFVjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 17:39:44 -0400
In-Reply-To: <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the documentation for the DWMAC ethernet controller
found in Amlogic Meson 8b (S805) and GXBB (S905) SoCs.
The main difference between the Meson6 glue is that different registers
(with different layout) are used.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Acked-by: Rob Herring <robh@kernel.org>
Acked-by: David S. Miller <davem@davemloft.net>
---
 .../devicetree/bindings/net/meson-dwmac.txt        | 45 ++++++++++++++++++----
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/meson-dwmac.txt b/Documentation/devicetree/bindings/net/meson-dwmac.txt
index ec633d7..89e62dd 100644
--- a/Documentation/devicetree/bindings/net/meson-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/meson-dwmac.txt
@@ -1,18 +1,32 @@
 * Amlogic Meson DWMAC Ethernet controller
 
 The device inherits all the properties of the dwmac/stmmac devices
-described in the file net/stmmac.txt with the following changes.
+described in the file stmmac.txt in the current directory with the
+following changes.
 
-Required properties:
+Required properties on all platforms:
 
-- compatible: should be "amlogic,meson6-dwmac" along with "snps,dwmac"
-	      and any applicable more detailed version number
-	      described in net/stmmac.txt
+- compatible:	Depending on the platform this should be one of:
+			- "amlogic,meson6-dwmac"
+			- "amlogic,meson8b-dwmac"
+			- "amlogic,meson-gxbb-dwmac"
+		Additionally "snps,dwmac" and any applicable more
+		detailed version number described in net/stmmac.txt
+		should be used.
 
-- reg: should contain a register range for the dwmac controller and
-       another one for the Amlogic specific configuration
+- reg:	The first register range should be the one of the DWMAC
+	controller. The second range is is for the Amlogic specific
+	configuration (for example the PRG_ETHERNET register range
+	on Meson8b and newer)
 
-Example:
+Required properties on Meson8b and newer:
+- clock-names:	Should contain the following:
+		- "stmmaceth" - see stmmac.txt
+		- "clkin0" - first parent clock of the internal mux
+		- "clkin1" - second parent clock of the internal mux
+
+
+Example for Meson6:
 
 	ethmac: ethernet@c9410000 {
 		compatible = "amlogic,meson6-dwmac", "snps,dwmac";
@@ -23,3 +37,18 @@ Example:
 		clocks = <&clk81>;
 		clock-names = "stmmaceth";
 	}
+
+Example for GXBB:
+	ethmac: ethernet@c9410000 {
+		compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
+		reg = <0x0 0xc9410000 0x0 0x10000>,
+			<0x0 0xc8834540 0x0 0x8>;
+		interrupts = <0 8 1>;
+		interrupt-names = "macirq";
+		clocks = <&clkc CLKID_ETH>,
+				<&clkc CLKID_FCLK_DIV2>,
+				<&clkc CLKID_MPLL2>;
+		clock-names = "stmmaceth", "clkin0", "clkin1";
+		phy-mode = "rgmii";
+		status = "disabled";
+	};
-- 
2.9.3
