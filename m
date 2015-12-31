From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.5] NFC update
Date: Thu, 31 Dec 2015 20:26:37 +0100
Message-ID: <20151231192637.GA3247@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45899 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbbLaT0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Dec 2015 14:26:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the first NFC pull request for 4.5 and it brings:

- A new driver for the STMicroelectronics ST95HF NFC chipset.
  The ST95HF is an NFC digital transceiver with an embedded analog
  front-end and as such relies on the Linux NFC digital
  implementation. This is the 3rd user of the NFC digital stack.

- ACPI support for the ST st-nci and st21nfca drivers.

- A small improvement for the nfcsim driver, as we can now tune
  the Rx delay through sysfs.

- A bunch of minor cleanups and small fixes from Christophe Ricard,
  for a few drivers and the NFC core code.


The following changes since commit 7f151f1d8abb7d5930b49d4796b463dca1673cb7:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-11-17 13:52:59 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.5-1

for you to fetch changes up to c6dc65d885b98898bf287aaf44e020077b41769f:

  NFC: nci: memory leak in nci_core_conn_create() (2015-12-29 19:06:23 +0100)

----------------------------------------------------------------
Christophe Ricard (27):
      nfc: st-nci: Remove useless #include "ndlc.h"
      nfc: st-nci: Remove unneeded CONFIG_OF switches
      nfc: st21nfca: Remove unneeded CONFIG_OF switches
      nfc: nxp-nci: Remove #ifdef CONFIG_OF
      nfc: pn544: Remove #ifdef CONFIG_OF
      nfc: st-nci: Group device table together
      nfc: st21nfca: Group device table together
      nfc: st-nci: Add macro for gpio name
      nfc: st21nfca: Add macro for gpio name
      nfc: st-nci: Add support for acpi probing for i2c device.
      nfc: st-nci: Add support for acpi probing for spi device.
      nfc: st21nfca: Add support for acpi probing for i2c device.
      nfc: st-nci: Code cleanup
      nfc: st21nfca: Code cleanup
      nfc: st21nfca: Remove useless pr_info in st21nfca_hci_i2c_disable
      NFC: nci: Fix error check of nci_hci_create_pipe() result
      NFC: st-nci: Auto-select core module
      NFC: st21nfca: Auto-select core module
      nfc: netlink: HCI event connectivity implementation
      nfc: st-nci: Add support for HCI event connectivity
      nfc: st21nfca: Add support for HCI event connectivity
      MAINTAINERS: nfc: Add missing platform_data files references
      nfc: fdp: Move i2c client irq checking
      nfc: microread: Remove useless irq field
      nfc: microread: Fix header comment
      nfc: nxp-nci: Remove i2c client gpio irq configuration
      nfc: pn544: Remove i2c client gpio irq configuration

Dan Carpenter (1):
      NFC: nci: memory leak in nci_core_conn_create()

Fabio Estevam (1):
      nxp-nci: i2c: Do not check specifically for -EREMOTEIO error

Geliang Tang (1):
      NFC: trf7970a: use to_spi_device

Julia Lawall (1):
      nfc: s3fwrn5: constify s3fwrn5_phy_ops structures

Saurabh Sengar (1):
      NFC: add rx delay sysfs parameter for nfcsim workqueue

Shikha Singh (4):
      NFC: digital: Add Type4A tags support
      NFC: Add STMicroelectronics ST95HF driver
      DT: bindings: net: nfc: Add ST95HF binding doc
      NFC: st95hf: Fix build error

 .../devicetree/bindings/net/nfc/st95hf.txt         |   50 +
 MAINTAINERS                                        |    5 +
 drivers/nfc/Kconfig                                |    1 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/fdp/i2c.c                              |   12 +-
 drivers/nfc/microread/i2c.c                        |    2 -
 drivers/nfc/nfcsim.c                               |   10 +-
 drivers/nfc/nxp-nci/i2c.c                          |   34 +-
 drivers/nfc/pn544/i2c.c                            |   46 +-
 drivers/nfc/s3fwrn5/core.c                         |    2 +-
 drivers/nfc/s3fwrn5/i2c.c                          |    2 +-
 drivers/nfc/s3fwrn5/s3fwrn5.h                      |    4 +-
 drivers/nfc/st-nci/Kconfig                         |   18 +-
 drivers/nfc/st-nci/i2c.c                           |   80 +-
 drivers/nfc/st-nci/ndlc.c                          |    1 -
 drivers/nfc/st-nci/se.c                            |    3 +-
 drivers/nfc/st-nci/spi.c                           |   81 +-
 drivers/nfc/st21nfca/Kconfig                       |   13 +-
 drivers/nfc/st21nfca/i2c.c                         |   80 +-
 drivers/nfc/st21nfca/se.c                          |    5 +-
 drivers/nfc/st95hf/Kconfig                         |   10 +
 drivers/nfc/st95hf/Makefile                        |    6 +
 drivers/nfc/st95hf/core.c                          | 1273 ++++++++++++++++++++
 drivers/nfc/st95hf/spi.c                           |  167 +++
 drivers/nfc/st95hf/spi.h                           |   64 +
 drivers/nfc/trf7970a.c                             |    8 +-
 include/linux/platform_data/microread.h            |    2 +-
 include/net/nfc/nfc.h                              |    1 +
 net/nfc/core.c                                     |   13 +
 net/nfc/digital_core.c                             |    3 +-
 net/nfc/nci/core.c                                 |    6 +-
 net/nfc/nci/hci.c                                  |    2 +-
 net/nfc/netlink.c                                  |   37 +
 net/nfc/nfc.h                                      |    1 +
 34 files changed, 1862 insertions(+), 181 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/st95hf.txt
 create mode 100644 drivers/nfc/st95hf/Kconfig
 create mode 100644 drivers/nfc/st95hf/Makefile
 create mode 100644 drivers/nfc/st95hf/core.c
 create mode 100644 drivers/nfc/st95hf/spi.c
 create mode 100644 drivers/nfc/st95hf/spi.h
