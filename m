From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v9 3/4] dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Mon, 14 Jul 2014 15:18:04 -0700
Message-ID: <1405376285-23008-4-git-send-email-isubramanian@apm.com>
References: <1405376285-23008-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og122.obsmtp.com ([64.18.0.192]:48324 "HELO
	exprod5og122.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757430AbaGNWR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:17:57 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so5930790pde.20
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 15:17:55 -0700 (PDT)
In-Reply-To: <1405376285-23008-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds bindings for APM X-Gene SoC ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm-mustang.dts |  4 ++++
 arch/arm64/boot/dts/apm-storm.dtsi  | 30 +++++++++++++++++++++++++++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
index 6541962..b2f5622 100644
--- a/arch/arm64/boot/dts/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm-mustang.dts
@@ -28,3 +28,7 @@
 &serial0 {
 	status = "ok";
 };
+
+&menet {
+	status = "ok";
+};
diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index 40aa96c..c0aceef 100644
--- a/arch/arm64/boot/dts/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm-storm.dtsi
@@ -167,14 +167,13 @@
 				clock-output-names = "ethclk";
 			};
 
-			eth8clk: eth8clk {
+			menetclk: menetclk {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
 				clocks = <&ethclk 0>;
-				clock-names = "eth8clk";
 				reg = <0x0 0x1702C000 0x0 0x1000>;
 				reg-names = "csr-reg";
-				clock-output-names = "eth8clk";
+				clock-output-names = "menetclk";
 			};
 
 			sataphy1clk: sataphy1clk@1f21c000 {
@@ -397,5 +396,30 @@
 			#clock-cells = <1>;
 			clocks = <&rtcclk 0>;
 		};
+
+		menet: ethernet@17020000 {
+			compatible = "apm,xgene-enet";
+			status = "disabled";
+			reg = <0x0 0x17020000 0x0 0xd100>,
+			      <0x0 0X17030000 0x0 0X400>,
+			      <0x0 0X10000000 0x0 0X200>;
+			reg-names = "enet_csr", "ring_csr", "ring_cmd";
+			interrupts = <0x0 0x3c 0x4>;
+			dma-coherent;
+			clocks = <&menetclk 0>;
+			local-mac-address = [00 01 73 00 00 01];
+			phy-connection-type = "rgmii";
+			phy-handle = <&menetphy>;
+			mdio {
+				compatible = "apm,xgene-mdio";
+				#address-cells = <1>;
+				#size-cells = <0>;
+				menetphy: menetphy@3 {
+					compatible = "ethernet-phy-id001c.c915";
+					reg = <0x3>;
+				};
+
+			};
+		};
 	};
 };
-- 
1.9.1
