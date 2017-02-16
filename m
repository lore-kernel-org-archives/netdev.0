From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/21] net-next: stmmac: add dwmac-sun8i
 ethernet driver
Date: Thu, 16 Feb 2017 13:48:38 +0100
Message-ID: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBQ6AS3CQKGQEH77OFVI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
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
present on Allwinner H3/A83T/A64 SoCs.

This driver is the continuation of the sun8i-emac driver.
During the development, it appeared that in fact the hardware was a modified
version of some dwmac.
So the driver is now written as a glue driver for stmmac.

It supports 10/100/1000 Mbit/s speed with half/full duplex.
It can use an internal PHY (MII 10/100) or an external PHY
via RGMII/RMII.

This patch series enable the driver only for the H3/A64 SoC since A83T
doesn't have the necessary clocks present in mainline.

The driver have been tested on the following boards:
- H3 Orange PI PC, BananaPI-M2+
- A64 Pine64, BananaPi-M64
- A83T BananaPI-M3

The first three patchs are some mandatory changes for letting dwmac-sun8i be used.
The following two patchs add the driver and its documentation.
The remaining are DT patch enabling it.

Regards
Corentin Labbe

Corentin Labbe (16):
  net-next: stmmac add optional init_phy function
  net-next: stmmac: export stmmac_set_mac_addr/stmmac_get_mac_addr
  net-next: stmmac: add optional setup function
  ARM: sun8i: dt: Add DT bindings documentation for Allwinner
    dwmac-sun8i
  net-next: stmmac: Add dwmac-sun8i
  ARM: dts: sun8i-h3: add dwmac-sun8i rgmii pins
  ARM: dts: sun8i: Enable dwmac-sun8i on the Orange Pi 2
  ARM: dts: sun8i: Enable dwmac-sun8i on the Orange PI One
  ARM: dts: sun8i: Enable dwmac-sun8i on the Orange Pi plus
  ARM: dts: sun8i: orangepi-pc-plus: Set EMAC activity LEDs to active
    high
  ARM64: dts: sun50i-a64: Add dt node for the syscon control module
  ARM64: dts: sun50i-a64: add dwmac-sun8i Ethernet driver
  ARM: dts: sun50i-a64: enable dwmac-sun8i on pine64
  ARM: dts: sun50i-a64: enable dwmac-sun8i on pine64 plus
  ARM: dts: sun50i-a64: enable dwmac-sun8i on the BananaPi M64
  ARM: sunxi: Enable dwmac-sun8i driver on multi_v7_defconfig

LABBE Corentin (5):
  ARM: dts: sun8i-h3: Add dt node for the syscon control module
  ARM: dts: sun8i-h3: add dwmac-sun8i ethernet driver
  ARM: dts: sun8i: Enable dwmac-sun8i on the Banana Pi M2+
  ARM: dts: sun8i: Enable dwmac-sun8i on the Orange PI PC
  ARM: sunxi: Enable dwmac-sun8i driver on sunxi_defconfig

 .../devicetree/bindings/net/dwmac-sun8i.txt        |  86 ++
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts    |  38 +
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |   5 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts       |  36 +
 arch/arm/boot/dts/sun8i-h3.dtsi                    |  42 +
 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm/configs/sunxi_defconfig                   |   1 +
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts |  14 +
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  16 +-
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts |  15 +
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      |  43 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  | 892 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  45 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   9 +-
 include/linux/stmmac.h                             |   4 +
 23 files changed, 1286 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c

-- 
2.10.2
