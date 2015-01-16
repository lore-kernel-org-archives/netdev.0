From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-01-16
Date: Fri, 16 Jan 2015 13:33:01 +0200
Message-ID: <20150116113301.GA3818@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:55238 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbbAPLdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 06:33:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are some more bluetooth & ieee802154 patches intended for 3.20:

 - Refactoring & cleanups of ieee802154 & 6lowpan code
 - Various fixes to the btmrvl driver
 - Fixes for Bluetooth Low Energy Privacy feature handling
 - Added build-time sanity checks for sockaddr sizes
 - Fixes for Security Manager registration on LE-only controllers
 - Refactoring of broken inquiry mode handling to a generic quirk

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit e8768f971558019ed83eee8210375cd2143deef2:

  net: skbuff: don't zero tc members when freeing skb (2015-01-02 16:04:29 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 0026b6551b51a9520b912f41b8d447b89a825f5a:

  Bluetooth: Remove unused function (2015-01-16 13:06:38 +0200)

----------------------------------------------------------------
Alexander Aring (13):
      ieee802154: handle socket functionality as module
      ieee802154: socket: change module name
      ieee802154: socket: put handling into one file
      ieee802154: socket: fix checkpatch issue
      ieee802154: rename af_ieee802154.c to socket.c
      ieee802154: handle config as menuconfig
      mac802154: fix kbuild test robot warning
      ieee802154: create 6lowpan sub-directory
      ieee802154: 6lowpan: rename internal header
      ieee802154: 6lowpan: move receive functionality
      ieee802154: 6lowpan: move transmit functionality
      ieee802154: 6lowpan: rename to core
      ieee802154: 6lowpan: fix Makefile entry

Amitkumar Karwar (6):
      Bluetooth: btmrvl: fix race issue while stopping main thread
      Bluetooth: btmrvl: error path handling in setup handler
      Bluetooth: btmrvl: add surprise_removed flag
      bluetooth: btmrvl: increase the priority of firmware download message
      Bluetooth: btmrvl: use msecs_to_jiffies within macro definition
      Bluetooth: btmrvl: fix card reset and suspend race issue

Gowtham Anandha Babu (1):
      Bluetooth: Remove dead code

Johan Hedberg (3):
      Bluetooth: Fix valid Identity Address check
      Bluetooth: Add helpers for src/dst bdaddr type conversion
      Bluetooth: Fix lookup of fixed channels by local bdaddr

Jukka Rissanen (1):
      Bluetooth: 6lowpan: Remove PSM setting code

Marcel Holtmann (32):
      Bluetooth: Introduce force_bredr_smp debugfs option for testing
      Bluetooth: Remove broken force_lesc_support debugfs option
      Bluetooth: Remove no longer needed force_sc_support debugfs option
      Bluetooth: Fix scope of sc_only_mode debugfs entry
      Bluetooth: Fix for a leftover debug of pairing credentials
      Bluetooth: Fix SMP channel registration for unconfigured controllers
      Bluetooth: Fix issue with Roper Class 1 Bluetooth Dongle
      Bluetooth: Remove dead code for manufacturer inquiry mode quirks
      Bluetooth: Introduce HCI_QUIRK_FIXUP_INQUIRY_MODE option
      Bluetooth: Use HCI_QUIRK_FIXUP_INQUIRY_MODE for Silicon Wave devices
      Bluetooth: Add opcode parameter to hci_req_complete_t callback
      Bluetooth: Add BUILD_BUG_ON for size of struct sockaddr_hci
      Bluetooth: Add BUILD_BUG_ON for size of struct sockaddr_l2
      Bluetooth: Add BUILD_BUG_ON for size of struct sockaddr_rc
      Bluetooth: Add BUILD_BUG_ON for size of struct sockaddr_sco
      Bluetooth: Simplify packet copy in hci_send_to_monitor function
      Bluetooth: Create generic queue_monitor_skb helper function
      Bluetooth: Replace send_monitor_event with queue_monitor_skb
      Bluetooth: Add defintions for HCI Read Stored Link Key command
      Bluetooth: Handle command complete event for HCI Read Stored Link Keys
      Bluetooth: Read stored link key information when powering on controller
      Bluetooth: Add missing response structure for HCI Delete Stored Link Key
      Bluetooth: Process result of HCI Delete Stored Link Key command
      Bluetooth: btusb: Add internal recv_event callback for event processing
      Bluetooth: Move Delete Stored Link Key to 4th phase of initialization
      Bluetooth: Use %llu for printing duration details of selftests
      Bluetooth: Show device address type for L2CAP debugfs entries
      Bluetooth: Fix issue with switching BR/EDR back on when disabled
      Bluetooth: Fix LE SMP channel source address and source address type
      Bluetooth: Don't register any SMP channel if LE is not supported
      Bluetooth: Bind the SMP channel registration to management power state
      Bluetooth: Add paranoid check for existing LE and BR/EDR SMP channels

Rickard Strandqvist (1):
      Bluetooth: Remove unused function

 drivers/bluetooth/btmrvl_drv.h            |    5 +-
 drivers/bluetooth/btmrvl_main.c           |   32 +-
 drivers/bluetooth/btmrvl_sdio.c           |    6 +-
 drivers/bluetooth/btusb.c                 |   15 +-
 include/net/bluetooth/bluetooth.h         |    2 +-
 include/net/bluetooth/hci.h               |   30 +-
 include/net/bluetooth/hci_core.h          |    6 +-
 net/bluetooth/6lowpan.c                   |   66 +-
 net/bluetooth/cmtp/capi.c                 |    6 -
 net/bluetooth/hci_conn.c                  |   17 +-
 net/bluetooth/hci_core.c                  |  128 ++--
 net/bluetooth/hci_debugfs.c               |  143 +---
 net/bluetooth/hci_event.c                 |   42 ++
 net/bluetooth/hci_request.c               |    3 +-
 net/bluetooth/hci_sock.c                  |  107 ++-
 net/bluetooth/l2cap_core.c                |   55 +-
 net/bluetooth/l2cap_sock.c                |    2 +
 net/bluetooth/mgmt.c                      |   79 +-
 net/bluetooth/rfcomm/sock.c               |    2 +
 net/bluetooth/sco.c                       |    2 +
 net/bluetooth/selftest.c                  |    2 +-
 net/bluetooth/smp.c                       |  133 +++-
 net/ieee802154/6lowpan/6lowpan_i.h        |   72 ++
 net/ieee802154/6lowpan/Kconfig            |    5 +
 net/ieee802154/6lowpan/Makefile           |    3 +
 net/ieee802154/6lowpan/core.c             |  304 ++++++++
 net/ieee802154/{ => 6lowpan}/reassembly.c |    2 +-
 net/ieee802154/6lowpan/rx.c               |  171 +++++
 net/ieee802154/6lowpan/tx.c               |  271 +++++++
 net/ieee802154/6lowpan_rtnl.c             |  729 ------------------
 net/ieee802154/Kconfig                    |   18 +-
 net/ieee802154/Makefile                   |    8 +-
 net/ieee802154/af802154.h                 |   33 -
 net/ieee802154/af_ieee802154.c            |  369 ---------
 net/ieee802154/dgram.c                    |  549 --------------
 net/ieee802154/raw.c                      |  270 -------
 net/ieee802154/reassembly.h               |   41 -
 net/ieee802154/socket.c                   | 1125 ++++++++++++++++++++++++++++
 net/mac802154/cfg.c                       |    5 +-
 39 files changed, 2461 insertions(+), 2397 deletions(-)
 create mode 100644 net/ieee802154/6lowpan/6lowpan_i.h
 create mode 100644 net/ieee802154/6lowpan/Kconfig
 create mode 100644 net/ieee802154/6lowpan/Makefile
 create mode 100644 net/ieee802154/6lowpan/core.c
 rename net/ieee802154/{ => 6lowpan}/reassembly.c (99%)
 create mode 100644 net/ieee802154/6lowpan/rx.c
 create mode 100644 net/ieee802154/6lowpan/tx.c
 delete mode 100644 net/ieee802154/6lowpan_rtnl.c
 delete mode 100644 net/ieee802154/af802154.h
 delete mode 100644 net/ieee802154/af_ieee802154.c
 delete mode 100644 net/ieee802154/dgram.c
 delete mode 100644 net/ieee802154/raw.c
 delete mode 100644 net/ieee802154/reassembly.h
 create mode 100644 net/ieee802154/socket.c


--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUuPbtAAoJECQj9vv5qNQSFnoP/A3x4o2KaEqQYzzYM2hqxXnc
EWoL4q3SzbLVL9ERsLxa5HqWzFDW54PzYWJy5cmxzi/Ik/rnLq7qIUFgmEysR/CR
w5//IqcIVMvLCA4e5GQbkiSnuugELdrIDlKoUksO3xLK5buw7luLHXvGmxaOtOry
HW7b478jLVLE/mrItkmGnLAm2E5uALwzLHoyQ3UUgmmtYCT4q31kN+MS9mf/pkhe
5LO8vRXN5119mFurIf4KNMzji1VESs8eZgoICkHOvGqacL24TntOycaG0N0VyfFH
7hm9P77TDdPJ+Fw6UBlLSzODgm9DcSYzDV7xRoRaOhvGt3RS8M2h1mhzXn2eFIqd
KwbPY/JNvKwa8VE2vSa8aujgtGApUfGTzXerSRFExWwftS/dsZHdWGS3aY1yadO8
psrVdtZV4IoQ3wb2DXAnPLupFVQNTMmfyZzb/62NlnsjOt9V/f2lnicsw4EXuozK
W8vAea9MrJeZjZsyOAkDVsi2mqPxrasCxey9/jug/hImWZ27n7VygWotlL/Nwrqw
kbSeUXepHxHo8Zmp/F6CqIjRIrzfsL0fenSq+avz52A4kLyzaqm57Twi/GKBvH1z
jSjwjG+LFGJO3aYw1izZpynytWlE182/XunT4oMnArkwmBrIRRyFLAyf6bbLKItw
/Cbj8RxXDZBxUt+C7c25
=UeEw
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
