From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.6] NFC update
Date: Wed, 11 May 2016 11:11:28 +0200
Message-ID: <20160511091128.GA4214@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65520 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbcEKJLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 05:11:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the first NFC pull request for 4.7. With this one we
mainly have:

- Support for NXP's pn532 NFC chipset. The pn532 is based on the same
  microcontroller as the pn533, but it talks to the host through i2c
  instead of USB. By separating the pn533 driver into core and PHY
  parts, we can not add the i2c layer and support the pn532 chipset.

- Support for NCI's loopback mode. This is a testing mode where each
  packet received by the NFCC is sent back to the DH, allowing the
  host to test that the controller can receive and send data.

- A few ACPI related fixes for the STMicro drivers, in order to match
  the device tree naming scheme.

- A bunch of cleanups for the st-nci and the st21nfca STMicro drivers.


The following changes since commit 03c5b534185f9844c1b5fcfdbae2adc32821ec42:

  ipv6: fix inet6_lookup_listener() (2016-04-09 16:53:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.7-1

for you to fetch changes up to b31d5103c33280738188c51e226224dff4401c7b:

  NFC: pn533: handle interrupted commands in pn533_recv_frame (2016-05-10 00:01:47 +0200)

----------------------------------------------------------------
Christophe Ricard (20):
      nfc: st21nfca: Fix static checker warning
      nfc: st-nci: i2c: Change ST_NCI_GPIO_NAME_RESET to match DT
      nfc: st-nci: spi: Change ST_NCI_GPIO_NAME_RESET to match DT
      nfc: st21nfca: i2c: Change ST21NFCA_GPIO_NAME_RESET to match DT
      nfc: st21nfca: set is_ese_present and is_uicc_present properly
      nfc: st-nci: set is_ese_present and is_uicc_present properly
      nfc: st21nfca: Simplify white list building
      nfc: st-nci: Simplify white list building
      nfc: st-nci: A APDU_READER_GATE pipe is unexpected on a UICC
      nfc: st21nfca: A APDU_READER_GATE pipe is unexpected on a UICC
      NFC: st21nfca: Drop two useless checks in ACPI probe path
      NFC: st-nci: i2c: Drop two useless checks in ACPI probe path
      NFC: st-nci: spi: Drop two useless checks in ACPI probe path
      nfc: st-nci: Remove redundant ST_NCI_HCI_HOST_ID_ESE from st-nci.h
      nfc: st21nfca: Remove duplicated ST21NFCA_ESE_HOST_ID from se.c
      nfc: nci: Fix nci_core_conn_create to allowing empty destination
      nfc: nci: Fix nci_core_conn_close
      nfc: nci: Add an additional parameter to identify a connection id
      nfc: nci: Add nci_nfcc_loopback to the nci core
      nfc: st-nci: Move loopback usage from HCI to NCI

Krzysztof Kozlowski (1):
      nfc: Drop owner assignment from i2c_driver

Michael Thalmeier (10):
      NFC: pn533: Send ATR_REQ only if NFC_PROTO_NFC_DEP bit is set
      NFC: pn533: Fix socket deadlock
      NFC: pn533: Separate physical layer from the core implementation
      NFC: pn533: add I2C phy driver
      nfc: pn533: Add device tree documentation for i2c phy
      NFC: pn533: i2c: free irq on driver remove
      NFC: pn533: fix order of initialization
      NFC: pn533: i2c: do not call pn533_recv_frame with aborted commands
      NFC: pn533: reset poll modulation list before calling targets_found
      NFC: pn533: handle interrupted commands in pn533_recv_frame

 .../devicetree/bindings/net/nfc/pn533-i2c.txt      |   31 +
 drivers/nfc/Kconfig                                |   11 +-
 drivers/nfc/Makefile                               |    2 +-
 drivers/nfc/fdp/fdp.c                              |    3 +-
 drivers/nfc/nxp-nci/i2c.c                          |    1 -
 drivers/nfc/pn533/Kconfig                          |   27 +
 drivers/nfc/pn533/Makefile                         |    9 +
 drivers/nfc/pn533/i2c.c                            |  281 +++++
 drivers/nfc/{ => pn533}/pn533.c                    | 1220 +++++---------------
 drivers/nfc/pn533/pn533.h                          |  238 ++++
 drivers/nfc/pn533/usb.c                            |  597 ++++++++++
 drivers/nfc/pn544/i2c.c                            |    1 -
 drivers/nfc/st-nci/i2c.c                           |   33 +-
 drivers/nfc/st-nci/se.c                            |   28 +-
 drivers/nfc/st-nci/spi.c                           |   32 +-
 drivers/nfc/st-nci/st-nci.h                        |   14 +-
 drivers/nfc/st-nci/vendor_cmds.c                   |   62 +-
 drivers/nfc/st21nfca/core.c                        |   13 +-
 drivers/nfc/st21nfca/i2c.c                         |   39 +-
 drivers/nfc/st21nfca/se.c                          |    2 -
 include/net/nfc/nci_core.h                         |   17 +-
 net/nfc/nci/core.c                                 |  117 +-
 net/nfc/nci/ntf.c                                  |    2 +-
 net/nfc/nci/rsp.c                                  |   23 +-
 24 files changed, 1695 insertions(+), 1108 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/pn533-i2c.txt
 create mode 100644 drivers/nfc/pn533/Kconfig
 create mode 100644 drivers/nfc/pn533/Makefile
 create mode 100644 drivers/nfc/pn533/i2c.c
 rename drivers/nfc/{ => pn533}/pn533.c (67%)
 create mode 100644 drivers/nfc/pn533/pn533.h
 create mode 100644 drivers/nfc/pn533/usb.c
