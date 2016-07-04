From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v2 0/4] net: ethernet: Add support for gmii2rgmii converter
Date: Mon, 4 Jul 2016 14:34:40 +0530
Message-ID: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<punnaia@xilinx.com>, <nicolas.ferre@atmel.com>,
	<f.fainelli@gmail.com>, <andrew@lunn.ch>, <anirudh@xilinx.com>,
	<harinik@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series does the following
---> Add support for gmii2rgmii converter.
---> Add support for gmii2rgmii converter in the macb driver.

The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
This core can be used in all three modes of operation(10/100/1000 Mb/s).
The Management Data Input/Output (MDIO) interface is used to configure the
Speed of operation. This core can switch dynamically between the three
Different speed modes by configuring the conveter register through mdio write.

The conveter sits b/w the MAC and external phy like below

MACB <==> GMII2RGMII <==> RGMII_PHY

	MDIO   <========> GMII2RGMII
MCAB <=======> 
	       <========> RGMII

Using MAC MDIO bus we can access both the converter and the external PHY.
We need to program the line speed of the converter during run time based
On the external phy negotiated speed.

Kedareswara rao Appana (4):
  Documentation: DT: net: Add Xilinx gmiitorgmii converter device tree
    binding documentation
  net: ethernet: xilinx: Add gmii2rgmii converter support
  Documentation: DT: net: Update binding doc for gmiitorgmii conveter
  net: macb: Add gmii2rgmii phy converter support

 Documentation/devicetree/bindings/net/macb.txt     |  4 ++
 .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 31 +++++++++
 drivers/net/ethernet/cadence/macb.c                | 21 ++++++
 drivers/net/ethernet/cadence/macb.h                |  1 +
 drivers/net/ethernet/xilinx/Kconfig                |  8 +++
 drivers/net/ethernet/xilinx/Makefile               |  1 +
 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c    | 79 ++++++++++++++++++++++
 include/linux/xilinx_gmii2rgmii.h                  | 24 +++++++
 8 files changed, 169 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
 create mode 100644 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c
 create mode 100644 include/linux/xilinx_gmii2rgmii.h

-- 
2.1.2
