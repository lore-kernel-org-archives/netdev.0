From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-07-30
Date: Thu, 30 Jul 2015 20:34:48 +0300
Message-ID: <20150730173448.GA13424@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of Bluetooth & 802.15.4 patches intended for the 4.3 kernel.

 - Cleanups & fixes to mac802154
 - Refactoring of Intel Bluetooth HCI driver
 - Various coding style fixes to Bluetooth HCI drivers
 - Support for Intel Lightning Peak Bluetooth devices
 - Generic class code in interface descriptor in btusb to match more HW
 - Refactoring of Bluetooth HS code together with a new config option
 - Support for BCM4330B1 Broadcom UART controller

Let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 045a0fa0c5f5ea0f16c009f924ea579634afbba8:

  ip_tunnel: Call ip_tunnel_core_init() from inet_init() (2015-07-23 01:28:21 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 5857d1dbae7d5bf4219efc39996ad002362a2951:

  Bluetooth: 6lowpan: Fix possible race (2015-07-30 14:11:36 +0200)

----------------------------------------------------------------
Alexander Aring (6):
      mac802154: add llsec address update workaround
      6lowpan: add request for ipv6 module
      mac802154: util: add stop_device utility function
      mac802154: cfg: add suspend and resume callbacks
      at86rf230: remove hrtimer on 1 usec delay
      Bluetooth: 6lowpan: Fix possible race

Antonio Borneo (1):
      net: ieee802154: Remove redundant spi driver bus initialization

Arron Wang (5):
      Bluetooth: Add BT_HS config option
      Bluetooth: Move high speed specific event under BT_HS option
      Bluetooth: Move get info completed callback to a2mp.c
      Bluetooth: Move amp assoc read/write completed callback to amp.c
      Bluetooth: Move create/accept phy link completed callback to amp.c

Christophe JAILLET (1):
      Bluetooth: cmtp: Do not use list_for_each_safe when not needed

Daniel Drake (1):
      Bluetooth: btusb: match generic class code in interface descriptor

Dean Jenkins (5):
      Bluetooth: L2CAP ERTM shutdown protect sk and chan
      Bluetooth: Make __l2cap_wait_ack more efficient
      Bluetooth: Add BT_DBG to l2cap_sock_shutdown()
      Bluetooth: __l2cap_wait_ack() use msecs_to_jiffies()
      Bluetooth: __l2cap_wait_ack() add defensive timeout

Frederic Danis (1):
      Bluetooth: btbcm: Add BCM4330B1 UART device

Jakub Pawlowski (1):
      Bluetooth: Move IRK checking logic in preparation to new connect method

Lennert Buytenhek (1):
      mac802154: Fix memory corruption with global deferred transmit state.

Loic Poulain (1):
      Bluetooth: hci_uart: Add basic support for Intel Lightning Peak devices

Marcel Holtmann (5):
      Bluetooth: btintel: Add generic function for handling hardware errors
      Bluetooth: btusb: Use hardware error handler from Intel module
      Bluetooth: hci_uart: Add Intel address configuration support
      Bluetooth: btintel: Create common Intel Secure Send function
      Bluetooth: btintel: Create common function for Intel version info

Prasanna Karthik (7):
      Bluetooth: dtl1_cs: Fix coding style -- clean up
      Bluetooth: bfusb: Coding style fix reported by coccinelle
      Bluetooth: dtl1_cs: Fixed coding style
      Bluetooth: bt3c_cs: Fix coding style
      Bluetooth: btmrvl: Coding style Fix for btmrvl header
      Bluetooth: hci_ldisc: Cleaned up coding style warnings
      Bluetooth: hci_h5: Cleaned up coding style warnings

Seungyoun Ju (1):
      Bluetooth: hci_check_conn_params() check proper range

Varka Bhadram (5):
      mac802154: use WARN_ON() macro
      mac802154: remove unused macro
      cfg802154: add PM hooks
      mac802154: do not export ieee802154_rx()
      mac802154: fix ieee802154_rx handling

 drivers/bluetooth/Kconfig          |   1 +
 drivers/bluetooth/bfusb.c          |   2 +-
 drivers/bluetooth/bt3c_cs.c        |   2 +-
 drivers/bluetooth/btbcm.c          |   8 +-
 drivers/bluetooth/btintel.c        |  80 +++++
 drivers/bluetooth/btintel.h        |  19 ++
 drivers/bluetooth/btmrvl_drv.h     |   6 +-
 drivers/bluetooth/btusb.c          |  94 +-----
 drivers/bluetooth/dtl1_cs.c        |   6 +-
 drivers/bluetooth/hci_h5.c         |   2 +-
 drivers/bluetooth/hci_intel.c      | 561 ++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/hci_ldisc.c      |   8 +-
 drivers/bluetooth/hci_uart.h       |   5 +
 drivers/net/ieee802154/at86rf230.c |   4 +-
 drivers/net/ieee802154/cc2520.c    |   1 -
 drivers/net/ieee802154/mrf24j40.c  |   1 -
 include/net/bluetooth/hci_core.h   |   2 +-
 include/net/bluetooth/l2cap.h      |   2 +
 include/net/cfg802154.h            |   2 +
 include/net/mac802154.h            |  17 --
 net/6lowpan/iphc.c                 |   2 +
 net/bluetooth/6lowpan.c            |  23 +-
 net/bluetooth/Kconfig              |   5 +
 net/bluetooth/Makefile             |   3 +-
 net/bluetooth/a2mp.c               |  17 +-
 net/bluetooth/a2mp.h               |  19 ++
 net/bluetooth/amp.c                | 134 ++++++++-
 net/bluetooth/amp.h                |  14 +
 net/bluetooth/cmtp/capi.c          |   8 +-
 net/bluetooth/hci_core.c           |  11 -
 net/bluetooth/hci_event.c          | 157 ++--------
 net/bluetooth/l2cap_sock.c         |  41 ++-
 net/bluetooth/mgmt.c               |  23 ++
 net/ieee802154/rdev-ops.h          |  20 ++
 net/ieee802154/sysfs.c             |  38 +++
 net/ieee802154/trace.h             |  22 ++
 net/mac802154/cfg.c                |  54 +++-
 net/mac802154/ieee802154_i.h       |  11 +-
 net/mac802154/iface.c              |  14 +-
 net/mac802154/main.c               |  10 +-
 net/mac802154/rx.c                 |  14 +-
 net/mac802154/tx.c                 |  27 +-
 net/mac802154/util.c               |   8 +
 43 files changed, 1167 insertions(+), 331 deletions(-)

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVumA4AAoJECQj9vv5qNQSxC4P/jic9dfU/Hk2KK82D/zpQHFD
MuD67/9KR5RBzOI4gipZ+5xn2BCEgapUmoZn+LaQwekglUnecqhrIIyxjOEapzAy
In/RHRe3v2Yzu6VLtJ9ax2R6e6IkkE8A+7V6kE5VP4WPiP3pBpeubhJmGFpXwjlS
1ufqdSHjgalVxmPac7eJviIWVhd5CzrHNCym35DX+VxF+AE/+hJHWb0JxsMX/3jZ
qy1oHpEbGF6Pmp31qJcLRoO5PJPhYmCuuSUYPJn1yabvAI1ApRIViwsj09EfHqpC
Q0Wl1jRyRhLvMVugo+1svrvrF6ZJb9mAnCtZuTfaM3Wiyz/Slz1mLzg+6HjjyZT6
zM29tGELz9FUyRN8i+uA0VD/EQe/2s0C7xXKYsToMchwkdlciS1ffJE5320qga6m
enzMlRH4R1D1N342e8btaiMDOADSQfBvl84pSYdCVzA6C8PFSS8lmwS2Am+HlDGV
IgLell9bxUEYtbqnIUsoHIYuvDbbpX8FwgAEeMx9nhZhpsD+cP5JnYawOY3IyeXe
FxZtxvds8tWlxQYs/56/CQk7Nv4H9lDqibXqmK1EG8K0KX7onPR8Jn7oh5fPMlkv
6huJ+8OTHXDI1gw9vukA6wDKtk6a6nntSbZKDIPTE5ce44IR0JmCkQlfV3CGK/vM
dIGfcQi8wRQSmn1unHD3
=033Y
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
