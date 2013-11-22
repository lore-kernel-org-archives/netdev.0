From: Alistair Popple <alistair@popple.id.au>
Subject: [PATCH 0/8] IBM Akebono/PPC476GTR Support
Date: Fri, 22 Nov 2013 13:07:37 +1100
Message-ID: <1385086057-10884-1-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-mmc@vger.kernel.org, linuxppc-dev@ozlabs.org, stern@rowland.harvard.edu,
 Alistair Popple <alistair@popple.id.au>, cjb@laptop.org, davem@davemloft.net
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

The IBM Akebono board is a development board for the new PPC476GTR
system on chip (SoC).

Changes from V1:
 * Update device-tree compatible strings to reflect the name of the
   SoC rather than the board when those components are integrated into
   the SoC.
 * Updates to allow the new EMAC PHY interface to be compile tested.
 * Rather than adding a new compatible string for EHCI support
   usb-ehci is used and the corresponding driver (ehci-ppc-of)
   is merged into the generic EHCI platform driver.
 * A generic (usb-ohci) compatible string is used for OHCI.
 * PCI MSI support has been added via the HSTA module.

Alistair Popple (8):
  IBM Akebono: Add support to AHCI platform driver
  IBM Akebono: Add a SDHCI platform driver
  IBM Akebono: Add support for a new PHY interface to the IBM emac
    driver
  IBM Akebono: Add support to the OHCI platform driver for PPC476GTR
  ECHI Platform: Merge ppc-of EHCI driver into the ehci-platform driver
  IBM Currituck: Clean up board specific code before adding Akebono
    code
  IBM Akebono: Add the Akebono platform
  powerpc: Added PCI MSI support using the HSTA module

 .../devicetree/bindings/powerpc/4xx/akebono.txt    |   54 +++
 .../devicetree/bindings/powerpc/4xx/emac.txt       |    9 +
 arch/powerpc/boot/Makefile                         |    3 +
 arch/powerpc/boot/dcr.h                            |    4 +
 arch/powerpc/boot/dts/akebono.dts                  |  415 ++++++++++++++++++++
 arch/powerpc/boot/treeboot-akebono.c               |  179 +++++++++
 arch/powerpc/boot/wrapper                          |    3 +
 arch/powerpc/configs/44x/akebono_defconfig         |  148 +++++++
 arch/powerpc/platforms/44x/Kconfig                 |   32 +-
 arch/powerpc/platforms/44x/Makefile                |    3 +-
 arch/powerpc/platforms/44x/currituck.c             |  233 -----------
 arch/powerpc/platforms/44x/ppc476.c                |  299 ++++++++++++++
 arch/powerpc/sysdev/Kconfig                        |    6 +
 arch/powerpc/sysdev/Makefile                       |    1 +
 arch/powerpc/sysdev/ppc4xx_hsta_msi.c              |  266 +++++++++++++
 arch/powerpc/sysdev/ppc4xx_pci.c                   |   41 +-
 arch/powerpc/sysdev/ppc4xx_pci.h                   |    4 +-
 drivers/ata/ahci_platform.c                        |    1 +
 drivers/mmc/host/Kconfig                           |   12 +
 drivers/mmc/host/Makefile                          |    1 +
 drivers/mmc/host/sdhci-of-476gtr.c                 |   60 +++
 drivers/net/ethernet/ibm/emac/Kconfig              |    4 +
 drivers/net/ethernet/ibm/emac/Makefile             |    1 +
 drivers/net/ethernet/ibm/emac/core.c               |   50 ++-
 drivers/net/ethernet/ibm/emac/core.h               |   12 +
 drivers/net/ethernet/ibm/emac/rgmii_wol.c          |  243 ++++++++++++
 drivers/net/ethernet/ibm/emac/rgmii_wol.h          |   62 +++
 drivers/usb/host/Kconfig                           |    7 +-
 drivers/usb/host/ehci-hcd.c                        |    5 -
 drivers/usb/host/ehci-platform.c                   |   86 +++-
 drivers/usb/host/ehci-ppc-of.c                     |  236 -----------
 drivers/usb/host/ohci-platform.c                   |   22 +-
 32 files changed, 1992 insertions(+), 510 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/powerpc/4xx/akebono.txt
 create mode 100644 arch/powerpc/boot/dts/akebono.dts
 create mode 100644 arch/powerpc/boot/treeboot-akebono.c
 create mode 100644 arch/powerpc/configs/44x/akebono_defconfig
 delete mode 100644 arch/powerpc/platforms/44x/currituck.c
 create mode 100644 arch/powerpc/platforms/44x/ppc476.c
 create mode 100644 arch/powerpc/sysdev/ppc4xx_hsta_msi.c
 create mode 100644 drivers/mmc/host/sdhci-of-476gtr.c
 create mode 100644 drivers/net/ethernet/ibm/emac/rgmii_wol.c
 create mode 100644 drivers/net/ethernet/ibm/emac/rgmii_wol.h
 delete mode 100644 drivers/usb/host/ehci-ppc-of.c

-- 
1.7.10.4
