From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v2 0/7] Add MDIO bus multiplexer support for iProc SoCs
Date: Tue, 31 May 2016 19:06:34 +0530
Message-ID: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Broadcom iProc based SoCs use a MDIO bus multiplexer where child buses
could be internal as well external to SoCs. These buses could supports
MDIO transaction compatible to C-22/C-45.

Broadcom MDIO bus mulitplexer is an integrated multiplexer where child bus
selection and mdio transaction logic lies inside multiplexer itself.
To accommodate this multiplexer in existing mux framework below changes
were required-

1. Passed MDIO parent bus via mdio_mux_init to MDIO mux framework.

2. Defined one new boolean property named "mdio-integrated-mux". Integrated
   bus Multiplexer node defines this so when parent bus is registered
   by calling "of_mdiobus_register", this api will not scan for child
   nodes. Child node of integrated multiplexer will be muxed nodes not
   PHYs one hence should not be scanned.

This patch set includes MDIO bus multiplexer driver along with above
framework changes. It includes one external bus node having Ethernet PHY
attached and two internal bus node holding PCIe PHYs.

This patch series is based on v4.6.0-rc1 and is available from github-
repo: https://github.com/Broadcom/arm64-linux.git
branch:mdio-mux-v2

Changes from v1:
- stop using "brcm,is_c45" from bus node as suggested by Andrew. MDIO
PHY driver will logically OR MII_ADDR_C45 into the address when issues
any C45 MDIO read/write transaction.

Pramod Kumar (7):
  mdio:mux: Enhanced MDIO mux framework for integrated multiplexers
  DT: phy.txt: Add mdio-integrated-mux property
  binding: mdio-mux: Add DT binding doc for Broadcom MDIO bus mutiplexer
  DT:mdio-mux: Add mdio multiplexer driver node
  net:mdio-mux: Add MDIO mux driver for iProc SoCs
  Binding:PHY: Binding doc for NS2 PCIe PHYs.
  phy: Add Northstar2 PCI Phy support

 .../bindings/net/brcm,mdio-mux-iproc.txt           |  60 +++++
 Documentation/devicetree/bindings/net/mdio-mux.txt |   9 +-
 .../bindings/phy/brcm,mdio-mux-bus-pci.txt         |  27 +++
 arch/arm64/boot/dts/broadcom/ns2-svk.dts           |  12 +
 arch/arm64/boot/dts/broadcom/ns2.dtsi              |  32 +++
 drivers/net/phy/Kconfig                            |  11 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-mux-bcm-iproc.c               | 243 +++++++++++++++++++++
 drivers/net/phy/mdio-mux-gpio.c                    |   2 +-
 drivers/net/phy/mdio-mux-mmioreg.c                 |   2 +-
 drivers/net/phy/mdio-mux.c                         |  28 ++-
 drivers/of/of_mdio.c                               |   3 +
 drivers/phy/Kconfig                                |   8 +
 drivers/phy/Makefile                               |   1 +
 drivers/phy/phy-bcm-ns2-pcie.c                     | 115 ++++++++++
 include/linux/mdio-mux.h                           |   4 +-
 16 files changed, 544 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt
 create mode 100644 drivers/net/phy/mdio-mux-bcm-iproc.c
 create mode 100644 drivers/phy/phy-bcm-ns2-pcie.c

-- 
1.9.1
