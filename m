From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 12/20] ARM: dts: sun8i: Enable dwmac-sun8i on the Orange Pi plus
Date: Tue, 14 Mar 2017 15:18:48 +0100
Message-ID: <20170314141856.24560-13-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32821 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbdCNOV2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 10:21:28 -0400
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac-sun8i hardware is present on the Orange PI plus.
It uses an external PHY rtl8211e via RGMII.

This patch create the needed regulator, emac and phy nodes.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts | 35 ++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
index 8c40ab7..4e075a2 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
@@ -58,6 +58,18 @@
 		enable-active-high;
 		gpio = <&pio 6 11 GPIO_ACTIVE_HIGH>;
 	};
+
+	reg_gmac_3v3: gmac-3v3 {
+		compatible = "regulator-fixed";
+		pinctrl-names = "default";
+		pinctrl-0 = <&gmac_power_pin_orangepi>;
+		regulator-name = "gmac-3v3";
+		regulator-min-microvolt = <3300000>;
+		regulator-max-microvolt = <3300000>;
+		startup-delay-us = <100000>;
+		enable-active-high;
+		gpio = <&pio 3 6 GPIO_ACTIVE_HIGH>;
+	};
 };
 
 &ehci3 {
@@ -86,8 +98,31 @@
 		pins = "PG11";
 		function = "gpio_out";
 	};
+
+	gmac_power_pin_orangepi: gmac_power_pin@0 {
+		pins = "PD6";
+		function = "gpio_out";
+		drive-strength = <10>;
+	};
 };
 
 &usbphy {
 	usb3_vbus-supply = <&reg_usb3_vbus>;
 };
+
+&mdio {
+	ext_rgmii_phy: ethernet-phy@1 {
+		reg = <0>;
+	};
+};
+
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_rgmii_pins>;
+	phy-supply = <&reg_gmac_3v3>;
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+
+	allwinner,leds-active-low;
+	status = "okay";
+};
-- 
2.10.2
