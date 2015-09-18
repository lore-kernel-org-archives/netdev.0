From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-09-18
Date: Fri, 18 Sep 2015 13:54:55 +0300
Message-ID: <20150918105455.GA12472@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:34465 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbbIRKzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 06:55:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's the first bluetooth-next pull request for the 4.4 kernel:

 - ieee802154 cleanups & fixes
 - debugfs support for the at86rf230 driver
 - Support for quirky (seemingly counterfeit) CSR Bluetooth controllers
 - Power management and device config improvements for Intel controllers
 - Fix for devices with incorrect advertising data length
 - Fix for closing HCI user channel socket

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 37d2dbcdcca88e392009d7cbe8617d5af0ebcb32:

  net: fix cdc-phonet.c dependency and build error (2015-09-16 11:51:19 -07=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 6818375e974aa8659c3d2b1bf4b660a2a7929077:

  Bluetooth: Fix reporting incorrect EIR in device found mgmt event (2015-0=
9-18 09:53:20 +0200)

----------------------------------------------------------------
Alexander Aring (22):
      ieee802154: 6lowpan: change dev vars to wdev and ldev
      ieee802154: 6lowpan: register packet layer while open
      ieee802154: 6lowpan: remove check on null
      ieee802154: 6lowpan: remove set to zero
      ieee802154: 6lowpan: remove EXPORT_SYMBOL
      ieee802154: 6lowpan: change if lowpan dev is running
      ieee802154: 6lowpan: cleanup pull of iphc bytes
      ieee802154: 6lowpan: trivial checks at first
      ieee802154: 6lowpan: earlier skb->dev switch
      ieee820154: 6lowpan: dispatch evaluation rework
      ieee802154: 6lowpan: add generic lowpan header check
      ieee802154: 6lowpan: add handler for all dispatch values
      ieee802154: 6lowpan: add check for reserved dispatch
      ieee802154: 6lowpan: check on valid 802.15.4 frame
      ieee802154: 6lowpan: remove packet type to host
      ieee802154: 6lowpan: remove tx full-size calc workaround
      ieee802154: 6lowpan: fix drop return value
      at86rf230: change trac status check behaviour
      at86rf230: interrupt tx with force trx_off
      at86rf230: add debugfs support
      at86rf230: detailed edge triggered irq warning
      atusb: add handling for different chipnames

Frederic Danis (3):
      Bluetooth: hci_bcm: Replace spinlock by mutex
      Bluetooth: hci_bcm: Use bt_dev logging helpers
      Bluetooth: hci_bcm: Add wake-up capability

Johan Hedberg (2):
      Bluetooth: Use BROKEN_STORED_LINK_KEY quirk for HCI_Read_Stored_Link_=
Key
      Bluetooth: btusb: Detect new kind of counterfeit CSR controllers

Kieran Bingham (1):
      Bluetooth: btmrvl: skb resource leak, and double free.

Kuba Pawlak (1):
      Bluetooth: Remove SCO fragments on connection close

Loic Poulain (15):
      Bluetooth: Add bt_dev logging macros
      Bluetooth: hci_intel: Retrieve host-wake IRQ
      Bluetooth: hci_intel: Introduce LPM support
      Bluetooth: hci_intel: Use bt_dev logging helpers
      Bluetooth: hci_intel: Replace spinlock with mutex
      Bluetooth: hci_intel: Implement LPM suspend/resume
      Bluetooth: hci_intel: Add PM support
      Bluetooth: hci_intel: Add runtime PM support
      Bluetooth: hci_intel: Show error in case of invalid LPM packet size
      Bluetooth: hci_intel: Fix warnings due to unused lpm functions
      Bluetooth: btintel: Add Device Configuration support
      Bluetooth: hci_intel: Add Device configuration
      Bluetooth: btusb: Use btintel_load_ddc_config for device config
      Bluetooth: hci_intel: Give priority to LPM packets
      Bluetooth: hci_intel: Enable IRQ wake capability

Marcel Holtmann (2):
      Bluetooth: hci_qca: Fix a few tab vs spaces issues
      Bluetooth: Fix typo in smp_ah comment for hash function

Prasanna Karthik (2):
      Bluetooth: bt3c_cs: clean up obsolete functions
      Bluetooth: hci_qca: Coding style clean up

Simon Fels (1):
      Bluetooth: close HCI device when user channel socket gets closed

Stefan Schmidt (3):
      ieee802154: 6lowpan: use correct ESC value for dispatch
      ieee802154: docs: fix project name to linux-wpan as well as some typos
      ieee802154: af_ieee802154: fix typo in comment.

Szymon Janc (2):
      Bluetooth: Add BT_ERR_RATELIMITED
      Bluetooth: Fix reporting incorrect EIR in device found mgmt event

Vincent Stehl=E9 (1):
      Bluetooth: btintel: fix warning

 Documentation/networking/ieee802154.txt |   8 +-
 drivers/bluetooth/bt3c_cs.c             |  12 +-
 drivers/bluetooth/btintel.c             |  46 +++
 drivers/bluetooth/btintel.h             |  10 +-
 drivers/bluetooth/btmrvl_main.c         |  14 -
 drivers/bluetooth/btusb.c               |  51 +--
 drivers/bluetooth/hci_bcm.c             | 222 ++++++++---
 drivers/bluetooth/hci_intel.c           | 590 ++++++++++++++++++++++++++--=
--
 drivers/bluetooth/hci_qca.c             |  12 +-
 drivers/net/ieee802154/Kconfig          |   7 +
 drivers/net/ieee802154/at86rf230.c      | 195 +++++++---
 drivers/net/ieee802154/at86rf230.h      |   8 +
 drivers/net/ieee802154/atusb.c          |  13 +-
 include/linux/ieee802154.h              |  25 ++
 include/net/6lowpan.h                   | 144 ++------
 include/net/af_ieee802154.h             |   2 +-
 include/net/bluetooth/bluetooth.h       |  11 +
 include/net/bluetooth/hci_core.h        |   1 +
 include/net/mac802154.h                 |  15 +
 net/6lowpan/iphc.c                      |  13 +-
 net/6lowpan/nhc_udp.c                   |  13 +-
 net/bluetooth/hci_core.c                |   5 +-
 net/bluetooth/hci_event.c               |  21 ++
 net/bluetooth/hci_sock.c                |  11 +-
 net/bluetooth/lib.c                     |  16 +
 net/bluetooth/smp.c                     |   2 +-
 net/ieee802154/6lowpan/6lowpan_i.h      |  14 +-
 net/ieee802154/6lowpan/core.c           | 116 +++---
 net/ieee802154/6lowpan/reassembly.c     | 157 +++++---
 net/ieee802154/6lowpan/rx.c             | 352 ++++++++++++++----
 net/ieee802154/6lowpan/tx.c             |  51 +--
 31 files changed, 1605 insertions(+), 552 deletions(-)

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV++1/AAoJECQj9vv5qNQSK60P/iIwLjEcUkqSBGcgpJUwUT+H
DrfR4ukwf12eY67laPjwln+BaUy3b3u0M/FT65PwL/BhedRucejI/1SrgT0o35Rs
OxKmKEvHVjK/DeLv1L1UeHIeEyQ72ucygcGapo9OAkhzdkDqc+rUpNG+wCNvcBhK
Afb0NsAKM+6W7KbtKfHJOOwKn0EOvEXV2F1v5ptRaEcOhcZVnZdtUn7Xn89Yv1ar
k2v6QNOia0UGTfiolDTM7cctml997UzjKN4XkozyVHRrMKJ2bcaUfgTCOu6n9hi0
HMdPDWHeVO+i1yoDC+g3Hq3ZzAT0/5NqdEsbpyorkCC2W/z8+8EzU2NtWqkUJGKj
4znIklb1lNWodZIUGu1/TsUPQmM607rIxkehOX8E0Y+4AteIoZMqf+VnMZIC6HdK
63MzwxK3UR6Hwptx+GkMYSDEXKaU6podkJHLFOGC36uV1YBuLQBE2hiswVwug78a
L4XtcwZ+aTTo9DP5BwrYmrekLHOIEd1sOfDbSjpF2qxzFqaww90BZwtsfabCJWxg
p0J6L2s6f+OErqJj7VSmwzn4o22PwPXK/o8za2Dt+sQobLNahR4WDR9gkHtGDuk2
V7weEFBHA9ZEOcs0G03XpgqzB17haj2pHnmkLhFyOqjGrVs1c2dMDr4AUR9Rs/kN
eKcDtKazMrS9Nt9FpPAI
=3WDr
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
