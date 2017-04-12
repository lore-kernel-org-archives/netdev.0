From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 00/18] net-next: stmmac: add dwmac-sun8i
 ethernet driver
Date: Wed, 12 Apr 2017 13:13:42 +0200
Message-ID: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBB6EYXDDQKGQEGQFFUUY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hello

This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
present on Allwinner H3/H5/A83T/A64 SoCs.

This driver is the continuation of the sun8i-emac driver.
During the development, it appeared that in fact the hardware was a modified
version of some dwmac.
So the driver is now written as a glue driver for stmmac.

It supports 10/100/1000 Mbit/s speed with half/full duplex.
It can use an internal PHY (MII 10/100) or an external PHY
via RGMII/RMII.

This patch series enable the driver only for the H3/A64/H5 SoC since A83T
doesn't have the necessary clocks present in mainline.

The driver have been tested on the following boards:
- H3 Orange PI PC, BananaPI-M2+
- A64 Pine64, BananaPi-M64
- A83T BananaPI-M3

The first two patchs are some mandatory changes for letting dwmac-sun8i be used.
The following three patchs add the driver and its documentation.
The remaining are DT patch enabling it.

Regards
Corentin Labbe

Changes since v3:
- Renamed tx-delay/rx-delay to tx-delay-ps/rx-delay-ps
- fix syscon compatible example
- Changed parameter type for setup() function
- Dropped some DT patchs for boards which I could not test further

Changes since v2:
- corrected order of syscon compatible
- added compatible = "ethernet-phy-ieee802.3-c22 to PHY
- added set_mac function

Changes since v1:
- added TX/RX delay units
- splitted syscon documentation in its own patch
- regulator is now disabled after clk_prepare_enable(gmac->tx_clk) error
- Fixed a memory leak on mac_device_info
- Use now generic pin config for all DT stuff
- CONFIG_DWMAC_SUN8I is now set to y in defconfigs

Corentin Labbe (18):
  net: stmmac: export stmmac_set_mac_addr/stmmac_get_mac_addr
  net: stmmac: add optional setup function
  dt-bindings: net: Add DT bindings documentation for Allwinner
    dwmac-sun8i
  dt-bindings: syscon: Add DT bindings documentation for Allwinner
    syscon
  net: stmmac: Add dwmac-sun8i
  arm: sun8i: sunxi-h3-h5: Add dt node for the syscon control module
  arm: sun8i: sunxi-h3-h5: add dwmac-sun8i ethernet driver
  arm: sun8i: orangepi-pc: Enable dwmac-sun8i
  arm: sun8i: orangepi-2: Enable dwmac-sun8i
  arm: sun8i: orangepi-one: Enable dwmac-sun8i
  arm: sun8i: orangepi-pc-plus: Set EMAC activity LEDs to active high
  arm64: allwinner: sun50i-a64: Add dt node for the syscon control
    module
  arm64: allwinner: sun50i-a64: add dwmac-sun8i Ethernet driver
  arm: allwinner: pine64: Enable dwmac-sun8i
  arm: allwinner: pine64-plus: Enable dwmac-sun8i
  arm64: allwinner: bananapi-m64: Enable dwmac-sun8i
  arm: sunxi: Enable dwmac-sun8i driver on sunxi_defconfig
  arm: multi_v7: Enable dwmac-sun8i driver on multi_v7_defconfig

 .../devicetree/bindings/misc/allwinner,syscon.txt  |  19 +
 .../devicetree/bindings/net/dwmac-sun8i.txt        |  77 ++
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |   5 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   8 +
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  40 +
 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm/configs/sunxi_defconfig                   |   1 +
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts |  15 +
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  17 +-
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts |  16 +
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      |  43 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  | 960 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  29 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   9 +-
 include/linux/stmmac.h                             |   2 +
 20 files changed, 1268 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/misc/allwinner,syscon.txt
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c

-- 
2.10.2
