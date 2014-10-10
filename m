From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 3/6] dtb: Add 10GbE node to APM X-Gene SoC device tree
Date: Thu,  9 Oct 2014 18:32:04 -0700
Message-ID: <1412904727-23485-4-git-send-email-isubramanian@apm.com>
References: <1412904727-23485-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og120.obsmtp.com ([64.18.0.137]:58796 "HELO
	exprod5og120.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751235AbaJJBcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:32:03 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so689257pdi.24
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:32:02 -0700 (PDT)
In-Reply-To: <1412904727-23485-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 10GbE interface and clock nodes.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm-mustang.dts |  4 ++++
 arch/arm64/boot/dts/apm-storm.dtsi  | 29 +++++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
index b2f5622..2ae782b 100644
--- a/arch/arm64/boot/dts/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm-mustang.dts
@@ -32,3 +32,7 @@
 &menet {
 	status = "ok";
 };
+
+&xgenet {
+	status = "ok";
+};
diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index f391972..d16cc03 100644
--- a/arch/arm64/boot/dts/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm-storm.dtsi
@@ -176,6 +176,16 @@
 				clock-output-names = "menetclk";
 			};
 
+			xge0clk: xge0clk@1f61c000 {
+				compatible = "apm,xgene-device-clock";
+				#clock-cells = <1>;
+				clocks = <&socplldiv2 0>;
+				reg = <0x0 0x1f61c000 0x0 0x1000>;
+				reg-names = "csr-reg";
+				csr-mask = <0x3>;
+				clock-output-names = "xge0clk";
+			};
+
 			sataphy1clk: sataphy1clk@1f21c000 {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
@@ -420,7 +430,8 @@
 			interrupts = <0x0 0x3c 0x4>;
 			dma-coherent;
 			clocks = <&menetclk 0>;
-			local-mac-address = [00 01 73 00 00 01];
+			/* mac address will be overwritten by the bootloader */
+			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "rgmii";
 			phy-handle = <&menetphy>;
 			mdio {
@@ -435,12 +446,26 @@
 			};
 		};
 
+		xgenet: ethernet@1f610000 {
+			compatible = "apm,xgene-enet";
+			status = "disabled";
+			reg = <0x0 0x1f610000 0x0 0xd100>,
+			      <0x0 0x1f600000 0x0 0X400>,
+			      <0x0 0x18000000 0x0 0X200>;
+			reg-names = "enet_csr", "ring_csr", "ring_cmd";
+			interrupts = <0x0 0x60 0x4>;
+			dma-coherent;
+			clocks = <&xge0clk 0>;
+			/* mac address will be overwritten by the bootloader */
+			local-mac-address = [00 00 00 00 00 00];
+			phy-connection-type = "xgmii";
+		};
+
 		rng: rng@10520000 {
 			compatible = "apm,xgene-rng";
 			reg = <0x0 0x10520000 0x0 0x100>;
 			interrupts = <0x0 0x41 0x4>;
 			clocks = <&rngpkaclk 0>;
 		};
-
 	};
 };
-- 
1.9.1
