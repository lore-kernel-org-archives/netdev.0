From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v7 10/12] dtb: xgene: Add MDIO node
Date: Mon, 25 Jul 2016 17:12:45 -0700
Message-ID: <1469491967-28627-11-git-send-email-isubramanian@apm.com>
References: <1469491967-28627-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35277 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536AbcGZAMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:12:48 -0400
Received: by mail-pa0-f52.google.com with SMTP id iw10so65767804pac.2
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 17:12:48 -0700 (PDT)
In-Reply-To: <1469491967-28627-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added mdio node for mdio driver.  Also added phy-handle
reference to the ethernet nodes.

Removed unused clock node from storm sgenet1.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 arch/arm64/boot/dts/apm/apm-merlin.dts     |  6 ++++++
 arch/arm64/boot/dts/apm/apm-mustang.dts    | 12 ++++++++++++
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 11 ++++++++++-
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 26 +++++++++++++-------------
 4 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-merlin.dts b/arch/arm64/boot/dts/apm/apm-merlin.dts
index 387c6a8..b0f6441 100644
--- a/arch/arm64/boot/dts/apm/apm-merlin.dts
+++ b/arch/arm64/boot/dts/apm/apm-merlin.dts
@@ -83,3 +83,9 @@
 		status = "ok";
 	};
 };
+
+&mdio {
+	sgenet0phy: phy@0 {
+		reg = <0x0>;
+	};
+};
diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
index 44db32e..b7fb5d9 100644
--- a/arch/arm64/boot/dts/apm/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
@@ -79,3 +79,15 @@
 &mmc0 {
 	status = "ok";
 };
+
+&mdio {
+	menet0phy: phy@3 {
+		reg = <0x3>;
+	};
+	sgenet0phy: phy@4 {
+		reg = <0x4>;
+	};
+	sgenet1phy: phy@5 {
+		reg = <0x5>;
+	};
+};
diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index c569f76..2e1e5da 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -625,10 +625,18 @@
 			apm,irq-start = <8>;
 		};
 
+		mdio: mdio@1f610000 {
+			compatible = "apm,xgene-mdio-xfi";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x0 0x1f610000 0x0 0xd100>;
+			clocks = <&xge0clk 0>;
+		};
+
 		sgenet0: ethernet@1f610000 {
 			compatible = "apm,xgene2-sgenet";
 			status = "disabled";
-			reg = <0x0 0x1f610000 0x0 0x10000>,
+			reg = <0x0 0x1f610000 0x0 0xd100>,
 			      <0x0 0x1f600000 0x0 0Xd100>,
 			      <0x0 0x20000000 0x0 0X20000>;
 			interrupts = <0 96 4>,
@@ -637,6 +645,7 @@
 			clocks = <&xge0clk 0>;
 			local-mac-address = [00 01 73 00 00 01];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet0phy>;
 		};
 
 		xgenet1: ethernet@1f620000 {
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index 5147d76..6bf7cbe 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -237,20 +237,11 @@
 				clocks = <&socplldiv2 0>;
 				reg = <0x0 0x1f21c000 0x0 0x1000>;
 				reg-names = "csr-reg";
-				csr-mask = <0x3>;
+				csr-mask = <0xa>;
+				enable-mask = <0xf>;
 				clock-output-names = "sge0clk";
 			};
 
-			sge1clk: sge1clk@1f21c000 {
-				compatible = "apm,xgene-device-clock";
-				#clock-cells = <1>;
-				clocks = <&socplldiv2 0>;
-				reg = <0x0 0x1f21c000 0x0 0x1000>;
-				reg-names = "csr-reg";
-				csr-mask = <0xc>;
-				clock-output-names = "sge1clk";
-			};
-
 			xge0clk: xge0clk@1f61c000 {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
@@ -921,6 +912,14 @@
 			clocks = <&rtcclk 0>;
 		};
 
+		mdio: mdio@17020000 {
+			compatible = "apm,xgene-mdio-rgmii";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x0 0x17020000 0x0 0xd100>;
+			clocks = <&menetclk 0>;
+		};
+
 		menet: ethernet@17020000 {
 			compatible = "apm,xgene-enet";
 			status = "disabled";
@@ -934,7 +933,7 @@
 			/* mac address will be overwritten by the bootloader */
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "rgmii";
-			phy-handle = <&menetphy>;
+			phy-handle = <&menet0phy>,<&menetphy>;
 			mdio {
 				compatible = "apm,xgene-mdio";
 				#address-cells = <1>;
@@ -960,6 +959,7 @@
 			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet0phy>;
 		};
 
 		sgenet1: ethernet@1f210030 {
@@ -973,9 +973,9 @@
 				     <0x0 0xAD 0x4>;
 			port-id = <1>;
 			dma-coherent;
-			clocks = <&sge1clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet1phy>;
 		};
 
 		xgenet: ethernet@1f610000 {
-- 
1.9.1
