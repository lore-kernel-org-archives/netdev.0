From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 00/13] ARM64: meson-gxl: Add extended support
Date: Fri, 21 Oct 2016 16:40:25 +0200
Message-ID: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This RFC patchset provides extended peripheral support for the Amlogix GXL SoCs.

The final patchs will be split among the correct subsystems.

In order to support more functionalities, this patchset :
 - Moves peripheral nodes to the common Meson arm64 dtsi
 - Add i2c, mmc, sd, sdio, pinctrl and clock nodes for GXL
 - Adds correct GXL P23X boards uart pinctrl
 - Adds the GXL Internal PHY driver
 - Add a temporary workaround to select the internal PHY
 - Add Ethernet nodes for GXL and the P23X boards
 - Add SD/MMC and SDIO WiFi support support for P23X boards

Neil Armstrong (13):
  pinctrl: meson: Add GXL pinctrl definitions
  ARM64: dts: meson-gxbb: Move common nodes to meson-gx
  ARM64: dts: meson-gxl: Add pinctrl nodes
  ARM64: dts: meson-gxl: Add clock nodes
  ARM64: dts: meson-gxl: Add i2c nodes
  ARM64: dts: meson-gxl: Add MMC/SD/SDIO nodes
  ARM64: dts: meson-gxl-p23x: Add uart pinctrl
  dwmac-meson8b: add support for phy selection
  net: phy: Add Meson GXL Internal PHY driver
  ARM64: dts: meson-gxl: Add ethernet nodes with internal PHY
  ARM64: dts: meson-gxl-p23x: Enable ethernet
  ARM64: dts: meson-gxl-p23x: Add SD/SDIO/MMC and PWM nodes
  ARM64: dts: meson-gxl-p23x: Enable IR receiver

 .../devicetree/bindings/pinctrl/meson,pinctrl.txt  |   2 +
 arch/arm64/boot/dts/amlogic/meson-gx.dtsi          | 131 +++++
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi        | 155 +-----
 .../boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi     | 125 +++++
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi         | 238 +++++++++
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    |  25 +
 drivers/net/phy/Kconfig                            |   5 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/meson-gxl.c                        | 175 ++++++
 drivers/pinctrl/meson/Makefile                     |   3 +-
 drivers/pinctrl/meson/pinctrl-meson-gxl.c          | 589 +++++++++++++++++++++
 drivers/pinctrl/meson/pinctrl-meson.c              |   8 +
 drivers/pinctrl/meson/pinctrl-meson.h              |   2 +
 include/dt-bindings/gpio/meson-gxl-gpio.h          | 131 +++++
 14 files changed, 1452 insertions(+), 138 deletions(-)
 create mode 100644 drivers/net/phy/meson-gxl.c
 create mode 100644 drivers/pinctrl/meson/pinctrl-meson-gxl.c
 create mode 100644 include/dt-bindings/gpio/meson-gxl-gpio.h

-- 
1.9.1

