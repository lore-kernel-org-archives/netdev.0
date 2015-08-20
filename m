From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.3] NFC update
Date: Fri, 21 Aug 2015 01:39:08 +0200
Message-ID: <20150820233908.GA1988@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFC <linux-nfc@lists.01.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63405 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690AbbHTXjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 19:39:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the NFC pull request for 4.3.
With this one we have:

- A new driver for Samsung's S3FWRN5 NFC chipset. In order to
  properly support this driver, a few NCI core routines needed
  to be exported. Future drivers like Intel's Fields Peak will
  benefit from this.

- SPI support as a physical transport for STM st21nfcb.

- An additional netlink API for sending replies back to userspace
  from vendor commands.

- 2 small fixes for TI's trf7970a

- A few st-nci fixes.


The following changes since commit d52736e24fe2e927c26817256f8d1a3c8b5d51a0:

  Merge branch 'vrf-lite' (2015-08-13 22:43:22 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.3-1

for you to fetch changes up to 29e76924cf087bc6a9114a9244828fd13ae959bb:

  nfc: netlink: Add capability to reply to vendor_cmd with data (2015-08-20 22:00:11 +0200)

----------------------------------------------------------------
Christophe Ricard (14):
      nfc: st-nci: Remove duplicate file platform_data/st_nci.h
      nfc: st-nci: Fix typo when changing from st21nfcb to st-nci
      nfc: st-nci: Fix non accurate comment for st_nci_i2c_read
      NFC: st21nfca: fix use of uninitialized variables in error path
      NFC: st-nci: fix use of uninitialized variables in error path
      nfc: st-nci: Remove data from ack_pending_q when receiving a SYNC_ACK
      nfc: st-nci: Free data with irrelevant NDLC PCB_SYNC value
      nfc: st-nci: Add spi phy support for st21nfcb
      nfc: st-nci: Add device tree documentation for spi phy
      nfc: st-nci: Remove pr_err in rcv_queue when ndlc header is unknown
      nfc: netlink: Add check on NFC_ATTR_VENDOR_DATA
      nfc: netlink: Warning fix
      nfc: nci: hci: Add check on skb nci_hci_send_cmd parameter
      nfc: netlink: Add capability to reply to vendor_cmd with data

Mark Greer (2):
      NFC: trf7970a: SDD_EN is bit 5 not bit 3
      NFC: trf7970a: Add NULL check to clear up smatch warning

Robert Baldyga (3):
      NFC: nci: Add post_setup handler
      NFC: nci: export nci_core_reset and nci_core_init
      nfc: s3fwrn5: Add driver for Samsung S3FWRN5 NFC Chip

 .../devicetree/bindings/net/nfc/s3fwrn5.txt        |  27 ++
 .../net/nfc/{st-nci.txt => st-nci-i2c.txt}         |   0
 .../devicetree/bindings/net/nfc/st-nci-spi.txt     |  31 ++
 MAINTAINERS                                        |   6 +
 drivers/nfc/Kconfig                                |   1 +
 drivers/nfc/Makefile                               |   1 +
 drivers/nfc/s3fwrn5/Kconfig                        |  19 +
 drivers/nfc/s3fwrn5/Makefile                       |  11 +
 drivers/nfc/s3fwrn5/core.c                         | 219 +++++++++
 drivers/nfc/s3fwrn5/firmware.c                     | 511 +++++++++++++++++++++
 drivers/nfc/s3fwrn5/firmware.h                     | 111 +++++
 drivers/nfc/s3fwrn5/i2c.c                          | 306 ++++++++++++
 drivers/nfc/s3fwrn5/nci.c                          | 165 +++++++
 drivers/nfc/s3fwrn5/nci.h                          |  89 ++++
 drivers/nfc/s3fwrn5/s3fwrn5.h                      |  99 ++++
 drivers/nfc/st-nci/Kconfig                         |  11 +
 drivers/nfc/st-nci/Makefile                        |   3 +
 drivers/nfc/st-nci/i2c.c                           |  23 +-
 drivers/nfc/st-nci/ndlc.c                          |   7 +-
 drivers/nfc/st-nci/spi.c                           | 392 ++++++++++++++++
 drivers/nfc/st-nci/st-nci_se.c                     |   8 +-
 drivers/nfc/st21nfca/st21nfca.c                    |  11 +-
 drivers/nfc/trf7970a.c                             |   6 +-
 include/linux/platform_data/st_nci.h               |  29 --
 include/net/nfc/nci_core.h                         |   3 +
 include/net/nfc/nfc.h                              |  41 ++
 net/nfc/nci/core.c                                 |  18 +
 net/nfc/nci/hci.c                                  |   2 +-
 net/nfc/netlink.c                                  |  91 +++-
 29 files changed, 2180 insertions(+), 61 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/s3fwrn5.txt
 rename Documentation/devicetree/bindings/net/nfc/{st-nci.txt => st-nci-i2c.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/st-nci-spi.txt
 create mode 100644 drivers/nfc/s3fwrn5/Kconfig
 create mode 100644 drivers/nfc/s3fwrn5/Makefile
 create mode 100644 drivers/nfc/s3fwrn5/core.c
 create mode 100644 drivers/nfc/s3fwrn5/firmware.c
 create mode 100644 drivers/nfc/s3fwrn5/firmware.h
 create mode 100644 drivers/nfc/s3fwrn5/i2c.c
 create mode 100644 drivers/nfc/s3fwrn5/nci.c
 create mode 100644 drivers/nfc/s3fwrn5/nci.h
 create mode 100644 drivers/nfc/s3fwrn5/s3fwrn5.h
 create mode 100644 drivers/nfc/st-nci/spi.c
 delete mode 100644 include/linux/platform_data/st_nci.h
