From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v1 0/3] Add Hisilicon MDIO bus driver and FEMAC driver
Date: Fri, 15 Jul 2016 16:26:32 +0800
Message-ID: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dongpo Li <lidongpo@hisilicon.com>
To: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <frowand.list@gmail.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds a Hisilicon MDIO bus driver and
a Fast Ethernet MAC(FEMAC) driver.
We also abstract a general interface "of_phy_get_and_connect"
for PHY connect. User will have no bother with getting
"phy-mode" and "phy-handle" any more.

Changes in v1:
- Pass private data structure instead of struct mii_bus
  in MDIO read and write operation.
- Return the error which devm_clk_get() gives when MDIO probe.
- Leave the clock unprepared and disabled on error when MDIO probe.
- Abstract a general interface "of_phy_get_and_connect" for PHY connect.
- Remove the "_reset" suffixes in "reset-names" property.
- Enable tx per-packet interrupt when tx fifo full.
- Remove pointless compatible and add SoC specific compatible.
- Declare only one clock in MAC dts documentation.
- Add standard unit suffixes for "phy-reset-delays".
- Use a smaller NAPI poll weight 16 for our Fast Ethernet MAC.
- Use phy_ethtool_{get|set}_link_ksettings for ethtool ops.
- Use phydev from struct net_device in MAC driver.

Dongpo Li (3):
  net: Add MDIO bus driver for the Hisilicon FEMAC
  of_mdio: Abstract a general interface for phy connect
  net: hisilicon: Add Fast Ethernet MAC driver

 .../bindings/net/hisilicon-femac-mdio.txt          |   22 +
 .../devicetree/bindings/net/hisilicon-femac.txt    |   39 +
 drivers/net/ethernet/hisilicon/Kconfig             |   12 +
 drivers/net/ethernet/hisilicon/Makefile            |    1 +
 drivers/net/ethernet/hisilicon/hisi_femac.c        | 1007 ++++++++++++++++++++
 drivers/net/phy/Kconfig                            |    7 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/mdio-hisi-femac.c                  |  166 ++++
 drivers/of/of_mdio.c                               |   36 +
 include/linux/of_mdio.h                            |   10 +
 10 files changed, 1301 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac.txt
 create mode 100644 drivers/net/ethernet/hisilicon/hisi_femac.c
 create mode 100644 drivers/net/phy/mdio-hisi-femac.c

-- 
2.8.2
