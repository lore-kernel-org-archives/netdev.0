From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.4] NFC update
Date: Thu, 29 Oct 2015 05:58:59 +0100
Message-ID: <20151029045859.GB20229@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53284 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbbJ2E7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 00:59:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the NFC pull request for 4.4.

It's a bit bigger than usual, the 3 main culprits being:

- A new driver for Intel's Fields Peak NCI chipset. In order to
  support this chipset we had to export a few NCI routines and
  extend the driver NCI ops to not only support proprietary
  commands but also core ones.

- Support for vendor commands for both STM drivers, st-nci
  and st21nfca. Those vendor commands allow to run factory tests
  through the NFC netlink interface.

- New i2c and SPI support for the Marvell driver, together with
  firmware download support for this driver's core.

Besides that we also have:

- A few file renames in the STM drivers, to keep the naming
  consistent between drivers.

- Some improvements and fixes on the NCI HCI layer, mostly to
  properly reach a secure element over a legacy HCI link.

- A few fixes for the s3fwrn5 and trf7970a drivers.


The following changes since commit f6d3125fa3c2f55ddf7cf69365c41089de6cfae6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-10-02 07:21:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.4-2

for you to fetch changes up to f11631748ee6973f85238109a3fa8ab8e760e5a4:

  NFC: nci: non-static functions can not be inline (2015-10-28 06:44:45 +0100)

----------------------------------------------------------------
Axel Lin (2):
      nfc: s3fwrn5: Make NFC_S3FWRN5 select CRYPTO
      nfc: s3fwrn5: i2c: Use devm_request_threaded_irq to avoid irq leak

Christophe JAILLET (1):
      NFC: nfcwilink: Drop a useless static qualifier

Christophe Ricard (35):
      NFC: st-nci: Align st-nci driver with other nfc driver
      NFC: st-nci: include st-nci.h instead of ndlc.h
      NFC: st21nfca: Align st21nfca driver with other nfc driver
      NFC: st-nci: Fix incorrect spi buffer size
      NFC: nci: Fix incorrect data chaining when sending data
      NFC: nci: Fix improper management of HCI return code
      NFC: nci: extract pipe value using NCI_HCP_MSG_GET_PIPE
      NFC: nci: add nci_hci_clear_all_pipes functions
      NFC: nci: Call nci_hci_clear_all_pipes at HCI initial activation.
      NFC: nci: Create pipe on specific gate in nci_hci_connect_gate
      NFC: st-nci: Remove HCI init_data.gates initialization in load_session
      NFC: st21nfca: Remove HCI gates initialization in load_session
      NFC: st-nci: Open NCI_HCI_LINK_MGMT_PIPE
      NFC: st21nfca: Open NFC_HCI_LINK_MGMT_PIPE
      NFC: st-nci: Keep st_nci_gates unchanged in load_session
      NFC: st21nfca: Keep st21nfca_gates unchanged in load_session
      NFC: st-nci: initialize gate_count in st_nci_hci_network_init
      NFC: st-nci: Add support for NCI_HCI_IDENTITY_MGMT_GATE
      NFC: st-nci: Fix st_nci_gates offset
      NFC: st21nfca: Fix st21nfca_gates offset
      NFC: st-nci: Add support for proprietary commands
      NFC: st-nci: Add error messages when an unexpected HCI event occurs
      NFC: netlink: Add missing NFC_ATTR comments
      NFC: st-nci: Add ese-present/uicc-present dts properties
      NFC: st-nci: Increase delay between 2 secure element activations
      NFC: st-nci: Fix host_list verification after SE activation
      NFC: st21nfca: Fix host_list verification after SEactivation
      NFC: netlink: Add mode parameter to deactivate_target functions
      NFC: st-nci: Add few code style fixes
      NFC: st21nfca: Add few code style fixes
      NFC: st21nfca: Add error messages for unexpected HCI events
      NFC: st-nci: Disable irq when powering the device up
      NFC: st-nci: remove duplicated skb dump
      NFC: st-nci: Replace st21nfcb by st_nci in makefile
      NFC: st21nfca: Add support for proprietary commands

Javier Martinez Canillas (1):
      NFC: trf7970a: Add OF match table

Jean Delvare (3):
      NFC: pn544: Auto-select core module
      NFC: microread: Auto-select core module
      NFC: nfcmrvl: Auto-select core module

Julia Lawall (2):
      NFC: nxp-nci: constify nxp_nci_phy_ops structure
      NFC: delete null dereference

Robert Dolca (11):
      NFC: nci: Export nci data send API
      NFC: nci: Add function to get max packet size for conn
      NFC: nci: Introduce new core opcodes
      NFC: nci: Do not call post_setup when setup fails
      NFC: nci: Introduce nci_core_cmd
      NFC: nci: Allow the driver to set handler for core nci ops
      NFC: nci: rename nci_prop_ops to nci_driver_ops
      NFC: nci: fix possible crash in nci_core_conn_create
      NFC: nci: add nci_get_conn_info_by_id function
      NFC: Add Intel Fields Peak NFC solution driver
      NFC: nci: non-static functions can not be inline

Samuel Ortiz (2):
      NFC: nci: Use __nci_request for exported routines
      NFC: st-nci: Rename st-nci_se.c

Valentin Rothberg (1):
      NFC: s3fwrn5: Remove superfluous cflags

Vincent Cuissard (9):
      NFC: nfcmrvl: remove unneeded version defines
      NFC: NCI: export nci_send_frame and nci_send_cmd function
      NFC: nfcmrvl: add firmware download support
      NFC: nfcmrvl: configure head/tail room values per low level drivers
      NFC: nfcmrvl: add i2c driver
      NFC: NCI: move generic spi driver to a module
      NFC: NCI: allow spi driver to choose transfer clock
      NFC: nfcmrvl: add spi driver
      NFC: nfcmrvl: update device tree bindings for Marvell NFC

 .../devicetree/bindings/net/nfc/nfcmrvl.txt        |  61 +-
 .../devicetree/bindings/net/nfc/st-nci-i2c.txt     |   7 +
 .../devicetree/bindings/net/nfc/st-nci-spi.txt     |   9 +-
 drivers/nfc/Kconfig                                |   1 +
 drivers/nfc/Makefile                               |   1 +
 drivers/nfc/fdp/Kconfig                            |  23 +
 drivers/nfc/fdp/Makefile                           |   9 +
 drivers/nfc/fdp/fdp.c                              | 817 +++++++++++++++++++++
 drivers/nfc/fdp/fdp.h                              |  38 +
 drivers/nfc/fdp/i2c.c                              | 388 ++++++++++
 drivers/nfc/microread/Kconfig                      |  18 +-
 drivers/nfc/nfcmrvl/Kconfig                        |  34 +-
 drivers/nfc/nfcmrvl/Makefile                       |   8 +-
 drivers/nfc/nfcmrvl/fw_dnld.c                      | 553 ++++++++++++++
 drivers/nfc/nfcmrvl/fw_dnld.h                      |  98 +++
 drivers/nfc/nfcmrvl/i2c.c                          | 290 ++++++++
 drivers/nfc/nfcmrvl/main.c                         |  75 +-
 drivers/nfc/nfcmrvl/nfcmrvl.h                      |  23 +-
 drivers/nfc/nfcmrvl/spi.c                          | 228 ++++++
 drivers/nfc/nfcmrvl/uart.c                         |  26 +-
 drivers/nfc/nfcmrvl/usb.c                          |  10 +-
 drivers/nfc/nfcsim.c                               |   2 +-
 drivers/nfc/nfcwilink.c                            |   2 +-
 drivers/nfc/nxp-nci/core.c                         |   3 +-
 drivers/nfc/nxp-nci/i2c.c                          |   2 +-
 drivers/nfc/nxp-nci/nxp-nci.h                      |   5 +-
 drivers/nfc/pn533.c                                |   2 +-
 drivers/nfc/pn544/Kconfig                          |  18 +-
 drivers/nfc/s3fwrn5/Kconfig                        |   1 +
 drivers/nfc/s3fwrn5/Makefile                       |   2 -
 drivers/nfc/s3fwrn5/i2c.c                          |   2 +-
 drivers/nfc/s3fwrn5/nci.c                          |   4 +-
 drivers/nfc/s3fwrn5/nci.h                          |   2 +-
 drivers/nfc/st-nci/Makefile                        |   4 +-
 drivers/nfc/st-nci/core.c                          |  20 +-
 drivers/nfc/st-nci/i2c.c                           |  35 +-
 drivers/nfc/st-nci/ndlc.c                          |   7 +-
 drivers/nfc/st-nci/ndlc.h                          |   5 +-
 drivers/nfc/st-nci/{st-nci_se.c => se.c}           | 166 +++--
 drivers/nfc/st-nci/spi.c                           |  37 +-
 drivers/nfc/st-nci/st-nci.h                        | 117 ++-
 drivers/nfc/st-nci/st-nci_se.h                     |  61 --
 drivers/nfc/st-nci/vendor_cmds.c                   | 516 +++++++++++++
 drivers/nfc/st21nfca/Makefile                      |   2 +-
 drivers/nfc/st21nfca/{st21nfca.c => core.c}        |  48 +-
 drivers/nfc/st21nfca/{st21nfca_dep.c => dep.c}     |   2 +-
 drivers/nfc/st21nfca/i2c.c                         |   1 +
 drivers/nfc/st21nfca/{st21nfca_se.c => se.c}       |  18 +-
 drivers/nfc/st21nfca/st21nfca.h                    | 148 +++-
 drivers/nfc/st21nfca/st21nfca_dep.h                |  43 --
 drivers/nfc/st21nfca/st21nfca_se.h                 |  63 --
 drivers/nfc/st21nfca/vendor_cmds.c                 | 375 ++++++++++
 drivers/nfc/trf7970a.c                             |   7 +
 include/linux/platform_data/nfcmrvl.h              |   8 +
 include/linux/platform_data/st-nci.h               |   2 +
 include/net/nfc/nci.h                              |   8 +
 include/net/nfc/nci_core.h                         |  24 +-
 include/net/nfc/nfc.h                              |   2 +-
 include/uapi/linux/nfc.h                           |   2 +
 net/nfc/core.c                                     |   4 +-
 net/nfc/digital_core.c                             |   3 +-
 net/nfc/hci/core.c                                 |   3 +-
 net/nfc/hci/llc.c                                  |   2 +
 net/nfc/nci/Kconfig                                |   2 +-
 net/nfc/nci/Makefile                               |   3 +-
 net/nfc/nci/core.c                                 | 150 +++-
 net/nfc/nci/data.c                                 |  13 +
 net/nfc/nci/hci.c                                  | 167 ++++-
 net/nfc/nci/ntf.c                                  |   3 +-
 net/nfc/nci/rsp.c                                  |   1 +
 net/nfc/nci/spi.c                                  |  11 +-
 net/nfc/netlink.c                                  |   8 +-
 net/nfc/nfc.h                                      |   5 +-
 net/nfc/rawsock.c                                  |   3 +-
 74 files changed, 4380 insertions(+), 481 deletions(-)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/fdp.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c
 create mode 100644 drivers/nfc/nfcmrvl/fw_dnld.c
 create mode 100644 drivers/nfc/nfcmrvl/fw_dnld.h
 create mode 100644 drivers/nfc/nfcmrvl/i2c.c
 create mode 100644 drivers/nfc/nfcmrvl/spi.c
 rename drivers/nfc/st-nci/{st-nci_se.c => se.c} (82%)
 delete mode 100644 drivers/nfc/st-nci/st-nci_se.h
 create mode 100644 drivers/nfc/st-nci/vendor_cmds.c
 rename drivers/nfc/st21nfca/{st21nfca.c => core.c} (97%)
 rename drivers/nfc/st21nfca/{st21nfca_dep.c => dep.c} (99%)
 rename drivers/nfc/st21nfca/{st21nfca_se.c => se.c} (96%)
 delete mode 100644 drivers/nfc/st21nfca/st21nfca_dep.h
 delete mode 100644 drivers/nfc/st21nfca/st21nfca_se.h
 create mode 100644 drivers/nfc/st21nfca/vendor_cmds.c
