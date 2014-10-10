From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 1/3] dtb: Add SGMII based 1GbE node to APM X-Gene SoC device tree
Date: Fri, 10 Oct 2014 13:18:34 -0700
Message-ID: <1412972316-16344-2-git-send-email-isubramanian@apm.com>
References: <1412972316-16344-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og116.obsmtp.com ([64.18.0.147]:46558 "HELO
	exprod5og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751866AbaJJUSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 16:18:31 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so2375502pab.37
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 13:18:30 -0700 (PDT)
In-Reply-To: <1412972316-16344-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm-mustang.dts |  4 ++++
 arch/arm64/boot/dts/apm-storm.dtsi  | 24 ++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
index 2ae782b..71a1489 100644
--- a/arch/arm64/boot/dts/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm-mustang.dts
@@ -33,6 +33,10 @@
 	status = "ok";
 };
 
+&sgenet0 {
+	status = "ok";
+};
+
 &xgenet {
 	status = "ok";
 };
diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index d16cc03..f45bbfe 100644
--- a/arch/arm64/boot/dts/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm-storm.dtsi
@@ -176,6 +176,16 @@
 				clock-output-names = "menetclk";
 			};
 
+			sge0clk: sge0clk@1f21c000 {
+				compatible = "apm,xgene-device-clock";
+				#clock-cells = <1>;
+				clocks = <&socplldiv2 0>;
+				reg = <0x0 0x1f21c000 0x0 0x1000>;
+				reg-names = "csr-reg";
+				csr-mask = <0x3>;
+				clock-output-names = "sge0clk";
+			};
+
 			xge0clk: xge0clk@1f61c000 {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
@@ -446,6 +456,20 @@
 			};
 		};
 
+		sgenet0: ethernet@1f210000 {
+			compatible = "apm,xgene-enet";
+			status = "disabled";
+			reg = <0x0 0x1f210000 0x0 0x10000>,
+			      <0x0 0x1f200000 0x0 0X10000>,
+			      <0x0 0x1B000000 0x0 0X20000>;
+			reg-names = "enet_csr", "ring_csr", "ring_cmd";
+			interrupts = <0x0 0xA0 0x4>;
+			dma-coherent;
+			clocks = <&sge0clk 0>;
+			local-mac-address = [00 00 00 00 00 00];
+			phy-connection-type = "sgmii";
+		};
+
 		xgenet: ethernet@1f610000 {
 			compatible = "apm,xgene-enet";
 			status = "disabled";
-- 
1.9.1
