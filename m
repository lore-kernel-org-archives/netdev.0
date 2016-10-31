From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v2 3/5] ARM64: dts: meson-gxl: Add ethernet nodes with internal PHY
Date: Mon, 31 Oct 2016 17:56:25 +0100
Message-ID: <1477932987-27871-4-git-send-email-narmstrong@baylibre.com>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
To: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37363 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944687AbcJaQ4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 12:56:38 -0400
Received: by mail-wm0-f54.google.com with SMTP id t79so61628456wmt.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 09:56:37 -0700 (PDT)
In-Reply-To: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Ethernet node with Internal PHY selection for the Amlogic GXL SoCs

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 45 ++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
index d1bf381..71670c3 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
@@ -47,6 +47,24 @@
 
 / {
 	compatible = "amlogic,meson-gxl";
+
+
+};
+
+&ethmac {
+	reg = <0x0 0xc9410000 0x0 0x10000
+	       0x0 0xc8834540 0x0 0x4>;
+
+	clocks = <&clkc CLKID_ETH>,
+		 <&clkc CLKID_FCLK_DIV2>,
+		 <&clkc CLKID_MPLL2>;
+	clock-names = "stmmaceth", "clkin0", "clkin1";
+
+	mdio0: mdio0 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+	};
 };
 
 &aobus {
@@ -214,6 +232,33 @@
 			};
 		};
 	};
+
+	eth-phy-mux {
+		compatible = "mdio-mux-mmioreg", "mdio-mux";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0x0 0x55c 0x0 0x4>;
+		mux-mask = <0xffffffff>;
+		mdio-parent-bus = <&mdio0>;
+
+		internal_mdio: mdio@e40908ff {
+			reg = <0xe40908ff>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			internal_phy: ethernet-phy@8 {
+				compatible = "ethernet-phy-id0181.4400", "ethernet-phy-ieee802.3-c22";
+				reg = <8>;
+				max-speed = <100>;
+			};
+		};
+
+		external_mdio: mdio@2009087f {
+			reg = <0x2009087f>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+		};
+	};
 };
 
 &hiubus {
-- 
1.9.1
