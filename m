From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 5/6] dtb: xgene: Remove clock nodes
Date: Fri, 27 May 2016 00:22:47 -0700
Message-ID: <1464333768-26150-6-git-send-email-isubramanian@apm.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33793 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128AbcE0HXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 03:23:12 -0400
Received: by mail-pf0-f169.google.com with SMTP id y69so39121009pfb.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 00:23:11 -0700 (PDT)
In-Reply-To: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the MDIO will be responsible for clock reset, removing the clock
nodes from shadowcat xge0 and storm sgenet1.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 12 ------------
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 18 ++++--------------
 2 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index 8106957..f27563d 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -299,17 +299,6 @@
 				clock-output-names = "pcie1clk";
 			};
 
-			xge0clk: xge0clk@1f61c000 {
-				compatible = "apm,xgene-device-clock";
-				#clock-cells = <1>;
-				clocks = <&socplldiv2 0>;
-				reg = <0x0 0x1f61c000 0x0 0x1000>;
-				reg-names = "csr-reg";
-				enable-mask = <0x3>;
-				csr-mask = <0x3>;
-				clock-output-names = "xge0clk";
-			};
-
 			xge1clk: xge1clk@1f62c000 {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
@@ -643,7 +632,6 @@
 			interrupts = <0 96 4>,
 				     <0 97 4>;
 			dma-coherent;
-			clocks = <&xge0clk 0>;
 			local-mac-address = [00 01 73 00 00 01];
 			phy-connection-type = "sgmii";
 			phy-handle = <&sgenet0phy>;
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index 18f694ea..f631fe4 100644
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
@@ -938,9 +929,9 @@
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
 			interrupts = <0x0 0x3c 0x4>;
 			dma-coherent;
-			clocks = <&menetclk 0>;
 			/* mac address will be overwritten by the bootloader */
 			local-mac-address = [00 00 00 00 00 00];
+			clocks = <&menetclk 0>;
 			phy-connection-type = "rgmii";
 			phy-handle = <&menetphy>;
 		};
@@ -955,8 +946,8 @@
 			interrupts = <0x0 0xA0 0x4>,
 				     <0x0 0xA1 0x4>;
 			dma-coherent;
-			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
+			clocks = <&sge0clk 0>;
 			phy-connection-type = "sgmii";
 			phy-handle = <&sgenet0phy>;
 		};
@@ -972,7 +963,6 @@
 				     <0x0 0xAD 0x4>;
 			port-id = <1>;
 			dma-coherent;
-			clocks = <&sge1clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "sgmii";
 			phy-handle = <&sgenet1phy>;
-- 
1.9.1
