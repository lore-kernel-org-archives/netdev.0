From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 3/4] dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Mon,  5 May 2014 14:47:26 -0700
Message-ID: <1399326447-2329-4-git-send-email-isubramanian@apm.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399326447-2329-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds bindings for APM X-Gene SoC ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm-mustang.dts |    4 ++++
 arch/arm64/boot/dts/apm-storm.dtsi  |   27 ++++++++++++++++++++++++---
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
index 1247ca1..e2fb1ef 100644
--- a/arch/arm64/boot/dts/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm-mustang.dts
@@ -24,3 +24,7 @@
 		reg = < 0x1 0x00000000 0x0 0x80000000 >; /* Updated by bootloader */
 	};
 };
+
+&menet {
+	status = "ok";
+};
diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index 93f4b2d..e1e3d5d 100644
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
@@ -339,5 +338,27 @@
 			phys = <&phy3 0>;
 			phy-names = "sata-phy";
 		};
+
+		menet: ethernet@17020000 {
+			compatible = "apm,xgene-enet";
+			status = "disabled";
+			reg = <0x0 0x17020000 0x0 0xd100>,
+			      <0x0 0X17030000 0x0 0X400>,
+			      <0x0 0X10000000 0x0 0X200>;
+			interrupts = <0x0 0x3c 0x4>;
+			clocks = <&menetclk 0>;
+			local-mac-address = [00 01 73 00 00 01];
+			phy-connection-type = "rgmii";
+			phy-handle = <&menetphy>;
+			mdio {
+				compatible = "apm,xgene-mdio";
+				#address-cells = <1>;
+				#size-cells = <0>;
+				menetphy: menetphy@3 {
+					reg = <0x3>;
+				};
+
+			};
+		};
 	};
 };
-- 
1.7.9.5
