From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v2 4/5] dtb: xgene: Add MDIO node
Date: Tue, 31 May 2016 17:10:39 -0700
Message-ID: <1464739840-21971-5-git-send-email-isubramanian@apm.com>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464739840-21971-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added mdio node for mdio driver.  Also added phy-handle
reference to the ethernet nodes.

Removed unused mdio subnode within storm menet ethernet node.
Removed unused clock node from storm sgenet1.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Matthias Brugger <mbrugger-IBi9RG/b67k@public.gmane.org>
---
 arch/arm64/boot/dts/apm/apm-merlin.dts     |  9 +++++++
 arch/arm64/boot/dts/apm/apm-mustang.dts    | 12 ++++++++++
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 11 +++++++++
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 38 +++++++++++-------------------
 4 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-merlin.dts b/arch/arm64/boot/dts/apm/apm-merlin.dts
index 387c6a8..c765f26 100644
--- a/arch/arm64/boot/dts/apm/apm-merlin.dts
+++ b/arch/arm64/boot/dts/apm/apm-merlin.dts
@@ -83,3 +83,12 @@
 		status = "ok";
 	};
 };
+
+&mdio {
+	sgenet0phy: phy@3 {
+		reg = <0x0>;
+	};
+	sgenet1phy: phy@2 {
+		reg = <0x2>;
+	};
+};
diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
index 44db32e..c4e2bc4 100644
--- a/arch/arm64/boot/dts/apm/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
@@ -79,3 +79,15 @@
 &mmc0 {
 	status = "ok";
 };
+
+&mdio {
+	menetphy: phy@3 {
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
index c569f76..17333fa 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -625,6 +625,15 @@
 			apm,irq-start = <8>;
 		};
 
+		mdio: mdio@0x1f610000 {
+			compatible = "apm,xgene-mdio-sgmii";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x0 0x1f610000 0x0 0x100>,
+			      <0x0 0X1f61d000 0x0 0X100>;
+			clocks = <&xge0clk 0>;
+		};
+
 		sgenet0: ethernet@1f610000 {
 			compatible = "apm,xgene2-sgenet";
 			status = "disabled";
@@ -637,6 +646,7 @@
 			clocks = <&xge0clk 0>;
 			local-mac-address = [00 01 73 00 00 01];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet0phy>;
 		};
 
 		xgenet1: ethernet@1f620000 {
@@ -659,6 +669,7 @@
 			clocks = <&xge1clk 0>;
 			local-mac-address = [00 01 73 00 00 02];
 			phy-connection-type = "xgmii";
+			phy-handle = <&sgenet1phy>;
 		};
 
 		rng: rng@10520000 {
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index 5147d76..f631fe4 100644
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
@@ -930,21 +929,11 @@
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
 			interrupts = <0x0 0x3c 0x4>;
 			dma-coherent;
-			clocks = <&menetclk 0>;
 			/* mac address will be overwritten by the bootloader */
 			local-mac-address = [00 00 00 00 00 00];
+			clocks = <&menetclk 0>;
 			phy-connection-type = "rgmii";
 			phy-handle = <&menetphy>;
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
 		};
 
 		sgenet0: ethernet@1f210000 {
@@ -957,9 +946,10 @@
 			interrupts = <0x0 0xA0 0x4>,
 				     <0x0 0xA1 0x4>;
 			dma-coherent;
-			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
+			clocks = <&sge0clk 0>;
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
