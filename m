From: Peter Griffin <peter.griffin@linaro.org>
Subject: [PATCH 4/7] ARM: STi: DT: STiH410: Add usb2 picophy dt nodes
Date: Wed, 19 Nov 2014 08:27:09 +0000
Message-ID: <1416385632-5832-5-git-send-email-peter.griffin@linaro.org>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin@linaro.org, lee.jones@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	alexandre.torgue@st.com
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the dt nodes for the extra usb2 picophys found on the stih410.
These two picophys are used in conjunction with the extra ehci/ohci usb
controllers also found on the stih410.

Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
---
 arch/arm/boot/dts/stih410.dtsi | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/arm/boot/dts/stih410.dtsi b/arch/arm/boot/dts/stih410.dtsi
index c05627e..7fd9d57 100644
--- a/arch/arm/boot/dts/stih410.dtsi
+++ b/arch/arm/boot/dts/stih410.dtsi
@@ -10,5 +10,23 @@
 #include "stih407-family.dtsi"
 #include "stih410-pinctrl.dtsi"
 / {
+	soc {
+		usb2_picophy1: phy@1 {
+			compatible = "st,stih407-usb2-phy";
+			#phy-cells = <0>;
+			st,syscfg = <&syscfg_core 0xf8 0xf4>;
+			resets = <&softreset STIH407_PICOPHY_SOFTRESET>,
+				 <&picophyreset STIH407_PICOPHY0_RESET>;
+			reset-names = "global", "port";
+		};
 
+		usb2_picophy2: phy@2 {
+			compatible = "st,stih407-usb2-phy";
+			#phy-cells = <0>;
+			st,syscfg = <&syscfg_core 0xfc 0xf4>;
+			resets = <&softreset STIH407_PICOPHY_SOFTRESET>,
+				 <&picophyreset STIH407_PICOPHY1_RESET>;
+			reset-names = "global", "port";
+		};
+	};
 };
-- 
1.9.1
