From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V3 1/4] net-next: mediatek: document MediaTek SoC ethernet
 binding
Date: Thu,  3 Mar 2016 21:02:38 +0100
Message-ID: <1457035361-57669-2-git-send-email-blogic@openwrt.org>
References: <1457035361-57669-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>,
 =?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
 <steven.liu@mediatek.com>, netdev@vger.kernel.org,
 =?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
 <Carlos.Huang@mediatek.com>, linux-kernel@vger.kernel.org,
 linux-mediatek@lists.infradead.org, Michael Lee <igvtee@gmail.com>,
 linux-arm-kernel@lists.infradead.org, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457035361-57669-1-git-send-email-blogic@openwrt.org>
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

This adds the binding documentation for the MediaTek Ethernet
controller.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: devicetree@vger.kernel.org
---
 .../devicetree/bindings/net/mediatek-net.txt       |   77 ++++++++++++++++++++
 1 file changed, 77 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net.txt

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
new file mode 100644
index 0000000..5ca7929
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -0,0 +1,77 @@
+MediaTek Frame Engine Ethernet controller
+=========================================
+
+The frame engine ethernet controller can be found on MediaTek SoCs. These SoCs
+have dual GMAC each represented by a child node..
+
+* Ethernet controller node
+
+Required properties:
+- compatible: Should be "mediatek,mt7623-eth"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the frame engines interrupt
+- clocks: the clock used by the core
+- clock-names: the names of the clock listed in the clocks property. These are
+	"ethif", "esw", "gp2", "gp1"
+- power-domains: phandle to the power domain that the ethernet is part of
+- resets: Should contain a phandle to the ethsys reset signal
+- reset-names: Should contain the reset signal name "eth"
+- mediatek,ethsys: phandle to the syscon node that handles the port setup
+- mediatek,pctl: phandle to the syscon node that handles the ports slew rate
+	and driver current
+
+Optional properties:
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+
+
+* Ethernet MAC node
+
+Required properties:
+- compatible: Should be "mediatek,eth-mac"
+- reg: The number of the MAC
+- phy-handle: see ethernet.txt file in the same directory.
+
+Example:
+
+eth: ethernet@1b100000 {
+	compatible = "mediatek,mt7623-eth";
+	reg = <0 0x1b100000 0 0x20000>;
+	clocks = <&topckgen CLK_TOP_ETHIF_SEL>,
+		 <&ethsys CLK_ETHSYS_ESW>,
+		 <&ethsys CLK_ETHSYS_GP2>,
+		 <&ethsys CLK_ETHSYS_GP1>;
+	clock-names = "ethif", "esw", "gp2", "gp1";
+	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
+	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
+	resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
+	reset-names = "eth";
+	mediatek,ethsys = <&ethsys>;
+	mediatek,pctl = <&syscfg_pctl_a>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	gmac1: mac@0 {
+		compatible = "mediatek,eth-mac";
+		reg = <0>;
+		phy-handle = <&phy0>;
+	};
+
+	gmac2: mac@1 {
+		compatible = "mediatek,eth-mac";
+		reg = <1>;
+		phy-handle = <&phy1>;
+	};
+
+	mdio-bus {
+		phy0: ethernet-phy@0 {
+			reg = <0>;
+			phy-mode = "rgmii";
+		};
+
+		phy1: ethernet-phy@1 {
+			reg = <1>;
+			phy-mode = "rgmii";
+		};
+	};
+};
-- 
1.7.10.4
