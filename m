From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v2 3/4] dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Fri, 11 Apr 2014 20:06:23 -0700
Message-ID: <1397271984-23405-4-git-send-email-isubramanian@apm.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1397271984-23405-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds bindings for APM X-Gene SoC ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 arch/arm64/boot/dts/apm-mustang.dts |    4 ++++
 arch/arm64/boot/dts/apm-storm.dtsi  |   18 +++++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

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
index 93f4b2d..6b2b7f9 100644
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
@@ -339,5 +338,18 @@
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
+			phy-addr = <3>;
+			phy-mode = "rgmii";
+		};
 	};
 };
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
