From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v1 4/6] dtb: xgene: Add MDIO node
Date: Fri, 27 May 2016 00:22:46 -0700
Message-ID: <1464333768-26150-5-git-send-email-isubramanian@apm.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464333768-26150-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added mdio node for mdio driver.  Also added phy-handle
reference to the ethernet nodes.  Removed unused mdio
subnode within ethernet node.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
---
 arch/arm64/boot/dts/apm/apm-merlin.dts     | 10 ++++++++++
 arch/arm64/boot/dts/apm/apm-mustang.dts    | 12 ++++++++++++
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 11 +++++++++++
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 20 ++++++++++----------
 4 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-merlin.dts b/arch/arm64/boot/dts/apm/apm-merlin.dts
index 387c6a8..7d47a0f 100644
--- a/arch/arm64/boot/dts/apm/apm-merlin.dts
+++ b/arch/arm64/boot/dts/apm/apm-merlin.dts
@@ -83,3 +83,13 @@
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
+
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
index ba04877..8106957 100644
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
index 5147d76..18f694ea 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -921,6 +921,14 @@
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
@@ -935,16 +943,6 @@
 			local-mac-address = [00 00 00 00 00 00];
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
@@ -960,6 +958,7 @@
 			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "sgmii";
+			phy-handle = <&sgenet0phy>;
 		};
 
 		sgenet1: ethernet@1f210030 {
@@ -976,6 +975,7 @@
 			clocks = <&sge1clk 0>;
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
