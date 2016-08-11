From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 4/4] ARM: dts: hix5hd2: add gmac clock and reset property
Date: Thu, 11 Aug 2016 17:01:55 +0800
Message-ID: <1470906115-155569-5-git-send-email-lidongpo@hisilicon.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<mturquette@baylibre.com>, <sboyd@codeaurora.org>,
	<linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add clock and reset property for gmac node.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 arch/arm/boot/dts/hisi-x5hd2-dkb.dts |  2 ++
 arch/arm/boot/dts/hisi-x5hd2.dtsi    | 15 +++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/hisi-x5hd2-dkb.dts b/arch/arm/boot/dts/hisi-x5hd2-dkb.dts
index d13af84..9da9283 100644
--- a/arch/arm/boot/dts/hisi-x5hd2-dkb.dts
+++ b/arch/arm/boot/dts/hisi-x5hd2-dkb.dts
@@ -57,6 +57,7 @@
 	#size-cells = <0>;
 	phy-handle = <&phy2>;
 	phy-mode = "mii";
+	hisilicon,phy-reset-delays-us = <1000 1000 20000>;
 	/* Placeholder, overwritten by bootloader */
 	mac-address = [00 00 00 00 00 00];
 	status = "okay";
@@ -71,6 +72,7 @@
 	#size-cells = <0>;
 	phy-handle = <&phy1>;
 	phy-mode = "rgmii";
+	hisilicon,phy-reset-delays-us = <10000 10000 30000>;
 	/* Placeholder, overwritten by bootloader */
 	mac-address = [00 00 00 00 00 00];
 	status = "okay";
diff --git a/arch/arm/boot/dts/hisi-x5hd2.dtsi b/arch/arm/boot/dts/hisi-x5hd2.dtsi
index fdcc23d..c391ce6 100644
--- a/arch/arm/boot/dts/hisi-x5hd2.dtsi
+++ b/arch/arm/boot/dts/hisi-x5hd2.dtsi
@@ -413,6 +413,7 @@
 				compatible = "hisilicon,hix5hd2-clock";
 				reg = <0 0x2000>;
 				#clock-cells = <1>;
+				#reset-cells = <2>;
 			};
 		};
 
@@ -436,18 +437,24 @@
 		};
 
 		gmac0: ethernet@1840000 {
-			compatible = "hisilicon,hix5hd2-gmac";
+			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
 			reg = <0x1840000 0x1000>,<0x184300c 0x4>;
 			interrupts = <0 71 4>;
-			clocks = <&clock HIX5HD2_MAC0_CLK>;
+			clocks = <&clock HIX5HD2_MAC0_CLK>, <&clock HIX5HD2_MAC_IFC0_CLK>;
+			clock-names = "mac_core", "mac_ifc";
+			resets = <&clock 0xcc 8>, <&clock 0xcc 10>, <&clock 0x120 4>;
+			reset-names = "mac_core", "mac_ifc", "phy";
 			status = "disabled";
 		};
 
 		gmac1: ethernet@1841000 {
-			compatible = "hisilicon,hix5hd2-gmac";
+			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
 			reg = <0x1841000 0x1000>,<0x1843010 0x4>;
 			interrupts = <0 72 4>;
-			clocks = <&clock HIX5HD2_MAC1_CLK>;
+			clocks = <&clock HIX5HD2_MAC1_CLK>, <&clock HIX5HD2_MAC_IFC1_CLK>;
+			clock-names = "mac_core", "mac_ifc";
+			resets = <&clock 0xcc 9>, <&clock 0xcc 11>, <&clock 0x168 2>;
+			reset-names = "mac_core", "mac_ifc", "phy";
 			status = "disabled";
 		};
 
-- 
2.8.2
