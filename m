From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the rockchip
 tree
Date: Tue, 15 Aug 2017 11:52:43 +1000
Message-ID: <20170815115243.056a5569@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        William Wu <william.wu@rock-chips.com>,
        David Wu <david.wu@rock-chips.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Heiko Stuebner <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/boot/dts/rockchip/rk3328.dtsi

between commit:

  c60c0373a5e8 ("arm64: dts: rockchip: add usb2 nodes for RK3328 SoCs")

from the rockchip tree and commit:

  9c4cc910fe28 ("ARM64: dts: rockchip: Add gmac2phy node support for rk3328")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/boot/dts/rockchip/rk3328.dtsi
index e6da0cee1241,d48bf5d9f8bd..000000000000
--- a/arch/arm64/boot/dts/rockchip/rk3328.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3328.dtsi
@@@ -616,45 -426,43 +618,82 @@@
  		status = "disabled";
  	};
  
+ 	gmac2phy: ethernet@ff550000 {
+ 		compatible = "rockchip,rk3328-gmac";
+ 		reg = <0x0 0xff550000 0x0 0x10000>;
+ 		rockchip,grf = <&grf>;
+ 		interrupts = <GIC_SPI 21 IRQ_TYPE_LEVEL_HIGH>;
+ 		interrupt-names = "macirq";
+ 		clocks = <&cru SCLK_MAC2PHY_SRC>, <&cru SCLK_MAC2PHY_RXTX>,
+ 			 <&cru SCLK_MAC2PHY_RXTX>, <&cru SCLK_MAC2PHY_REF>,
+ 			 <&cru ACLK_MAC2PHY>, <&cru PCLK_MAC2PHY>,
+ 			 <&cru SCLK_MAC2PHY_OUT>;
+ 		clock-names = "stmmaceth", "mac_clk_rx",
+ 			      "mac_clk_tx", "clk_mac_ref",
+ 			      "aclk_mac", "pclk_mac",
+ 			      "clk_macphy";
+ 		resets = <&cru SRST_GMAC2PHY_A>, <&cru SRST_MACPHY>;
+ 		reset-names = "stmmaceth", "mac-phy";
+ 		phy-mode = "rmii";
+ 		phy-handle = <&phy>;
+ 		status = "disabled";
+ 
+ 		mdio {
+ 			compatible = "snps,dwmac-mdio";
+ 			#address-cells = <1>;
+ 			#size-cells = <0>;
+ 
+ 			phy: phy@0 {
+ 				compatible = "ethernet-phy-id1234.d400", "ethernet-phy-ieee802.3-c22";
+ 				reg = <0>;
+ 				clocks = <&cru SCLK_MAC2PHY_OUT>;
+ 				resets = <&cru SRST_MACPHY>;
+ 				pinctrl-names = "default";
+ 				pinctrl-0 = <&fephyled_rxm1 &fephyled_linkm1>;
+ 				phy-is-integrated;
+ 			};
+ 		};
+ 	};
+ 
 +	usb20_otg: usb@ff580000 {
 +		compatible = "rockchip,rk3328-usb", "rockchip,rk3066-usb",
 +			     "snps,dwc2";
 +		reg = <0x0 0xff580000 0x0 0x40000>;
 +		interrupts = <GIC_SPI 23 IRQ_TYPE_LEVEL_HIGH>;
 +		clocks = <&cru HCLK_OTG>;
 +		clock-names = "otg";
 +		dr_mode = "otg";
 +		g-np-tx-fifo-size = <16>;
 +		g-rx-fifo-size = <280>;
 +		g-tx-fifo-size = <256 128 128 64 32 16>;
 +		g-use-dma;
 +		phys = <&u2phy_otg>;
 +		phy-names = "usb2-phy";
 +		status = "disabled";
 +	};
 +
 +	usb_host0_ehci: usb@ff5c0000 {
 +		compatible = "generic-ehci";
 +		reg = <0x0 0xff5c0000 0x0 0x10000>;
 +		interrupts = <GIC_SPI 16 IRQ_TYPE_LEVEL_HIGH>;
 +		clocks = <&cru HCLK_HOST0>, <&u2phy>;
 +		clock-names = "usbhost", "utmi";
 +		phys = <&u2phy_host>;
 +		phy-names = "usb";
 +		status = "disabled";
 +	};
 +
 +	usb_host0_ohci: usb@ff5d0000 {
 +		compatible = "generic-ohci";
 +		reg = <0x0 0xff5d0000 0x0 0x10000>;
 +		interrupts = <GIC_SPI 17 IRQ_TYPE_LEVEL_HIGH>;
 +		clocks = <&cru HCLK_HOST0>, <&u2phy>;
 +		clock-names = "usbhost", "utmi";
 +		phys = <&u2phy_host>;
 +		phy-names = "usb";
 +		status = "disabled";
 +	};
 +
  	gic: interrupt-controller@ff811000 {
  		compatible = "arm,gic-400";
  		#interrupt-cells = <3>;
