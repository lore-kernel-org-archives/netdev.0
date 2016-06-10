From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v5 0/7] Add MDIO bus multiplexer support for iProc SoCs
Date: Fri, 10 Jun 2016 11:03:44 +0530
Message-ID: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
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

Broadcom MDIO bus multiplexer is an integrated multiplexer where child bus
selection and mdio transaction logic lies inside multiplexer itself.
To accommodate this multiplexer in existing mux framework below changes
were required-

1. Passed MDIO parent bus via mdio_mux_init to MDIO mux framework.

This patch set includes MDIO bus multiplexer driver along with above
framework change. It includes one external bus node having Ethernet PHY
attached and two internal bus node holding PCIe PHYs.

This patch series is based on v4.7-rc1 and is available from github-
repo: https://github.com/Broadcom/arm64-linux.git
branch:mdio-mux-v5

-Changes from v4:
- disabled PCIe PHYs from dtsi and enabled in dts file.

-Changes from v3:
- Unregister and free the parent MDIO bus.
- rebased on net-next/master branch.

Reason for resend:
-Rebased on v4.7-rc1

Changes from v2:
-Addressed Rob's comments in this patch regarding typo/grammers.
-Addressed David's comments regarding local variables order.
-Removed property "mdio-integrated-mux" and used mdiobus_register()
in place of of_mdiobus_regsiter().
-removed usage of IS_ERR_OR_NULL to IS_ERR in PCIe PHY driver.

Changes from v1:
- stop using "brcm,is_c45" from bus node as suggested by Andrew. MDIO
PHY driver will logically OR MII_ADDR_C45 into the address when issues
any C45 MDIO read/write transaction.

Pramod Kumar (7):
  mdio: mux: Enhanced MDIO mux framework for integrated multiplexers
  binding: Make "mdio-parent-bus" property from mandatory to optional
  binding: mdio-mux: Add DT binding doc for Broadcom MDIO bus
    multiplexer
  dt: mdio-mux: Add mdio multiplexer driver node
  net: mdio-mux: Add MDIO mux driver for iProc SoCs
  binding: PHY: Binding doc for NS2 PCIe PHYs.
  phy: Add Northstar2 PCI Phy support

 .../bindings/net/brcm,mdio-mux-iproc.txt           |  59 +++++
 Documentation/devicetree/bindings/net/mdio-mux.txt |   3 +-
 .../bindings/phy/brcm,mdio-mux-bus-pci.txt         |  27 +++
 arch/arm64/boot/dts/broadcom/ns2-svk.dts           |  16 ++
 arch/arm64/boot/dts/broadcom/ns2.dtsi              |  39 ++++
 drivers/net/phy/Kconfig                            |  11 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-mux-bcm-iproc.c               | 248 +++++++++++++++++++++
 drivers/net/phy/mdio-mux-gpio.c                    |   2 +-
 drivers/net/phy/mdio-mux-mmioreg.c                 |   2 +-
 drivers/net/phy/mdio-mux.c                         |  28 ++-
 drivers/phy/Kconfig                                |   8 +
 drivers/phy/Makefile                               |   2 +-
 drivers/phy/phy-bcm-ns2-pcie.c                     | 115 ++++++++++
 include/linux/mdio-mux.h                           |   4 +-
 15 files changed, 550 insertions(+), 15 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt
 create mode 100644 drivers/net/phy/mdio-mux-bcm-iproc.c
 create mode 100644 drivers/phy/phy-bcm-ns2-pcie.c

-- 
1.9.1
