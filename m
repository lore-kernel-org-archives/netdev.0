From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v10 7/8] arm64: dts: allwinner: H5: Restore EMAC changes
Date: Tue, 31 Oct 2017 09:19:14 +0100
Message-ID: <20171031081915.18960-8-clabbe.montjoie@gmail.com>
References: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original dwmac-sun8i DT bindings have some issue on how to handle
integrated PHY and was reverted in last RC of 4.13.
But now we have a solution so we need to get back that was reverted.

This patch restore arm64 DT about dwmac-sun8i for H5
This reverts a part of commit 87e1f5e8bb4b ("arm64: dts: allwinner: Revert EMAC changes")

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts | 17 +++++++++++++++++
 .../arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts | 17 +++++++++++++++++
 .../boot/dts/allwinner/sun50i-h5-orangepi-prime.dts     | 17 +++++++++++++++++
 3 files changed, 51 insertions(+)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
index 1c2387bd5df6..6eb8092d8e57 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
@@ -50,6 +50,7 @@
 	compatible = "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
 
 	aliases {
+		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -108,6 +109,22 @@
 	status = "okay";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_rgmii_pins>;
+	phy-supply = <&reg_gmac_3v3>;
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+	status = "okay";
+};
+
+&external_mdio {
+	ext_rgmii_phy: ethernet-phy@7 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <7>;
+	};
+};
+
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
index 4f77c8470f6c..a0ca925175aa 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
@@ -59,6 +59,7 @@
 	};
 
 	aliases {
+		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -136,6 +137,22 @@
 	status = "okay";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_rgmii_pins>;
+	phy-supply = <&reg_gmac_3v3>;
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+	status = "okay";
+};
+
+&external_mdio {
+	ext_rgmii_phy: ethernet-phy@1 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <1>;
+	};
+};
+
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
index 6be06873e5af..b47790650144 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
@@ -54,6 +54,7 @@
 	compatible = "xunlong,orangepi-prime", "allwinner,sun50i-h5";
 
 	aliases {
+		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -143,6 +144,22 @@
 	status = "okay";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_rgmii_pins>;
+	phy-supply = <&reg_gmac_3v3>;
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+	status = "okay";
+};
+
+&external_mdio {
+	ext_rgmii_phy: ethernet-phy@1 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <1>;
+	};
+};
+
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
-- 
2.13.6
