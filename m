From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v2 4/5] ARM64: dts: meson-gxl-p23x: Enable ethernet
Date: Mon, 31 Oct 2016 17:56:26 +0100
Message-ID: <1477932987-27871-5-git-send-email-narmstrong@baylibre.com>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
To: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable Ethernet on the p23x board, pinctrl attribute is only added for
the p230 board since the p231 only uses the Internal PHY.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts  | 16 ++++++++++++++++
 arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p231.dts  |  6 ++++++
 arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi |  4 ++++
 3 files changed, 26 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
index 3dfaa37..a569286 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
@@ -49,3 +49,19 @@
 	compatible = "amlogic,p230", "amlogic,s905d", "amlogic,meson-gxl";
 	model = "Amlogic Meson GXL (S905D) P230 Development Board";
 };
+
+/* P230 has exclusive choice between internal or external PHY */
+&ethmac {
+	pinctrl-0 = <&eth_pins>;
+	pinctrl-names = "default";
+
+	phy-handle = <&external_phy>;
+};
+
+&external_mdio {
+	external_phy: ethernet-phy@0 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <0>;
+		max-speed = <1000>;
+	};
+};
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p231.dts b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p231.dts
index ade8d29..1cc8d49 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p231.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p231.dts
@@ -49,3 +49,9 @@
 	compatible = "amlogic,p231", "amlogic,s905d", "amlogic,meson-gxl";
 	model = "Amlogic Meson GXL (S905D) P231 Development Board";
 };
+
+/* P231 has only internal PHY port */
+&ethmac {
+	phy-mode = "rmii";
+	phy-handle = <&internal_phy>;
+};
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi
index bbe46a2..622ffbe 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi
@@ -182,3 +182,7 @@
 	clocks = <&clkc CLKID_FCLK_DIV4>;
 	clock-names = "clkin0";
 };
+
+&ethmac {
+	status = "okay";
+};
-- 
1.9.1
