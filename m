From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 00/13] net: mvpp2: comphy configuration
Date: Thu, 24 Aug 2017 10:38:10 +0200
Message-ID: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series, following up the one one the GoP/MAC configuration, aims at
stopping to depend on the firmware/bootloader configuration when using
the PPv2 engine. With this series the PPv2 driver does not need to rely
on a previous configuration, and dynamic reconfiguration while the
kernel is running can be done (i.e. switch one port from SGMII to 10GKR,
or the opposite). A port can now be configured in a different mode than
what's done in the firmware/bootloader as well.

The series first contain patches in the generic PHY framework to support
what is called the comphy (common PHYs), which is an h/w block providing
PHYs that can be configured in various modes ranging from SGMII, 10GKR
to SATA and others. As of now only the SGMII and 10GKR modes are
supported by the comphy driver.

Then patches are modifying the PPv2 driver to first add the comphy
initialization sequence (i.e. calls to the generic PHY framework) and to
then take advantage of this to allow dynamic reconfiguration (i.e.
configuring the mode of a port given what's connected, between sgmii and
10G). Note the use of the comphy in the PPv2 driver is kept optional
(i.e. if not described in dt the driver still as before an relies on the
firmware/bootloader configuration).

Finally there are dt/defconfig patches to describe and take advantage of
this.

This was tested on a range of devices: 8040-db, 8040-mcbin and 7040-db.

Thanks!
Antoine

Antoine Tenart (12):
  phy: add sgmii and 10gkr modes to the phy_mode enum
  phy: add the mvebu cp110 comphy driver
  Documentation/bindings: phy: document the Marvell comphy driver
  net: mvpp2: initialize the comphy
  net: mvpp2: do not force the link mode
  net: mvpp2: simplify the link_event function
  net: mvpp2: improve the link management function
  net: mvpp2: check the netif is running in the link_event function
  net: mvpp2: dynamic reconfiguration of the PHY mode
  arm64: dts: marvell: extend the cp110 syscon register area length
  arm64: dts: marvell: add comphy nodes on cp110 master and slave
  arm64: dts: marvell: mcbin: add comphy references to Ethernet ports

Miquel Raynal (1):
  arm64: defconfig: enable Marvell CP110 comphy

 .../devicetree/bindings/phy/phy-mvebu-comphy.txt   |  42 ++
 arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts  |   3 +
 .../boot/dts/marvell/armada-cp110-master.dtsi      |  40 +-
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |  40 +-
 arch/arm64/configs/defconfig                       |   1 +
 drivers/net/ethernet/marvell/mvpp2.c               | 111 ++--
 drivers/phy/marvell/Kconfig                        |  10 +
 drivers/phy/marvell/Makefile                       |   1 +
 drivers/phy/marvell/phy-mvebu-cp110-comphy.c       | 656 +++++++++++++++++++++
 include/linux/phy/phy.h                            |   2 +
 10 files changed, 871 insertions(+), 35 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt
 create mode 100644 drivers/phy/marvell/phy-mvebu-cp110-comphy.c

-- 
2.13.5
