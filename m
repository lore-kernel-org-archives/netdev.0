From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 0/2] Initial driver for Synopsys DWC XLGMAC
Date: Wed, 7 Dec 2016 11:57:37 +0800
Message-ID: <cover.1481075763.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>,
        <lars.persson@axis.com>, <thomas.lendacky@amd.com>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series provides the support for 25/40/50/100 GbE
devices using Synopsys DWC Enterprise Ethernet (XLGMAC).

The first patch adds support for Synopsys XLGMII.
The second patch provides the initial driver for Synopsys XLGMAC

The driver has three layers by refactoring AMD XGBE.

dwc-eth-xxx.x
  The DWC ethernet core layer (DWC ECL). This layer contains codes
can be shared by different DWC series ethernet cores

dwc-xxx.x (e.g. dwc-xlgmac.c)
  The DWC MAC HW adapter layer (DWC MHAL). This layer contains
special support for a specific MAC. e.g. currently, XLGMAC.

xxx-xxx-pci.c xxx-xxx-plat.c (e.g. dwc-xlgmac-pci.c)
  The glue adapter layer (GAL). Vendors who adopt Synopsys Etherent
cores can develop a glue driver for their platform.

Jie Deng (2):
  net: phy: add extension of phy-mode for XLGMII
  net: ethernet: Initial driver for Synopsys DWC XLGMAC

 Documentation/devicetree/bindings/net/ethernet.txt |    1 +
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/synopsys/Kconfig              |    2 +
 drivers/net/ethernet/synopsys/Makefile             |    1 +
 drivers/net/ethernet/synopsys/dwc/Kconfig          |   37 +
 drivers/net/ethernet/synopsys/dwc/Makefile         |    9 +
 drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c    |  228 ++
 .../net/ethernet/synopsys/dwc/dwc-eth-debugfs.c    |  328 +++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c   |  715 +++++
 .../net/ethernet/synopsys/dwc/dwc-eth-ethtool.c    |  567 ++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c     | 3098 ++++++++++++++++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c   |  252 ++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c    | 2319 +++++++++++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c    |  216 ++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h | 1115 +++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth.h        |  738 +++++
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c |  538 ++++
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c     |  135 +
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h     |   85 +
 include/linux/phy.h                                |    3 +
 20 files changed, 10393 insertions(+)
 create mode 100644 drivers/net/ethernet/synopsys/dwc/Kconfig
 create mode 100644 drivers/net/ethernet/synopsys/dwc/Makefile
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-debugfs.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-ethtool.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth.h
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h

-- 
1.9.1
