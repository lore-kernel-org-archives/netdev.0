From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: [PATCH net-next v3 1/2] dt-bindings: net: add DT bindings for
 Socionext UniPhier AVE
Date: Wed, 25 Oct 2017 10:07:58 +0900
Message-ID: <1508893679-11727-2-git-send-email-hayashi.kunihiko@socionext.com>
References: <1508893679-11727-1-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Kunihiko Hayashi <hayashi.kunihiko@socionext.com>,
 Masami Hiramatsu <masami.hiramatsu@linaro.org>,
 Jassi Brar <jaswinder.singh@linaro.org>, linux-kernel@vger.kernel.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Rob Herring <robh+dt@kernel.org>, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1508893679-11727-1-git-send-email-hayashi.kunihiko@socionext.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

DT bindings for the AVE ethernet controller found on Socionext's
UniPhier platforms.

Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
---
 .../bindings/net/socionext,uniphier-ave4.txt       | 48 ++++++++++++++++++++++
 1 file changed, 48 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt

diff --git a/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
new file mode 100644
index 0000000..4b7eca8
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
@@ -0,0 +1,48 @@
+* Socionext AVE ethernet controller
+
+This describes the devicetree bindings for AVE ethernet controller
+implemented on Socionext UniPhier SoCs.
+
+Required properties:
+ - compatible: Should be
+	- "socionext,uniphier-pro4-ave4" : for Pro4 SoC
+	- "socionext,uniphier-pxs2-ave4" : for PXs2 SoC
+	- "socionext,uniphier-ld11-ave4" : for LD11 SoC
+	- "socionext,uniphier-ld20-ave4" : for LD20 SoC
+ - reg: Address where registers are mapped and size of region.
+ - interrupts: Should contain the MAC interrupt.
+ - phy-mode: See ethernet.txt in the same directory. Allow to choose
+	"rgmii", "rmii", or "mii" according to the PHY.
+ - phy-handle: Should point to the external phy device.
+	See ethernet.txt file in the same directory.
+ - clocks: A phandle to the clock for the MAC.
+
+Optional properties:
+ - resets: A phandle to the reset control for the MAC.
+ - local-mac-address: See ethernet.txt in the same directory.
+
+Required subnode:
+ - mdio: Device tree subnode with the following required properties:
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+	- reg: phy ID number, usually a small integer.
+
+Example:
+
+	ether: ethernet@65000000 {
+		compatible = "socionext,uniphier-ld20-ave4";
+		reg = <0x65000000 0x8500>;
+		interrupts = <0 66 4>;
+		phy-mode = "rgmii";
+		phy-handle = <&ethphy>;
+		clocks = <&sys_clk 6>;
+		resets = <&sys_rst 6>;
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
