From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 09/11] dtb: xgene: Add MDIO node
Date: Wed,  6 Jul 2016 17:35:10 -0700
Message-ID: <1467851712-24780-10-git-send-email-isubramanian@apm.com>
References: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35943 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504AbcGGAfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:35:31 -0400
Received: by mail-pf0-f176.google.com with SMTP id t190so855358pfb.3
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 17:35:31 -0700 (PDT)
In-Reply-To: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added mdio node for mdio driver.  Also added phy-handle
reference to the ethernet nodes.

Removed unused mdio subnode within storm menet ethernet node.
Removed unused clock node from storm sgenet1.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 arch/arm64/boot/dts/apm/apm-mustang.dts | 12 +++++++++++
 arch/arm64/boot/dts/apm/apm-storm.dtsi  | 36 ++++++++++++---------------------
 2 files changed, 25 insertions(+), 23 deletions(-)

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
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index 5147d76..a415b3a 100644
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
 
+		mdio: mdio@0x17020000 {
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
@@ -934,17 +933,7 @@
 			/* mac address will be overwritten by the bootloader */
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "rgmii";
-			phy-handle = <&menetphy>;
-			mdio {
-				compatible = "apm,xgene-mdio";
-				#address-cells = <1>;
-				#size-cells = <0>;
-				menetphy: menetphy@3 {
-					compatible = "ethernet-phy-id001c.c915";
-					reg = <0x3>;
-				};
-
-			};
+			phy-handle = <&menet0phy>;
 		};
 
 		sgenet0: ethernet@1f210000 {
@@ -960,6 +949,7 @@
 			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet0phy>;
 		};
 
 		sgenet1: ethernet@1f210030 {
@@ -973,9 +963,9 @@
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
