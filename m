From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 10/13] ARM64: dts: meson-gxl: Add ethernet nodes with internal PHY
Date: Fri, 21 Oct 2016 16:40:35 +0200
Message-ID: <1477060838-14164-11-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34331 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934650AbcJUOlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:41:05 -0400
Received: by mail-qk0-f182.google.com with SMTP id f128so150551125qkb.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:41:00 -0700 (PDT)
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Ethernet node with Internal PHY selection for the Amlogic GXL SoCs

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
index d1bf381..85969c6 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
@@ -49,6 +49,34 @@
 	compatible = "amlogic,meson-gxl";
 };
 
+&ethmac {
+	reg = <0x0 0xc9410000 0x0 0x10000
+	       0x0 0xc8834540 0x0 0x4
+	       0x0 0xc8834558 0x0 0xc>;
+
+	clocks = <&clkc CLKID_ETH>,
+		 <&clkc CLKID_FCLK_DIV2>,
+		 <&clkc CLKID_MPLL2>;
+	clock-names = "stmmaceth", "clkin0", "clkin1";
+
+	/* Select Internal PHY by default */
+	amlogic,phy-select = <0xe40908ff>;
+	phy-mode = "rmii";
+	phy-handle = <&internal_phy>;
+
+	mdio0 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+
+		internal_phy: ethernet-phy@8 {
+			compatible = "ethernet-phy-id0181.4400", "ethernet-phy-ieee802.3-c22";
+			reg = <8>;
+			max-speed = <100>;
+		};
+	};
+};
+
 &aobus {
 	pinctrl_aobus: pinctrl@14 {
 		compatible = "amlogic,meson-gxl-aobus-pinctrl";
-- 
1.9.1
