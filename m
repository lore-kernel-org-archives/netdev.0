From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2014-12-31
Date: Wed, 31 Dec 2014 09:25:49 +0200
Message-ID: <20141231072549.GA11458@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:60657 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbaLaH0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 02:26:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the first batch of bluetooth patches for 3.20.

 - Cleanups & fixes to ieee802154  drivers
 - Fix synchronization of mgmt commands with respective HCI commands
 - Add self-tests for LE pairing crypto functionality
 - Remove 'BlueFritz!' specific handling from core using a new quirk flag
 - Public address configuration support for ath3012
 - Refactor debugfs support into a dedicated file
 - Initial support for LE Data Length Extension feature from Bluetooth 4.2

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 86c8fc4bbe14b8950e62d379bb57722427ad3d67:

  Merge tag 'mac80211-for-davem-2014-12-18' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2014-12-18 15:33:49 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to e64b4fb66cc428cef0a62ea899b671c1aad05f3a:

  Bluetooth: Add timing information to ECDH test case runs (2014-12-30 10:32:11 +0200)

----------------------------------------------------------------
Alexander Aring (11):
      nl802154: introduce cca mode enums
      ieee802154: rework cca setting
      nl802154: introduce support for cca settings
      at86rf230: add reset state cca handling
      at86rf230: remove if branch
      at86rf230: make at86rf230_async_error inline
      at86rf230: fix context pointer handling
      at86rf230: remove unnecessary assign
      at86rf230: cleanup check on trac status
      mac802154: iface: check concurrent ifaces
      ieee802154: iface: move multiple node type check

Andrey Yurovsky (2):
      at86rf230: fix register read for part version
      at86rf230: remove version check for AT86RF212

Johan Hedberg (12):
      Bluetooth: Split hci_update_page_scan into two functions
      Bluetooth: Split hci_request helpers to hci_request.[ch]
      Bluetooth: Add hci_request support for hci_update_background_scan
      Bluetooth: Fix Remove Device to wait for HCI before sending cmd_complete
      Bluetooth: Fix Add Device to wait for HCI before sending cmd_complete
      Bluetooth: Add return parameter to cmd_complete callbacks
      Bluetooth: Move hci_update_page_scan to hci_request.c
      Bluetooth: Fix const declarations for smp_f5 and smp_f6
      Bluetooth: Add support for ECDH test cases
      Bluetooth: Add skeleton for SMP self-tests
      Bluetooth: Add legacy SMP tests
      Bluetooth: Add LE Secure Connections tests for SMP

Jukka Rissanen (1):
      Bluetooth: 6lowpan: Add IPSP PSM value

Marcel Holtmann (17):
      Bluetooth: Support static address when BR/EDR has been disabled
      Bluetooth: Add skeleton functions for debugfs creation
      Bluetooth: Move common debugfs file creation into hci_debugfs.c
      Bluetooth: Move BR/EDR debugfs file creation into hci_debugfs.c
      Bluetooth: Move LE debugfs file creation into hci_debugfs.c
      Bluetooth: Add structures for LE Data Length Extension feature
      Bluetooth: Enable basics for LE Data Length Extension feature
      Bluetooth: Store default and maximum LE data length settings
      Bluetooth: Create debugfs directory for each connection handle
      Bluetooth: Remove duplicate constant for RFCOMM PSM
      Bluetooth: Introduce HCI_QUIRK_BROKEN_LOCAL_COMMANDS constant
      Bluetooth: bfusb: Set the HCI_QUIRK_BROKEN_LOCAL_COMMANDS quirk
      Bluetooth: btusb: Set the HCI_QUIRK_BROKEN_LOCAL_COMMANDS quirk
      Bluetooth: Remove BlueFritz! specific check from initialization
      Bluetooth: Add support for self testing framework
      Bluetooth: Add timing information to SMP test case runs
      Bluetooth: Add timing information to ECDH test case runs

Stefan Schmidt (6):
      ieee802154/at86rf230: Remove unneeded blank lines
      ieee802154/at86rf230: Align to opening parenthesis
      ieee802154/at86rf230: Fix typo unkown -> unknown
      ieee802154/cc2520: Remove extra blank lines
      ieee802154/mrf24j40: Fix typo begining -> beginning
      ieee802154/mrf24j40: Fix alignment of parenthesis

Toshi Kikuchi (1):
      Bluetooth: btusb: support public address configuration for ath3012

Varka Bhadram (3):
      cc2520: use devm_kzalloc(.., sizeof(*pointer), ..) pattern
      cc2520: remove 'ret' goto label
      cc2520: fix zero perm_extended_addr address

Wolfram Sang (1):
      net: ieee802154: don't use devm_pinctrl_get_select_default() in probe

 drivers/bluetooth/bfusb.c          |    2 +
 drivers/bluetooth/btusb.c          |   34 +-
 drivers/net/ieee802154/at86rf230.c |   80 +-
 drivers/net/ieee802154/cc2520.c    |   27 +-
 drivers/net/ieee802154/mrf24j40.c  |    6 +-
 include/net/bluetooth/hci.h        |   53 ++
 include/net/bluetooth/hci_core.h   |   35 +-
 include/net/bluetooth/l2cap.h      |    1 +
 include/net/bluetooth/rfcomm.h     |    2 -
 include/net/cfg802154.h            |   10 +-
 include/net/ieee802154_netdev.h    |    4 +-
 include/net/mac802154.h            |    5 +-
 include/net/nl802154.h             |   45 +-
 net/bluetooth/Kconfig              |   27 +
 net/bluetooth/Makefile             |    4 +-
 net/bluetooth/af_bluetooth.c       |    6 +
 net/bluetooth/hci_conn.c           |    4 +
 net/bluetooth/hci_core.c           | 1640 +----------------------------------
 net/bluetooth/hci_debugfs.c        | 1076 +++++++++++++++++++++++
 net/bluetooth/hci_debugfs.h        |   26 +
 net/bluetooth/hci_event.c          |   71 +-
 net/bluetooth/hci_request.c        |  555 ++++++++++++
 net/bluetooth/hci_request.h        |   54 ++
 net/bluetooth/mgmt.c               |  265 ++++--
 net/bluetooth/rfcomm/core.c        |    4 +-
 net/bluetooth/selftest.c           |  244 ++++++
 net/bluetooth/selftest.h           |   45 +
 net/bluetooth/smp.c                |  335 ++++++-
 net/bluetooth/smp.h                |   13 +
 net/ieee802154/nl-mac.c            |    4 +-
 net/ieee802154/nl802154.c          |   46 +-
 net/ieee802154/rdev-ops.h          |    7 +
 net/ieee802154/sysfs.c             |    2 +-
 net/mac802154/cfg.c                |   21 +
 net/mac802154/driver-ops.h         |    5 +-
 net/mac802154/iface.c              |  100 ++-
 net/mac802154/mac_cmd.c            |    6 +-
 37 files changed, 3084 insertions(+), 1780 deletions(-)
 create mode 100644 net/bluetooth/hci_debugfs.c
 create mode 100644 net/bluetooth/hci_debugfs.h
 create mode 100644 net/bluetooth/hci_request.c
 create mode 100644 net/bluetooth/hci_request.h
 create mode 100644 net/bluetooth/selftest.c
 create mode 100644 net/bluetooth/selftest.h


--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUo6T9AAoJECQj9vv5qNQSHykQAKlS5/+Ia/ca6JlDj+hJVnge
+u3RnoI+x7VfXw/k2HsqnBQPd+r/RdiTfxU5e4ynuvIZvyg6rNsnJiNl3NA0AeKz
CCUbMJEGEqUIvTWzb5roADJtB0QsBrJYwv9cI8vqF3ZTmCIKL2mddgaQ+FSNG3eE
Qzn3fnOb1LyfuyyHwRzD9hqlizmvhie9L0Tp0cp56O3UDR8E9Wlb+44iuoatuCG4
KSLAOP/UoGlgpMxMysAZgQcWoMXYrAg86YAAaAnxhgd1MHkt2AMIwTWLKX+aG8fv
h/spIkA1Q3UlDmUTvLbTEjtokNdwotWYcIXJTGJtbam01b6+x7tvFhvev9VhWeVB
gjBfOjz4T5IKBg25gVkHclOVF+YvNR+1K+U+JQPEUCG6FuS8vYDOHs7aYNMxYDdE
XQfNNPuBz7wG2DXU0VFySTYWlflt6IU1nn/dyU+f8I965YxXeH4MIpYrjvEypQAQ
eeH2Wl+LcTyMC4GC9q6EqUlsdl/pfPXyTXV9AdqcJwFL4NtF0pcBzdJ7gM8ps0H5
q11gnRTo4JYspHLTC+qXDyUP+ddr6fk5B/56et6rTQjm1Ky/rdMOweZUQVfoLw7k
Yshi0g3M5cvjwYHN2xwn3mgAQfdmS/U32G+pv+PPTVbpYoNBTZ2PkucpbPoaB0JZ
/hBsnyZ+ZS8LeO/2wg2P
=vZpi
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
