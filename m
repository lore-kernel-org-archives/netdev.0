From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv3 RESEND 0/6] ARM: sunxi: Add support for A10 Ethernet controller
Date: Fri, 24 May 2013 11:23:08 +0200
Message-ID: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The Allwinner A10 SoC has an ethernet controller that seem to be specific to
Allwinner. This IP has no public documentation, so exact
details are quite sparse, and this code come from refactored Allwinner
code.

The rework to use NAPI is taking more time than expected, I'm still working
on it, but it could probably be sent as a follow-up patch.

Thanks,
Maxime

Changes from v2:
  - Split the MDIO controller to a separate driver and make use of standards
    device tree bindings
  - Fixed various minor things as suggested by Florian Fainelli
  - Added clock support now that we have a clock driver

Changes from v1:
  - Use phylib for the phy-related functions
  - Use an optional regulator to power up the phy
  - Rename the driver from Davicom Wemac to Allwinner EMAC, since it's the name
    mentionned in the datasheet, and we have no strong evidence of a
    relationship with Davicom
  - Fix various small things around the driver: add defines for undocumented
    values, fix documentation name and compatible example, etc.

Maxime Ripard (4):
  net: Add MDIO bus driver for the Allwinner EMAC
  ARM: sun4i: Add muxing options for the ethernet controller
  ARM: sunxi: Add EMAC controller node to sun4i DTSI
  ARM: sunxi: Add EMAC Controller to Hackberry dt

Stefan Roese (2):
  net: Add EMAC ethernet driver found on Allwinner A10 SoC's
  ARM: cubieboard: Enable ethernet (EMAC) support in dts

 .../bindings/net/allwinner,sun4i-emac.txt          |  22 +
 .../bindings/net/allwinner,sun4i-mdio.txt          |  26 +
 arch/arm/boot/dts/sun4i-a10-cubieboard.dts         |  15 +
 arch/arm/boot/dts/sun4i-a10-hackberry.dts          |  41 +
 arch/arm/boot/dts/sun4i-a10.dtsi                   |  27 +
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/allwinner/Kconfig             |  44 +
 drivers/net/ethernet/allwinner/Makefile            |   6 +
 drivers/net/ethernet/allwinner/sun4i-emac.c        | 960 +++++++++++++++++++++
 drivers/net/ethernet/allwinner/sun4i-emac.h        | 108 +++
 drivers/net/ethernet/allwinner/sun4i-mdio.c        | 191 ++++
 12 files changed, 1442 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
 create mode 100644 drivers/net/ethernet/allwinner/Kconfig
 create mode 100644 drivers/net/ethernet/allwinner/Makefile
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.c
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.h
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-mdio.c

-- 
1.8.1.2
