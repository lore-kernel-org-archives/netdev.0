From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-07-13
Date: Wed, 13 Jul 2016 11:25:40 +0300
Message-ID: <20160713082540.GA3719@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34815 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbcGMI0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 04:26:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's our main bluetooth-next pull request for the 4.8 kernel:

 - Fixes and cleanups in 802.15.4 and 6LoWPAN code
 - Fix out of bounds issue in btmrvl driver
 - Fixes to Bluetooth socket recvmsg return values
 - Use crypto_cipher_encrypt_one() instead of crypto_skcipher
 - Cleanup of Bluetooth connection sysfs interface
 - New Authentication failure reson code for Disconnected mgmt event
 - New USB IDs for Atheros, Qualcomm and Intel Bluetooth controllers

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit a90a6e55f34f28190e4dc2a6a3660ef157827a8f:

  Merge tag 'mac80211-next-for-davem-2016-07-06' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next (2016-07-06 22:32:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 87510973d6e137c33552b3365b5afbd5be81c5dd:

  Bluetooth: Increment management interface revision (2016-07-13 10:02:52 +0200)

----------------------------------------------------------------
Alexander Aring (13):
      6lowpan: ndisc: fix double read unlock
      6lowpan: ndisc: add missing 802.15.4 only check
      nl802154: move PAD to right position
      ieee802154: add netns support
      ieee802154: allow netns create of lowpan interface
      ieee802154: add ieee802154_skb_dst_pan helper
      ieee802154: add ieee802154_skb_src_pan helper
      ieee802154: 6lowpan: fix intra pan id check
      ieee802154: fix skb get fc on big endian
      6lowpan: ndisc: set invalid unicast short addr to unspec
      atusb: don't change csma settings while set channel
      ieee802154: cleanup WARN_ON for fc fetch
      fakelb: allow to run as monitor

Andy Lutomirski (1):
      Bluetooth: Switch SMP to crypto_cipher_encrypt_one()

Denis Kenzior (2):
      Bluetooth: Fix bt_sock_recvmsg return value
      Bluetooth: Fix hci_sock_recvmsg return value

Dmitry Tunin (1):
      Bluetooth: Add support of 13d3:3490 AR3012 device

Johan Hedberg (1):
      Bluetooth: Increment management interface revision

Loic Poulain (1):
      Bluetooth: hci_intel: Remove LPM enabling from setup procedure

Marcel Holtmann (3):
      Bluetooth: Remove connection link attributes
      Bluetooth: Remove controller device attributes
      Bluetooth: Rename HCI_BREDR into HCI_PRIMARY

Ricky Liang (1):
      Bluetooth: btmrvl: fix slab-out-of-bounds access in btmrvl_sdio

Szymon Janc (1):
      Bluetooth: Add Authentication Failed reason to Disconnected Mgmt event

Tedd Ho-Jeong An (2):
      Bluetooth: Add support for Intel Bluetooth device 3168 [8087:0aa7]
      Bluetooth: Replace constant hw_variant from Intel Bluetooth firmware filename

Walter Mack (1):
      mrf24j40: avoid uninitialized byte in SPI transfer to radio.

Yvain THONNART (1):
      Bluetooth: btusb: add support for device 0489:e092

 drivers/bluetooth/ath3k.c         |   2 +
 drivers/bluetooth/btmrvl_main.c   |   2 +-
 drivers/bluetooth/btmrvl_sdio.c   |  14 ++---
 drivers/bluetooth/btsdio.c        |   2 +-
 drivers/bluetooth/btusb.c         |  18 ++++--
 drivers/bluetooth/hci_intel.c     |  28 +++------
 drivers/bluetooth/hci_ldisc.c     |   2 +-
 drivers/bluetooth/hci_vhci.c      |   6 +-
 drivers/net/ieee802154/atusb.c    |   6 +-
 drivers/net/ieee802154/fakelb.c   |   8 +++
 drivers/net/ieee802154/mrf24j40.c |   2 +
 include/linux/ieee802154.h        |  29 +++++++++
 include/net/bluetooth/hci.h       |   3 +-
 include/net/bluetooth/hci_core.h  |   1 +
 include/net/bluetooth/mgmt.h      |   1 +
 include/net/cfg802154.h           |  13 +++++
 include/net/mac802154.h           | 117 +++++++++++++++++++++++++++++++++++--
 include/net/nl802154.h            |   9 ++-
 net/6lowpan/ndisc.c               |  13 ++++-
 net/bluetooth/af_bluetooth.c      |   5 ++
 net/bluetooth/hci_conn.c          |   2 +-
 net/bluetooth/hci_core.c          |  28 +++++----
 net/bluetooth/hci_event.c         |  18 +++++-
 net/bluetooth/hci_sock.c          |   7 ++-
 net/bluetooth/hci_sysfs.c         |  99 -------------------------------
 net/bluetooth/l2cap_core.c        |   2 +-
 net/bluetooth/mgmt.c              |  18 +++---
 net/bluetooth/smp.c               |  67 +++++++++------------
 net/ieee802154/6lowpan/core.c     |   3 +-
 net/ieee802154/6lowpan/rx.c       |   2 +-
 net/ieee802154/core.c             |  70 +++++++++++++++++++++-
 net/ieee802154/core.h             |   2 +
 net/ieee802154/nl802154.c         |  54 +++++++++++++++--
 33 files changed, 423 insertions(+), 230 deletions(-)

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXhfsEAAoJECQj9vv5qNQSU/cP/i1Nm9sjyab8Ltf+UuluvCqp
bcdAZzbZaesvXWlHfdiWOKQnEsPk4XF3f0+HphZbwMnB6S19wiCf67uBjK5wORxa
eaRgfmkf8Xdi1P18Y1KXTt8qe6xCOr8W9WCVEknjwLYqJq/p5LmN3HUK13JmDdQq
cdNVyW3yeuH/esS1D0m8wVB2iMsrdTjMEkBZq7o2bYg7QnRT138/QMuHKlGpwsHi
CjJoAGivOe6i3y9HFqyG0WYtP4vN/Paf7tGHQ2wEf6DVN8ZjAJOEvIIuqw4TneZI
9gfBhR1pCMMrnCF8Fbdpj4cWHqRZvwzpOHkzfbrZ74fnywQAwLZ7aOFX6fV1Iuf6
mzFIw/JmsJiv5C2zShfTMane6/2NQltsLyFrxhn1EPHda/FAbZ/aF/mAPzZ05S+l
qLhS1XsVJRRXWlHnzceQpDwy3l0jT89/FfXOcTqhHiFuRz9x/dFWC31Ptmn+rREW
dtriiR+Wn55xGYy+O3cI8ELZD5KwmAAoC5lS/Ba8OgA6/GdtMyr4oqtHdhqbMUPL
cBp5tc9VmB6wGmBhQ/VRo1zHF5EH90Z/ExmJGcrDu4IvaSfuqBTG+InvvEp4iUeY
tbo8tZHLCtsa5pRN0lBGwKcb16OjojbWA7FWPgYRa0hwfY+aNVJhA0T8tklePVp9
yIwwmdcnWhpJknhh9uMT
=Gy/s
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
