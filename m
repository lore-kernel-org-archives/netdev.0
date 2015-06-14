From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.2] NFC update
Date: Sun, 14 Jun 2015 18:00:45 +0200
Message-ID: <20150614160045.GA10440@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:58867 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbbFNQAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jun 2015 12:00:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the NFC pull request for 4.2:

- NCI drivers can now define their own handlers for processing
  proprietary NCI responses and notifications.

- NFC vendors can use a dedicated netlink API to send their own
  proprietary commands, like e.g. all commands needed to implement
  vendor specific manufacturing tools.

- A new generic NCI over UART driver against which any NCI chipset
  running on top of a serial interface can register.

- The st21nfcb driver is renamed to st-nci as it can and will support
  most of ST Microelectronics NCI chipsets.

- The st21nfcb driver can put its CLF in hibernate mode and save
  significant amount of power.

- A few st21nfcb minor fixes.

- The NXP NCI driver now supports ACPI enumeration.

- The Marvell NCI driver now supports both USB and serial
  physical interfaces.

- The Marvell NCI drivers also supports NCI frames being muxed
  over HCI. This is a setting that can be defined by a DT property.


The following changes since commit 6da8253bdd3945b81377e4908d6d395a9956=
f8af:

  net: phy: bcm7xxx: update workaround to fix 100BaseT corner cases (20=
15-06-08 12:16:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags=
/nfc-next-4.2-1

for you to fetch changes up to d0dcad8bd32a34aa85bcbd5d2033658cb3964377=
:

  NFC: nfcmrvl: set PB_BAIL_OUT at setup (2015-06-13 00:08:55 +0200)

----------------------------------------------------------------
Christophe Ricard (14):
      NFC: nci: Add NCI_RESET return code check before setup
      NFC: nci: Add nci init ops for early device initialization
      NFC: nci: Add nci_prop_cmd allowing to send proprietary nci cmd
      NFC: st21nfcb: Do not remove header once the payload is sent
      NFC: st21nfcb: remove st21nfcb_nci_i2c_disable
      NFC: st21nfcb: Add ndlc_close in st21nfcb_nci_remove
      NFC: st21nfcb: Fix st21nfcb_nci_close
      NFC: st21nfcb: Add support for nci proprietary commands
      NFC: nci: Move close ops call in nci_close_device
      NFC: st21nfcb: Move st21nfcb_nci_remove in ndlc_remove
      NFC: st21nfcb: Move powered flag from phy to ndlc layer
      NFC: st21nfcb: disable irq when st21nfcb is disabled
      NFC: st21nfcb: Configure CLF with NCI proprietary command
      nfc: st-nci: Rename st21nfcb to st-nci

=46iro Yang (1):
      NFC: st21nfcb: Remove inappropriate kfree on a devm_kzalloc point=
er

Joe Perches (1):
      NFC: nci: hci: Fix releasing uninitialized skbs

Mark A. Greer (1):
      NFC: trf7970a: Handle extra byte in response to Type 5 RMB comman=
ds

Masanari Iida (1):
      NFC: Fix typo in nfc-hci.txt

Oleg Zhurakivskyy (1):
      NFC: nxp-nci_i2c: Add support for enumerating through ACPI

Samuel Ortiz (5):
      NFC: nxp-nci: Fix build warning
      NFC: nci: Handle proprietary response and notifications
      NFC: Introduce vendor commands structures
      NFC: netlink: Implement vendor command support
      NFC: nci: Export nci_req_complete

Tomas Winkler (1):
      NFC: microread: drop unused variable

Uwe Kleine-K=F6nig (1):
      NFC: pn544: use flags argument of devm_gpiod_get to set direction

Valentin Rothberg (1):
      NFC: Remove obsolete setting of DEBUG

Vincent Cuissard (12):
      NFC: nfcmrvl: remove integration related settings
      NFC: nfcmrvl: add support of HCI-based transport
      NFC: nfcmrvl: update nci recv frame API
      NFC: nfcmrvl: update USB device id
      NFC: nfcmrvl: add chip reset management
      NFC: nci: add generic uart support
      NFC: nfcmrvl: add platform_data and DT configuration
      NFC: nfcmrvl: add UART driver
      NFC: nfcmrvl: small fix in USB driver
      NFC: nfcmrvl: Allow ISO15693 protocol
      NFC: nci: remove current SLEEP mode management
      NFC: nfcmrvl: set PB_BAIL_OUT at setup

 .../devicetree/bindings/net/nfc/nfcmrvl.txt        |  29 ++
 .../bindings/net/nfc/{st21nfcb.txt =3D> st-nci.txt}  |   4 +-
 .../devicetree/bindings/net/nfc/trf7970a.txt       |   4 +
 Documentation/nfc/nfc-hci.txt                      |   2 +-
 drivers/nfc/Kconfig                                |   2 +-
 drivers/nfc/Makefile                               |   4 +-
 drivers/nfc/microread/i2c.c                        |   3 -
 drivers/nfc/nfcmrvl/Kconfig                        |  11 +
 drivers/nfc/nfcmrvl/Makefile                       |   3 +
 drivers/nfc/nfcmrvl/main.c                         | 134 +++++-
 drivers/nfc/nfcmrvl/nfcmrvl.h                      |  60 ++-
 drivers/nfc/nfcmrvl/uart.c                         | 225 ++++++++++
 drivers/nfc/nfcmrvl/usb.c                          |  27 +-
 drivers/nfc/nxp-nci/Makefile                       |   2 -
 drivers/nfc/nxp-nci/i2c.c                          |  52 +++
 drivers/nfc/pn544/i2c.c                            |  43 +-
 drivers/nfc/st-nci/Kconfig                         |  23 +
 drivers/nfc/st-nci/Makefile                        |   9 +
 drivers/nfc/st-nci/core.c                          | 179 ++++++++
 drivers/nfc/{st21nfcb =3D> st-nci}/i2c.c             | 147 +++---
 drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.c            |  23 +-
 drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.h            |   5 +-
 .../nfc/{st21nfcb/st21nfcb.h =3D> st-nci/st-nci.h}   |  30 +-
 .../{st21nfcb/st21nfcb_se.c =3D> st-nci/st-nci_se.c} | 383 ++++++++---=
-----
 drivers/nfc/st-nci/st-nci_se.h                     |  61 +++
 drivers/nfc/st21nfcb/Kconfig                       |  22 -
 drivers/nfc/st21nfcb/Makefile                      |   9 -
 drivers/nfc/st21nfcb/st21nfcb.c                    | 143 ------
 drivers/nfc/st21nfcb/st21nfcb_se.h                 |  61 ---
 drivers/nfc/trf7970a.c                             |  23 +-
 include/linux/platform_data/nfcmrvl.h              |  40 ++
 .../linux/platform_data/{st21nfcb.h =3D> st-nci.h}   |  14 +-
 include/linux/platform_data/st_nci.h               |  29 ++
 include/net/nfc/hci.h                              |   7 +
 include/net/nfc/nci.h                              |   1 +
 include/net/nfc/nci_core.h                         |  71 +++
 include/net/nfc/nfc.h                              |  22 +
 include/uapi/linux/nfc.h                           |  10 +
 include/uapi/linux/tty.h                           |   1 +
 net/nfc/nci/Kconfig                                |   7 +
 net/nfc/nci/Makefile                               |   3 +
 net/nfc/nci/core.c                                 | 105 ++++-
 net/nfc/nci/hci.c                                  |  11 +-
 net/nfc/nci/ntf.c                                  |  10 +
 net/nfc/nci/rsp.c                                  |  10 +
 net/nfc/nci/uart.c                                 | 494 +++++++++++++=
++++++++
 net/nfc/netlink.c                                  |  55 +++
 47 files changed, 1988 insertions(+), 625 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/nfcmrvl.t=
xt
 rename Documentation/devicetree/bindings/net/nfc/{st21nfcb.txt =3D> st=
-nci.txt} (87%)
 create mode 100644 drivers/nfc/nfcmrvl/uart.c
 create mode 100644 drivers/nfc/st-nci/Kconfig
 create mode 100644 drivers/nfc/st-nci/Makefile
 create mode 100644 drivers/nfc/st-nci/core.c
 rename drivers/nfc/{st21nfcb =3D> st-nci}/i2c.c (64%)
 rename drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.c (94%)
 rename drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.h (92%)
 rename drivers/nfc/{st21nfcb/st21nfcb.h =3D> st-nci/st-nci.h} (63%)
 rename drivers/nfc/{st21nfcb/st21nfcb_se.c =3D> st-nci/st-nci_se.c} (5=
4%)
 create mode 100644 drivers/nfc/st-nci/st-nci_se.h
 delete mode 100644 drivers/nfc/st21nfcb/Kconfig
 delete mode 100644 drivers/nfc/st21nfcb/Makefile
 delete mode 100644 drivers/nfc/st21nfcb/st21nfcb.c
 delete mode 100644 drivers/nfc/st21nfcb/st21nfcb_se.h
 create mode 100644 include/linux/platform_data/nfcmrvl.h
 rename include/linux/platform_data/{st21nfcb.h =3D> st-nci.h} (70%)
 create mode 100644 include/linux/platform_data/st_nci.h
 create mode 100644 net/nfc/nci/uart.c
