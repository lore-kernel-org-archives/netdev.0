From: <dinguyen@altera.com>
Subject: [PATCH 2/3] dts: socfpga: Add DTS entry for adding the stmmac glue layer for stmmac.
Date: Wed, 26 Mar 2014 22:45:11 -0500
Message-ID: <1395891912-26855-3-git-send-email-dinguyen@altera.com>
References: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <srinivas.kandagatla@st.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <arm@kernel.org>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, Dinh Nguyen <dinguyen@altera.com>
To: <dinh.linux@gmail.com>, <arnd@arndb.de>, <davem@davemloft.net>,
	<peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:36111
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752136AbaC0DsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 23:48:07 -0400
In-Reply-To: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

This patch adds the dts bindings documenation for the Altera SOCFPGA glue
layer for the Synopsys STMMAC ethernet driver.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |   27 ++++++++++++++++++++
 arch/arm/boot/dts/socfpga.dtsi                     |    2 ++
 arch/arm/boot/dts/socfpga_arria5_socdk.dts         |   21 +++++++++++++++
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |   14 ++++++++++
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |   17 ++++++++++++
 arch/arm/boot/dts/socfpga_vt.dts                   |    5 ++++
 6 files changed, 86 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socfpga-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
new file mode 100644
index 0000000..636f0ac
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -0,0 +1,27 @@
+Altera SOCFPGA SoC DWMAC controller
+
+This is a variant of the dwmac/stmmac driver an inherits all descriptions
+present in Documentation/devicetree/bindings/net/stmmac.txt.
+
+The device node has additional properties:
+
+Required properties:
+ - compatible	: Should contain "altr,socfpga-stmmac" along with
+		  "snps,dwmac" and any applicable more detailed
+		  designware version numbers documented in stmmac.txt
+ - altr,sysmgr-syscon : Should be the phandle to the system manager node that
+   encompasses the glue register, the register offset, and the register shift.
+
+Example:
+
+gmac0: ethernet@ff700000 {
+	compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
+	altr,sysmgr-syscon = <&sysmgr 0x60 0>;
+	status = "disabled";
+	reg = <0xff700000 0x2000>;
+	interrupts = <0 115 4>;
+	interrupt-names = "macirq";
+	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+	clocks = <&emac_0_clk>;
+	clocks-names = "stmmaceth";
+};
diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 537f1a5..ba51d69 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -443,6 +443,7 @@
 
 		gmac0: ethernet@ff700000 {
 			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
+			altr,sysmgr-syscon = <&sysmgr 0x60 0>;
 			reg = <0xff700000 0x2000>;
 			interrupts = <0 115 4>;
 			interrupt-names = "macirq";
@@ -454,6 +455,7 @@
 
 		gmac1: ethernet@ff702000 {
 			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
+			altr,sysmgr-syscon = <&sysmgr 0x60 2>;
 			reg = <0xff702000 0x2000>;
 			interrupts = <0 120 4>;
 			interrupt-names = "macirq";
diff --git a/arch/arm/boot/dts/socfpga_arria5_socdk.dts b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
index 5beffb2..a87ee1c 100644
--- a/arch/arm/boot/dts/socfpga_arria5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
@@ -37,4 +37,25 @@
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
+&gmac1 {
+	status = "okay";
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
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
index 2ee52ab..ae16d97 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
@@ -38,3 +38,17 @@
 		ethernet0 = &gmac1;
 	};
 };
+
+&gmac1 {
+	status = "okay";
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
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
index 50b99a2..b79e2a2 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
@@ -30,8 +30,25 @@
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
 
 &gmac1 {
 	status = "okay";
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
diff --git a/arch/arm/boot/dts/socfpga_vt.dts b/arch/arm/boot/dts/socfpga_vt.dts
index d1ec0ca..dde2c66 100644
--- a/arch/arm/boot/dts/socfpga_vt.dts
+++ b/arch/arm/boot/dts/socfpga_vt.dts
@@ -75,3 +75,8 @@
 		};
 	};
 };
+
+&gmac0 {
+	status = "okay";
+	phy-mode = "gmii";
+};
-- 
1.7.9.5
