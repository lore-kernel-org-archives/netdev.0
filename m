From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-11-23
Date: Mon, 23 Nov 2015 15:55:33 +0200
Message-ID: <20151123135533.GA5257@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the first bluetooth-next pull request for the 4.5 kernel.

 - Add new Get Advertising Size Information management command
 - Add support for new system note message type on monitor channel
 - Refactor LE scan changes behind separate workqueue to avoid races
 - Fix issue with privacy feature when powering on adapter
 - Various minor fixes & cleanups here and there

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit d37b4c0a3647db23f41c5ee85701eec3544446d1:

  be2net: remove local variable 'status' (2015-11-18 15:21:41 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to dc4270c0cd880f1b28dd48f2a31d869d22da941e:

  Bluetooth: Increment management interface revision (2015-11-23 14:13:32 +0100)

----------------------------------------------------------------
Andrei Emeltchenko (2):
      Bluetooth: Fix mask for H5 header len
      Bluetooth: Use hex notation for mask

Andrzej Kaczmarek (1):
      Bluetooth: Fix powering on with privacy and advertising

Johan Hedberg (28):
      Bluetooth: Remove redundant setting to zero of bt_cb
      Bluetooth: Compress the size of struct hci_ctrl
      Bluetooth: Add clarifying comment why schedule_work is used
      Bluetooth: Remove unnecessary call to hci_update_background_scan
      Bluetooth: Move synchronous request handling into hci_request.c
      Bluetooth: Add 'sync' specifier to synchronous request APIs
      Bluetooth: Add stubs for synchronous HCI request functionality
      Bluetooth: Run all background scan updates through req_workqueue
      Bluetooth: Don't wait for HCI in Add/Remove Device
      Bluetooth: Add HCI status return parameter to hci_req_sync()
      Bluetooth: Use req_workqueue for explicit connect requests
      Bluetooth: Use req_workqueue for background scanning when powering on
      Bluetooth: Make __hci_update_background_scan private to hci_request.c
      Bluetooth: Move LE scan disable/restart behind req_workqueue
      Bluetooth: Add discovery type validity helper
      Bluetooth: Add error return value to hci_req_sync callback
      Bluetooth: Move Start Discovery to req_workqueue
      Bluetooth: Move Stop Discovery to req_workqueue
      Bluetooth: Fix BR/EDR Page Scan update with Add Device
      Bluetooth: Pass inquiry length to bredr_inquiry()
      Bluetooth: Simplify le_scan_disable_work()
      Bluetooth: Remove unnecessary le_scan_restart_work_complete() function
      Bluetooth: Fix specifying role for LE connections
      Bluetooth: Move check for ongoing connect earlier in hci_connect_le()
      Bluetooth: Remove conn_unfinished variable from hci_connect_le()
      Bluetooth: Simplify request cleanup code
      Bluetooth: Fix returning proper HCI status from __hci_req_sync
      Bluetooth: Increment management interface revision

Marcel Holtmann (14):
      Bluetooth: Move BR/EDR default events behind its features
      Bluetooth: Build LE event mask based on supported commands
      Bluetooth: Fix issue with HCI_QUIRK_FIXUP_INQUIRY_MODE and event mask
      Bluetooth: Make LE only events conditional on supported commands
      Bluetooth: Add hci_skb_* helper wrappers for bt_cb(skb) access
      Bluetooth: Use new hci_skb_pkt_* wrappers for core packet handling
      Bluetooth: Use new hci_skb_pkt_* wrappers for drivers
      Bluetooth: Add missing hci_skb_opcode for raw socket commands
      Bluetooth: Fix casting coding style within HCI sockets
      Bluetooth: Add support for sending system notes to monitor channel
      Bluetooth: Add support for controller specific logging
      Bluetooth: Add instance range check for Add Advertising command
      Bluetooth: Simplify if statements in tlv_data_is_valid function
      Bluetooth: Add support for Get Advertising Size Information command

Markus Elfring (2):
      mac802154: Delete an unnecessary check before the function call "kfree_skb"
      Bluetooth: Delete an unnecessary check before the function call "kfree_skb"

Prasanna Karthik (3):
      Bluetooth: clean up af_bluetooth code
      Bluetooth: Clean up hci_core code
      Bluetooth: remove unneeded variable in l2cap_stream_rx

 drivers/bluetooth/bfusb.c         |   9 +-
 drivers/bluetooth/bluecard_cs.c   |  25 +-
 drivers/bluetooth/bpa10x.c        |   4 +-
 drivers/bluetooth/bt3c_cs.c       |  11 +-
 drivers/bluetooth/btmrvl_main.c   |   8 +-
 drivers/bluetooth/btmrvl_sdio.c   |   4 +-
 drivers/bluetooth/btsdio.c        |   6 +-
 drivers/bluetooth/btuart_cs.c     |  11 +-
 drivers/bluetooth/btusb.c         |  48 +--
 drivers/bluetooth/btwilink.c      |   8 +-
 drivers/bluetooth/dtl1_cs.c       |  11 +-
 drivers/bluetooth/hci_ath.c       |   6 +-
 drivers/bluetooth/hci_bcm.c       |   2 +-
 drivers/bluetooth/hci_bcsp.c      |  25 +-
 drivers/bluetooth/hci_h4.c        |  16 +-
 drivers/bluetooth/hci_h5.c        |  18 +-
 drivers/bluetooth/hci_intel.c     |  14 +-
 drivers/bluetooth/hci_ldisc.c     |   5 +-
 drivers/bluetooth/hci_ll.c        |   4 +-
 drivers/bluetooth/hci_qca.c       |   4 +-
 drivers/bluetooth/hci_vhci.c      |   8 +-
 include/net/bluetooth/bluetooth.h |  25 +-
 include/net/bluetooth/hci.h       |   3 +-
 include/net/bluetooth/hci_core.h  |  13 +-
 include/net/bluetooth/hci_mon.h   |   2 +
 include/net/bluetooth/hci_sock.h  |   1 +
 include/net/bluetooth/mgmt.h      |  13 +
 net/bluetooth/af_bluetooth.c      |  12 +-
 net/bluetooth/cmtp/core.c         |   3 +-
 net/bluetooth/hci_conn.c          | 103 ++----
 net/bluetooth/hci_core.c          | 576 ++++++++-----------------------
 net/bluetooth/hci_request.c       | 682 +++++++++++++++++++++++++++++++++++--
 net/bluetooth/hci_request.h       |  25 +-
 net/bluetooth/hci_sock.c          | 200 +++++++++--
 net/bluetooth/l2cap_core.c        |  19 +-
 net/bluetooth/mgmt.c              | 616 ++++++++++-----------------------
 net/mac802154/rx.c                |   3 +-
 37 files changed, 1378 insertions(+), 1165 deletions(-)

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWUxrVAAoJECQj9vv5qNQSY9kQALdkveKxwaQMRNMhk3FyrXI9
NoIB7OOiSpM/WkOji+rtofUi0y4GBUjDxjdgX8zbqS+HoZCKwreV5sIzTAvGekko
iuAEhp7EUbypLTNhsObz7GDnpM2p73bgm49YdZHABXT3Gfacg45OWda1vr2SG8K4
4Wj29VZSyzeq+Wb332h6yW0QI2VfrB0XLbatmfeUx6Z6A9+Jy+uU9jyGWSP4dkQu
WKOqTlU6OnA1PkU59mndLT6JZUtV1Q8ruECzE9oJxCCSU/9cGYGpS2XdIz1hb7QE
8QJQ5liG5IIz4YEg+d8YWSvJBr/QsXolSr/iWKnuMVoV5aoynSwbhzRFl5y1Y72N
hGEkPkGxwmu1lU8mRbW0ni/1E5IH/V62TEkCGD5w2r7gfnXNhCGLznzO9BwG+mg4
ByzQCOnoQtU0jMxy0fBiPcE82aaAQ8ycryGfDOz9rn/FyY3NyZ2tYmlrNG48+S8v
it6TWWVS6S0Aen2NxbxHtn+XkJAbjOggZS6AYt15DVBNmoAuU/Z+fxMS1jB+vx8v
W4zSc7KA5LXZqwErISaLvv4xvVW9tC6ON18SDqW/0kFsPfqfnFFWnyqLUsoPAWoV
x67X99f2ip8qyT3W83ohxTQKl5Gkz9D1ELmA0DQBzTRc4OXrGfAg+1T7eIcOdr/E
98wGe2GtCF1M+pqgMN+m
=CO4/
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
