From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 0/8] ARM: Alpine: Ethernet support
Date: Fri,  3 Feb 2017 19:12:08 +0100
Message-ID: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, saeed@annapurnalabs.com, arnd@arndb.de,
 Antoine Tenart <antoine.tenart@free-electrons.com>, talz@annapurnalabs.com,
 rshitrit@annapurnalabs.com, barak@annapurnalabs.com, tsahee@annapurnalabs.com
To: netdev@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
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

Hello all,

This series intend to add Ethernet support for the Annapurna Labs Alpine
v1 (ARM) and v2 (ARM64). The series first adds helpers for the I/O
fabric interrupt controller that is found in many controllers on the
Alpine, then helpers for the so called "Universal DMA" (UDMA) are also
added and finally adds the Alpine Ethernet driver (split in a few
patches, per functionality).

Many units in the Alpine platform (as the Ethernet controller) are
connected to what is called an I/O fabric bus. All these units share a
common implementation of an interrupt controller (the IOFIC) and some
share a DMA controller implementation (the UDMA). These controller are
duplicated in each unit (and there can be more than one per unit) and
use the same common definitions and functions. This is why SoC-specific
helpers and headers are provided here, to abstract some code. As these
controllers are not fully independent ones (they just happen to expose
the same registers in the units register spaces), proper interrupt nor
DMA drivers were not implemented.

This Ethernet controller is connected over PCIe, uses MSIX interrupts,
handle multiple UDMA controllers (4 rx queues + 4 tx queues per UDMA),
and offloading helpers (TSO, checksum offloads...).

This was tested on an Alpine v2 (ARM64) platform, and applies on top
of net-next (8fe809a99263).

Thanks,

Antoine Tenart (8):
  alpine: add I/O fabric interrupt controller (iofic) helpers
  soc: alpine: add udma helpers
  pci: add Annapurna Labs PCI id
  net: ethernet: add the Alpine Ethernet driver
  net: ethernet: annapurna: add statistics helper
  net: ethernet: annapurna: add wol helpers to the Alpine driver
  net: ethernet: annapurna: add eee helpers to the Alpine driver
  net: ethernet: annapurna: add the coalesce helpers to the Alpine
    driver

 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/annapurna/Kconfig             |   29 +
 drivers/net/ethernet/annapurna/Makefile            |    6 +
 drivers/net/ethernet/annapurna/al_eth.c            | 3267 +++++++++++++++++++
 drivers/net/ethernet/annapurna/al_eth.h            |  282 ++
 drivers/net/ethernet/annapurna/al_hw_eth.h         | 1301 ++++++++
 drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h | 1099 +++++++
 .../net/ethernet/annapurna/al_hw_eth_mac_regs.h    |  738 +++++
 drivers/net/ethernet/annapurna/al_hw_eth_main.c    | 3367 ++++++++++++++++++++
 .../ethernet/annapurna/al_hw_unit_adapter_regs.h   |   24 +
 drivers/soc/Kconfig                                |    1 +
 drivers/soc/Makefile                               |    1 +
 drivers/soc/alpine/Kconfig                         |   11 +
 drivers/soc/alpine/Makefile                        |    1 +
 drivers/soc/alpine/udma/Makefile                   |    1 +
 drivers/soc/alpine/udma/al_udma_config.c           |  140 +
 drivers/soc/alpine/udma/al_udma_iofic.c            |  110 +
 drivers/soc/alpine/udma/al_udma_main.c             |  245 ++
 drivers/soc/alpine/udma/al_udma_queue.c            |  232 ++
 include/linux/pci_ids.h                            |    2 +
 include/linux/soc/alpine/al_hw_udma.h              |  499 +++
 include/linux/soc/alpine/al_hw_udma_config.h       |   75 +
 include/linux/soc/alpine/al_hw_udma_iofic.h        |  199 ++
 include/linux/soc/alpine/al_hw_udma_regs.h         |  134 +
 include/linux/soc/alpine/al_hw_udma_regs_m2s.h     |  413 +++
 include/linux/soc/alpine/al_hw_udma_regs_s2m.h     |  294 ++
 include/linux/soc/alpine/iofic.h                   |  165 +
 28 files changed, 12638 insertions(+)
 create mode 100644 drivers/net/ethernet/annapurna/Kconfig
 create mode 100644 drivers/net/ethernet/annapurna/Makefile
 create mode 100644 drivers/net/ethernet/annapurna/al_eth.c
 create mode 100644 drivers/net/ethernet/annapurna/al_eth.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_main.c
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_unit_adapter_regs.h
 create mode 100644 drivers/soc/alpine/Kconfig
 create mode 100644 drivers/soc/alpine/Makefile
 create mode 100644 drivers/soc/alpine/udma/Makefile
 create mode 100644 drivers/soc/alpine/udma/al_udma_config.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_iofic.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_main.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_queue.c
 create mode 100644 include/linux/soc/alpine/al_hw_udma.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_config.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_iofic.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs_m2s.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs_s2m.h
 create mode 100644 include/linux/soc/alpine/iofic.h

-- 
2.11.0
