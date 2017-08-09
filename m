From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v4 11/12] ARM64: dts: rockchip: Add gmac2phy node support for rk3328
Date: Wed,  9 Aug 2017 20:13:44 +0800
Message-ID: <1502280824-2566-1-git-send-email-david.wu@rock-chips.com>
References: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The gmac2phy controller of rk3328 is connected to internal phy
directly inside, add the node for the internal phy support.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm64/boot/dts/rockchip/rk3328.dtsi | 37 ++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/arch/arm64/boot/dts/rockchip/rk3328.dtsi b/arch/arm64/boot/dts/rockchip/rk3328.dtsi
index 0be96ce..903aaae 100644
--- a/arch/arm64/boot/dts/rockchip/rk3328.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3328.dtsi
@@ -63,6 +63,8 @@
 		i2c1 = &i2c1;
 		i2c2 = &i2c2;
 		i2c3 = &i2c3;
+		ethernet0 = &gmac2io;
+		ethernet1 = &gmac2phy;
 	};
 
 	cpus {
@@ -424,6 +426,41 @@
 		status = "disabled";
 	};
 
+	gmac2phy: ethernet@ff550000 {
+		compatible = "rockchip,rk3328-gmac";
+		reg = <0x0 0xff550000 0x0 0x10000>;
+		rockchip,grf = <&grf>;
+		interrupts = <GIC_SPI 21 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "macirq";
+		clocks = <&cru SCLK_MAC2PHY_SRC>, <&cru SCLK_MAC2PHY_RXTX>,
+			 <&cru SCLK_MAC2PHY_RXTX>, <&cru SCLK_MAC2PHY_REF>,
+			 <&cru ACLK_MAC2PHY>, <&cru PCLK_MAC2PHY>,
+			 <&cru SCLK_MAC2PHY_OUT>;
+		clock-names = "stmmaceth", "mac_clk_rx",
+			      "mac_clk_tx", "clk_mac_ref",
+			      "aclk_mac", "pclk_mac",
+			      "clk_macphy";
+		resets = <&cru SRST_GMAC2PHY_A>, <&cru SRST_MACPHY>;
+		reset-names = "stmmaceth", "mac-phy";
+		phy-mode = "rmii";
+		pinctrl-names = "default";
+		pinctrl-0 = <&fephyled_rxm1 &fephyled_linkm1>;
+		phy-handle = <&phy>;
+		status = "disabled";
+
+		mdio {
+			compatible = "snps,dwmac-mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy: phy@0 {
+				compatible = "ethernet-phy-id1234.d400", "ethernet-phy-802.3-c22";
+				reg = <0>;
+				phy-is-internal;
+			};
+		};
+	};
+
 	gic: interrupt-controller@ff811000 {
 		compatible = "arm,gic-400";
 		#interrupt-cells = <3>;
-- 
1.9.1
