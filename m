From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.1] NFC update
Date: Wed, 8 Apr 2015 19:19:43 +0200
Message-ID: <20150408171943.GA21610@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NFC <linux-nfc@lists.01.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10463 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbbDHRTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 13:19:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here goes the NFC update for 4.1.

This is a shorter one than usual, as the Intel Field Peak NFC
driver could not make it in time.

We have:

- A new driver for NXP NCI based chipsets, like e.g. the NPC100 or
  the PN7150. It currently only supports an i2c physical layer, but
  could easily be extended to work on top of e.g. SPI.
  This driver also includes support for user space triggered firmware
  updates.

- A few minor st21nfc[ab] fixes, cleanups, and comments improvements.

- A pn533 error return fix.

- A few NFC related logs formatting cleanups.

The following changes since commit 5a352dd0a3aac03b443c94828dfd7144261c=
8636:

  ipv6: hash net ptr into fragmentation bucket selection (2015-03-25 14=
:07:04 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags=
/nfc-next-4.1-1

for you to fetch changes up to 3590ebc040c9ee5d06754ce926f0e7c3a595e46d=
:

  NFC: logging neatening (2015-04-07 12:05:12 +0200)

----------------------------------------------------------------
Christophe Ricard (10):
      NFC: st21nfcb: Fix memory leak in secure element probing stage
      NFC: st21nfcb: Retry i2c_master_send if it returns a negative val=
ue
      NFC: st21nfca: fix st21nfca_get_iso14443_3_uid data copy
      NFC: st21nfca: Change st21nfca_get_iso14443_3_uid parameter name
      nfc: hci: Add comment to explain NFC_HCI_MAX_PIPES
      nfc: Reduce nfc_evt_transaction params length to 0
      nfc: st21nfcb: Add missing break statement in switch section
      nfc: nci: Add comment to explain NCI_HCI_MAX_PIPES
      nfc: st21nfcb: Add additional comments about EVT_TRANSACTION
      nfc: st21nfca: Add additional comments about EVT_TRANSACTION

Cl=E9ment Perrochaud (3):
      NFC: nci: Add firmware download support
      NFC: nxp-nci: Add support for NXP NCI chips
      NFC: nxp-nci_i2c: Add I2C support to NXP NCI driver

Joe Perches (1):
      NFC: logging neatening

Julia Lawall (1):
      NFC: pn533: fix error return code

Samuel Ortiz (2):
      NFC: nxp-nxi: Remove useless fw pointer check
      NFC: nxp-nci: Release firmware when switching to FW mode fails

 .../devicetree/bindings/net/nfc/nxp-nci.txt        |  35 ++
 MAINTAINERS                                        |   7 +
 drivers/nfc/Kconfig                                |   1 +
 drivers/nfc/Makefile                               |   1 +
 drivers/nfc/microread/i2c.c                        |   2 +-
 drivers/nfc/nfcmrvl/main.c                         |   4 +-
 drivers/nfc/nfcmrvl/usb.c                          |  18 +-
 drivers/nfc/nxp-nci/Kconfig                        |  25 ++
 drivers/nfc/nxp-nci/Makefile                       |  11 +
 drivers/nfc/nxp-nci/core.c                         | 186 +++++++++
 drivers/nfc/nxp-nci/firmware.c                     | 325 +++++++++++++=
+++
 drivers/nfc/nxp-nci/i2c.c                          | 415 +++++++++++++=
++++++++
 drivers/nfc/nxp-nci/nxp-nci.h                      |  89 +++++
 drivers/nfc/pn533.c                                |   6 +-
 drivers/nfc/pn544/i2c.c                            |   7 +-
 drivers/nfc/port100.c                              |  36 +-
 drivers/nfc/st21nfca/st21nfca.c                    |   4 +-
 drivers/nfc/st21nfca/st21nfca_se.c                 |  11 +-
 drivers/nfc/st21nfcb/i2c.c                         |   9 +-
 drivers/nfc/st21nfcb/ndlc.c                        |   5 +-
 drivers/nfc/st21nfcb/st21nfcb_se.c                 |  16 +-
 include/linux/platform_data/nxp-nci.h              |  27 ++
 include/net/nfc/hci.h                              |   4 +
 include/net/nfc/nci_core.h                         |   5 +
 include/net/nfc/nfc.h                              |   2 +-
 net/nfc/nci/core.c                                 |  11 +
 26 files changed, 1207 insertions(+), 55 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/nxp-nci.t=
xt
 create mode 100644 drivers/nfc/nxp-nci/Kconfig
 create mode 100644 drivers/nfc/nxp-nci/Makefile
 create mode 100644 drivers/nfc/nxp-nci/core.c
 create mode 100644 drivers/nfc/nxp-nci/firmware.c
 create mode 100644 drivers/nfc/nxp-nci/i2c.c
 create mode 100644 drivers/nfc/nxp-nci/nxp-nci.h
 create mode 100644 include/linux/platform_data/nxp-nci.h
