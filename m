From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 00/20] net-next: stmmac: add dwmac-sun8i ethernet driver
Date: Tue, 14 Mar 2017 15:18:36 +0100
Message-ID: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: robh+dt@kernel.org, mark.rutland@arm.com, maxime.ripard@free-electrons.com,
 wens@csie.org, linux@armlinux.org.uk, catalin.marinas@arm.com,
 will.deacon@arm.com, peppe.cavallaro@st.com, alexandre.torgue@st.com,
 davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

Changes since v1:
- added TX/RX delay units
- splitted syscon documentation in its own patch
- regulator is now disabled after clk_prepare_enable(gmac->tx_clk) error
- Fixed a memory leak on mac_device_info
- Use now generic pin config for all DT stuff
- CONFIG_DWMAC_SUN8I is now set to y in defconfigs

Corentin Labbe (17):
  net-next: stmmac: export stmmac_set_mac_addr/stmmac_get_mac_addr
  net-next: stmmac: add optional setup function
  ARM: sun8i: dt: Add DT bindings documentation for Allwinner
    dwmac-sun8i
  ARM: sun8i: dt: Add DT bindings documentation for Allwinner syscon
  net-next: stmmac: Add dwmac-sun8i
  ARM: dts: sunxi-h3-h5: Add dt node for the syscon control module
  ARM: dts: sunxi-h3-h5: add dwmac-sun8i ethernet driver
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

LABBE Corentin (3):
  ARM: dts: sun8i: Enable dwmac-sun8i on the Banana Pi M2+
  ARM: dts: sun8i: Enable dwmac-sun8i on the Orange PI PC
  ARM: sunxi: Enable dwmac-sun8i driver on sunxi_defconfig

 .../devicetree/bindings/misc/allwinner,syscon.txt  |  19 +
 .../devicetree/bindings/net/dwmac-sun8i.txt        |  77 ++
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts    |  37 +
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |   5 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts       |  35 +
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  39 +
 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm/configs/sunxi_defconfig                   |   1 +
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts |  14 +
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  16 +-
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts |  15 +
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      |  43 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  | 938 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  31 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   9 +-
 include/linux/stmmac.h                             |   4 +
 22 files changed, 1317 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/misc/allwinner,syscon.txt
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c

-- 
2.10.2
