From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: [PATCH net-next v2 1/2] dt-bindings: net: add DT bindings for Socionext UniPhier AVE
Date: Fri, 13 Oct 2017 09:35:27 +0900
Message-ID: <1507854928-4357-2-git-send-email-hayashi.kunihiko@socionext.com>
References: <1507854928-4357-1-git-send-email-hayashi.kunihiko@socionext.com>
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>,
        Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
To: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507854928-4357-1-git-send-email-hayashi.kunihiko@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DT bindings for the AVE ethernet controller found on Socionext's
UniPhier platforms.

Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
---
 .../bindings/net/socionext,uniphier-ave4.txt       | 53 ++++++++++++++++++++++
 1 file changed, 53 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt

diff --git a/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
new file mode 100644
index 0000000..25f4d92
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
@@ -0,0 +1,53 @@
+* Socionext AVE ethernet controller
+
+This describes the devicetree bindings for AVE ethernet controller
+implemented on Socionext UniPhier SoCs.
+
+Required properties:
+ - compatible: Should be
+	- "socionext,uniphier-pro4-ave4" : for Pro4 SoC
+	- "socionext,uniphier-pxs2-ave4" : for PXs2 SoC
+	- "socionext,uniphier-ld20-ave4" : for LD20 SoC
+	- "socionext,uniphier-ld11-ave4" : for LD11 SoC
+ - reg: Address where registers are mapped and size of region.
+ - interrupts: Should contain the MAC interrupt.
+ - phy-mode: See ethernet.txt in the same directory. Allow to choose
+	"rgmii", "rmii", or "mii" according to the PHY.
+ - pinctrl-names: List of assigned state names, see pinctrl
+	binding documentation.
+ - pinctrl-0: List of phandles to configure the GPIO pin,
+	see pinctrl binding documentation. Choose this appropriately
+	according to phy-mode.
+	- <&pinctrl_ether_rgmii> if phy-mode is "rgmii".
+	- <&pinctrl_ether_rmii> if phy-mode is "rmii".
+	- <&pinctrl_ether_mii> if phy-mode is "mii".
+ - phy-handle: Should point to the external phy device.
+	See ethernet.txt file in the same directory.
+ - mdio subnode: Should be device tree subnode with the following required
+	properties:
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+	- reg: phy ID number, usually a small integer.
+
+Optional properties:
+ - local-mac-address: See ethernet.txt in the same directory.
+
+Example:
+
+	ether: ethernet@65000000 {
+		compatible = "socionext,uniphier-ld20-ave4";
+		reg = <0x65000000 0x8500>;
+		interrupts = <0 66 4>;
+		pinctrl-names = "default";
+		pinctrl-0 = <&pinctrl_ether_rgmii>;
+		phy-mode = "rgmii";
+		phy-handle = <&ethphy>;
+		local-mac-address = [00 00 00 00 00 00];
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			ethphy: ethphy@1 {
+				reg = <1>;
+			};
+		};
+	};
-- 
2.7.4
