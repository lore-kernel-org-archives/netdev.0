From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net v4 1/2] imx7s/imx7d has the ptp interrupt newly added as well.
Date: Tue, 31 Oct 2017 13:16:46 -0700
Message-ID: <20171031201647.13006-1-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com, andrew@lunn.ch,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:48378 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752023AbdJaUQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 16:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For imx7, "int0" is the interrupt for queue 0 and ENET_MII
"int1" is for queue 1
"int2" is for queue 2

For imx6sx, "int0" handles all 3 queues and ENET_MII

And of course, the "pps" interrupt is for the PTP_CLOCK_PPS interrupts
This will help document what each interrupt does.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v2: replaced empty names with "int0","int1", or "int2"

reordered imx7 interrupts so that "int0", for queue 0, is first.

v3: renamed "ptp" interrupt to "pps", added binding documentation
for interrupt-names.

v4: add blank, ie s/"int0","pps"/"int0", "pps"/ as suggested by Andrew Lunn
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 13 +++++++++++++
 arch/arm/boot/dts/imx6qdl.dtsi                    |  1 +
 arch/arm/boot/dts/imx6sx.dtsi                     |  2 ++
 arch/arm/boot/dts/imx6ul.dtsi                     |  2 ++
 arch/arm/boot/dts/imx7d.dtsi                      |  6 ++++--
 arch/arm/boot/dts/imx7s.dtsi                      |  6 ++++--
 6 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 6f55bdd52f8a..f0dc94409107 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -34,6 +34,19 @@ Optional properties:
 - fsl,err006687-workaround-present: If present indicates that the system has
   the hardware workaround for ERR006687 applied and does not need a software
   workaround.
+ -interrupt-names:  names of the interrupts listed in interrupts property in
+  the same order. The defaults if not specified are
+  __Number of interrupts__   __Default__
+	1			"int0"
+	2			"int0", "pps"
+	3			"int0", "int1", "int2"
+	4			"int0", "int1", "int2", "pps"
+  The order may be changed as long as they correspond to the interrupts
+  property. Currently, only i.mx7 uses "int1" and "int2". They correspond to
+  tx/rx queues 1 and 2. "int0" will be used for queue 0 and ENET_MII interrupts.
+  For imx6sx, "int0" handles all 3 queues and ENET_MII. "pps" is for the pulse
+  per second interrupt associated with 1588 precision time protocol(PTP).
+
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
diff --git a/arch/arm/boot/dts/imx6qdl.dtsi b/arch/arm/boot/dts/imx6qdl.dtsi
index 8884b4a3cafb..f97dee04b9be 100644
--- a/arch/arm/boot/dts/imx6qdl.dtsi
+++ b/arch/arm/boot/dts/imx6qdl.dtsi
@@ -1017,6 +1017,7 @@
 			fec: ethernet@02188000 {
 				compatible = "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "int0", "pps";
 				interrupts-extended =
 					<&intc 0 118 IRQ_TYPE_LEVEL_HIGH>,
 					<&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
diff --git a/arch/arm/boot/dts/imx6sx.dtsi b/arch/arm/boot/dts/imx6sx.dtsi
index 6c7eb54be9e2..7f3773b88c47 100644
--- a/arch/arm/boot/dts/imx6sx.dtsi
+++ b/arch/arm/boot/dts/imx6sx.dtsi
@@ -861,6 +861,7 @@
 			fec1: ethernet@02188000 {
 				compatible = "fsl,imx6sx-fec", "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "int0", "pps";
 				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6SX_CLK_ENET>,
@@ -970,6 +971,7 @@
 			fec2: ethernet@021b4000 {
 				compatible = "fsl,imx6sx-fec", "fsl,imx6q-fec";
 				reg = <0x021b4000 0x4000>;
+				interrupt-names = "int0", "pps";
 				interrupts = <GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 103 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6SX_CLK_ENET>,
diff --git a/arch/arm/boot/dts/imx6ul.dtsi b/arch/arm/boot/dts/imx6ul.dtsi
index f11a241a340d..5ac00ff959b2 100644
--- a/arch/arm/boot/dts/imx6ul.dtsi
+++ b/arch/arm/boot/dts/imx6ul.dtsi
@@ -476,6 +476,7 @@
 			fec2: ethernet@020b4000 {
 				compatible = "fsl,imx6ul-fec", "fsl,imx6q-fec";
 				reg = <0x020b4000 0x4000>;
+				interrupt-names = "int0", "pps";
 				interrupts = <GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 121 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6UL_CLK_ENET>,
@@ -775,6 +776,7 @@
 			fec1: ethernet@02188000 {
 				compatible = "fsl,imx6ul-fec", "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "int0", "pps";
 				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6UL_CLK_ENET>,
diff --git a/arch/arm/boot/dts/imx7d.dtsi b/arch/arm/boot/dts/imx7d.dtsi
index 4d308d17f040..8b9c8c0695df 100644
--- a/arch/arm/boot/dts/imx7d.dtsi
+++ b/arch/arm/boot/dts/imx7d.dtsi
@@ -114,9 +114,11 @@
 	fec2: ethernet@30bf0000 {
 		compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
 		reg = <0x30bf0000 0x10000>;
-		interrupts = <GIC_SPI 100 IRQ_TYPE_LEVEL_HIGH>,
+		interrupt-names = "int0", "int1", "int2", "pps";
+		interrupts = <GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>,
+			<GIC_SPI 100 IRQ_TYPE_LEVEL_HIGH>,
 			<GIC_SPI 101 IRQ_TYPE_LEVEL_HIGH>,
-			<GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>;
+			<GIC_SPI 103 IRQ_TYPE_LEVEL_HIGH>;
 		clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
 			<&clks IMX7D_ENET_AXI_ROOT_CLK>,
 			<&clks IMX7D_ENET2_TIME_ROOT_CLK>,
diff --git a/arch/arm/boot/dts/imx7s.dtsi b/arch/arm/boot/dts/imx7s.dtsi
index 82ad26e766eb..966b97fdc394 100644
--- a/arch/arm/boot/dts/imx7s.dtsi
+++ b/arch/arm/boot/dts/imx7s.dtsi
@@ -1007,9 +1007,11 @@
 			fec1: ethernet@30be0000 {
 				compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
 				reg = <0x30be0000 0x10000>;
-				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
+				interrupt-names = "int0", "int1", "int2", "pps";
+				interrupts = <GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					<GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>,
-					<GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>;
+					<GIC_SPI 121 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
 					<&clks IMX7D_ENET_AXI_ROOT_CLK>,
 					<&clks IMX7D_ENET1_TIME_ROOT_CLK>,
-- 
2.11.0
