From: <dinguyen@altera.com>
Subject: [PATCHv2 2/2] dts: socfpga: Add DTS entry for adding the stmmac glue layer for stmmac.
Date: Thu, 6 Feb 2014 17:19:55 -0600
Message-ID: <1391728795-30435-2-git-send-email-dinguyen@altera.com>
References: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <devicetree@vger.kernel.org>,
	Dinh Nguyen <dinguyen@altera.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"Rob Herring" <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	"Kumar Gala" <galak@codeaurora.org>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:7446
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751004AbaBFXWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 18:22:18 -0500
In-Reply-To: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

This patch adds the dts bindings documenation for the Altera SOCFPGA glue
layer for the Synopsys STMMAC ethernet driver.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Pawel Moll <pawel.moll@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
Cc: Kumar Gala <galak@codeaurora.org>
Cc: Vince Bridgers <vbridgers2013@gmail.com>
---
v2: Use the dwmac-sti as an example for a glue layer and split patch up
to have dts as a separate patch. Also cc dts maintainers since there is
a new binding.
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |   35 ++++++++++++++
 arch/arm/boot/dts/socfpga.dtsi                     |   51 +++++++++++++-------
 arch/arm/boot/dts/socfpga_arria5_socdk.dts         |   24 +++++++++
 arch/arm/boot/dts/socfpga_cyclone5.dtsi            |    6 ---
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |   18 +++++++
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |   22 ++++++++-
 arch/arm/boot/dts/socfpga_vt.dts                   |   13 +++--
 7 files changed, 140 insertions(+), 29 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/socfpga-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
new file mode 100644
index 0000000..d53d376
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -0,0 +1,35 @@
+Altera SOCFPGA SoC DWMAC controller
+
+The device node has following properties.
+
+Required properties:
+ - compatible	: Should contain "altr,socfpga-stmmac"
+ - altr,sysmgr-syscon : Should be the phandle to the system manager node that
+   encompasses the glue register, and the register offset.
+
+Sub-nodes:
+The dwmac core should be added as subnode to SOCFPGA dwmac glue.
+- dwmac :	The binding details of dwmac can be found in
+  Documentation/devicetree/bindings/net/stmmac.txt
+
+Example:
+
+ethernet0: ethernet0 {
+	#address-cells = <1>;
+	#size-cells = <1>;
+
+	compatible = "altr,socfpga-stmmac";
+	altr,sysmgr-syscon = <&sysmgr 0x60>;
+	status = "disabled";
+	ranges;
+
+	gmac0: gmac0@ff700000 {
+		compatible = "snps,dwmac-3.70a", "snps,dwmac";
+		reg = <0xff700000 0x2000>;
+		interrupts = <0 115 4>;
+		interrupt-names = "macirq";
+		mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+		clocks = <&emac0_clk>;
+		clock-names = "stmmaceth";
+	};
+};
diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 8c4adb7..ebf6113 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -442,26 +442,43 @@
 				};
 			};
 
-		gmac0: ethernet@ff700000 {
-			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
-			reg = <0xff700000 0x2000>;
-			interrupts = <0 115 4>;
-			interrupt-names = "macirq";
-			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-			clocks = <&emac0_clk>;
-			clock-names = "stmmaceth";
+		ethernet0: ethernet0 {
+			#address-cells = <1>;
+			#size-cells = <1>;
+			compatible = "altr,socfpga-stmmac";
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
 			status = "disabled";
+			ranges;
+
+			gmac0: gmac0@ff700000 {
+				compatible = "snps,dwmac-3.70a", "snps,dwmac";
+				reg = <0xff700000 0x2000>;
+				interrupts = <0 115 4>;
+				interrupt-names = "macirq";
+				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+				clocks = <&emac0_clk>;
+				clock-names = "stmmaceth";
+			};
 		};
 
-		gmac1: ethernet@ff702000 {
-			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
-			reg = <0xff702000 0x2000>;
-			interrupts = <0 120 4>;
-			interrupt-names = "macirq";
-			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-			clocks = <&emac1_clk>;
-			clock-names = "stmmaceth";
+		ethernet1: ethernet1 {
+			#address-cells = <1>;
+			#size-cells = <1>;
+			compatible = "altr,socfpga-stmmac";
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
 			status = "disabled";
+			ranges;
+
+			gmac1: gmac1@ff702000 {
+				device_type = "network";
+				compatible = "snps,dwmac-3.70a", "snps,dwmac";
+				reg = <0xff702000 0x2000>;
+				interrupts = <0 120 4>;
+				interrupt-names = "macirq";
+				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+				clocks = <&emac1_clk>;
+				clock-names = "stmmaceth";
+			};
 		};
 
 		L2: l2-cache@fffef000 {
@@ -538,7 +555,7 @@
 			reg = <0xffd05000 0x1000>;
 		};
 
-		sysmgr@ffd08000 {
+		sysmgr: sysmgr@ffd08000 {
 				compatible = "altr,sys-mgr", "syscon";
 				reg = <0xffd08000 0x4000>;
 			};
diff --git a/arch/arm/boot/dts/socfpga_arria5_socdk.dts b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
index 5beffb2..2d6b38b 100644
--- a/arch/arm/boot/dts/socfpga_arria5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
@@ -37,4 +37,28 @@
 		*/
 		ethernet0 = &gmac1;
 	};
+
+	aliases {
+		/* this allow the ethaddr uboot environmnet variable contents
+		 * to be added to the gmac1 device tree blob.
+		 */
+		ethernet0 = &gmac1;
+	};
+};
+
+&ethernet1 {
+	status = "okay";
+};
+
+&gmac1 {
+	phy-mode = "rgmii";
+
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <2600>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <2000>;
 };
diff --git a/arch/arm/boot/dts/socfpga_cyclone5.dtsi b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
index ca41b0e..454148d 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5.dtsi
+++ b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
@@ -39,12 +39,6 @@
 			};
 		};
 
-		ethernet@ff702000 {
-			phy-mode = "rgmii";
-			phy-addr = <0xffffffff>; /* probe for phy addr */
-			status = "okay";
-		};
-
 		timer0@ffc08000 {
 			clock-frequency = <100000000>;
 		};
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
index 2ee52ab..9b3b01b 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
@@ -38,3 +38,21 @@
 		ethernet0 = &gmac1;
 	};
 };
+
+&ethernet1 {
+	status = "okay";
+};
+
+&gmac1 {
+	phy-mode = "rgmii";
+
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <2600>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <2000>;
+};
+
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
index 50b99a2..469bb5c 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
@@ -30,8 +30,28 @@
 		device_type = "memory";
 		reg = <0x0 0x40000000>; /* 1GB */
 	};
+
+	aliases {
+		/* this allow the ethaddr uboot environmnet variable contents
+		 * to be added to the gmac1 device tree blob.
+		 */
+		ethernet0 = &gmac1;
+	};
 };
 
-&gmac1 {
+&ethernet1 {
 	status = "okay";
 };
+
+&gmac1 {
+	phy-mode = "rgmii";
+
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <2600>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <2000>;
+};
diff --git a/arch/arm/boot/dts/socfpga_vt.dts b/arch/arm/boot/dts/socfpga_vt.dts
index 222313f..418472c 100644
--- a/arch/arm/boot/dts/socfpga_vt.dts
+++ b/arch/arm/boot/dts/socfpga_vt.dts
@@ -52,11 +52,6 @@
 			};
 		};
 
-		ethernet@ff700000 {
-			phy-mode = "gmii";
-			status = "okay";
-		};
-
 		timer0@ffc08000 {
 			clock-frequency = <7000000>;
 		};
@@ -86,3 +81,11 @@
 		};
 	};
 };
+
+&ethernet0 {
+        status = "okay";
+};
+
+&gmac0 {
+	phy-mode = "gmii";
+};
-- 
1.7.9.5
