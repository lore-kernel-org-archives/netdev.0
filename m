From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-05-28
Date: Thu, 28 May 2015 12:31:43 +0300
Message-ID: <20150528093143.GA22996@t440s.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of patches intended for 4.2. The majority of the changes
are on the 802.15.4 side of things rather than Bluetooth related:

 - All sorts of cleanups & fixes to ieee802154 and related drivers
 - Rework of tx power support in ieee802154 and its drivers
 - Support for setting ieee802154 tx power through nl802154
 - New IDs for the btusb driver
 - Various cleanups & smaller fixes to btusb
 - New btrtl driver for Realtec devices
 - Fix suspend/resume for Realtek devices

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit f0b5e8a42f37a880b8467e59dc814f4f21581d3d:

  net: kill useless net_*_ingress_queue() definitions when NET_CLS_ACT is unset (2015-05-13 15:44:28 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to b5a61c306b0dddb28e3a3ab5d782c73e5f665497:

  atusb: add support for at86rf230 (2015-05-27 19:29:54 +0200)

----------------------------------------------------------------
Alexander Aring (42):
      nl802154: cleanup invalid argument handling
      ieee802154: move validation check out of softmac
      ieee802154: change transmit power to s32
      ieee802154: change transmit power to mbm
      ieee802154: change cca ed level to mbm
      ieee802154: introduce wpan_phy_supported
      ieee802154: add several phy supported handling
      mac802154: check for really changes
      mac802154: remove check if operation is supported
      cfg802154: introduce wpan phy flags
      ieee802154: add iftypes capability
      at86rf230: set cca_modes supported flags
      at86rf230: rework tx power support
      at86rf230: rework tx cca energy detection level
      at86rf230: add cca ed level reset value
      at86rf230: add reset states of tx power level
      nl802154: add support for dump phy capabilities
      at86rf230: fix callback for aret handling
      mac802154: tx: allow xmit complete from hard irq
      ieee802154: add support for atusb transceiver
      fakelb: creating two virtual phys per default
      fakelb: use list_for_each_entry_safe
      fakelb: rename fakelb_dev_priv to fakelb_phy
      fakelb: don't deliver when one phy
      fakelb: declare rwlock static
      fakelb: declare fakelb list static
      fakelb: move lock out of iteration
      fakelb: introduce fakelb ifup phys list
      fakelb: use own channel and page attributes
      fakelb: add virtual phy reset defaults
      fakelb: remove fakelb_hw_deliver
      fakelb: add support for async xmit handling
      fakelb: cleanup code
      at86rf230: add missing cca ed level values
      mac802154: fix hold rtnl while ioctl
      mac802154: remove pib lock
      mac802154: use atomic ops for sequence incrementation
      mac802154: remove mib lock
      nl802154: fix cca mode wpan phy flag
      nl802154: add support for cca ed level info
      nl802154: add support to set cca ed level
      atusb: add support for at86rf230

Arnd Bergmann (1):
      mac802154: select CRYPTO when needed

Carlo Caione (1):
      Bluetooth: btrtl: Create separate module for Realtek BT driver

Chan-yeol Park (1):
      Bluetooth: btusb: Support QCA61x4 ROME v2.0

Daniel Drake (1):
      Bluetooth: btusb: fix Realtek suspend/resume

Florian Grandel (1):
      Bluetooth: mgmt: fix typos

Frederic Danis (4):
      Bluetooth: Fix calls to __hci_cmd_sync()
      Bluetooth: btusb: Fix calls to __hci_cmd_sync()
      Bluetooth: btintel: Fix calls to __hci_cmd_sync()
      Bluetooth: btbcm: Fix calls to __hci_cmd_sync()

Johan Hedberg (1):
      Bluetooth: Add debug logs for legacy SMP crypto functions

Lennert Buytenhek (7):
      mac802154: Avoid rtnl deadlock in mac802154_wpan_ioctl().
      ieee802154 socket: Return EMSGSIZE from raw_sendmsg() if packet too big.
      Documentation/networking/ieee802154.txt: fix various inaccuracies.
      ieee802154: Remove ieee802154_reduced_mlme_ops references.
      ieee802154: Remove 802.15.4/6LoWPAN checks for interface MTU.
      ieee802154 socket: No need to check for ARPHRD_IEEE802154 in raw_bind().
      mac802154: mac802154_mlme_start_req() optimisation.

Leo Yan (1):
      Bluetooth: btwilink: remove DEBUG define

Martin Townsend (1):
      mac802154: fakelb: Fix potential NULL pointer dereference.

Shailendra Verma (2):
      Bluetooth: btusb: Change 1 to true in bool type variable assignment
      Bluetooth: hci_uart: Change 1 to true for bool type variables assignments

Stefan Schmidt (3):
      ieee802154/atusb: Warn about outdated device firmware.
      ieee802154/atusb: Mark driver as AACK enabled in hardware.
      ieee802154/atusb: Set default ed level to 0xbe like the rest of these drivers

Varka Bhadram (2):
      ieee802154: add set transmit power support
      ieee802154: fix typo for file name

Xinming Hu (1):
      Bluetooth: btmrvl: fix compilation warning

 Documentation/networking/ieee802154.txt |  32 +-
 drivers/bluetooth/Kconfig               |  15 +
 drivers/bluetooth/Makefile              |   1 +
 drivers/bluetooth/btbcm.c               |   6 -
 drivers/bluetooth/btintel.c             |   6 -
 drivers/bluetooth/btmrvl_sdio.c         |   2 +-
 drivers/bluetooth/btrtl.c               | 390 +++++++++++++++++
 drivers/bluetooth/btrtl.h               |  52 +++
 drivers/bluetooth/btusb.c               | 434 +------------------
 drivers/bluetooth/btwilink.c            |   2 +-
 drivers/bluetooth/hci_bcsp.c            |   4 +-
 drivers/net/ieee802154/Kconfig          |  10 +
 drivers/net/ieee802154/Makefile         |   1 +
 drivers/net/ieee802154/at86rf230.c      | 376 +++++++----------
 drivers/net/ieee802154/at86rf230.h      | 220 ++++++++++
 drivers/net/ieee802154/atusb.c          | 699 +++++++++++++++++++++++++++++++
 drivers/net/ieee802154/atusb.h          |  84 ++++
 drivers/net/ieee802154/cc2520.c         |   2 +-
 drivers/net/ieee802154/fakelb.c         | 209 ++++-----
 drivers/net/ieee802154/mrf24j40.c       |   2 +-
 include/net/cfg802154.h                 |  70 +++-
 include/net/ieee802154_netdev.h         |  16 -
 include/net/mac802154.h                 |  38 +-
 include/net/nl802154.h                  |  79 ++++
 net/bluetooth/hci_core.c                |   5 -
 net/bluetooth/mgmt.c                    |   6 +-
 net/bluetooth/smp.c                     |  20 +-
 net/ieee802154/6lowpan/core.c           |  28 --
 net/ieee802154/6lowpan/tx.c             |   2 +-
 net/ieee802154/core.c                   |   2 -
 net/ieee802154/nl-mac.c                 |  39 +-
 net/ieee802154/nl-phy.c                 |  10 +-
 net/ieee802154/nl802154.c               | 276 ++++++++++--
 net/ieee802154/rdev-ops.h               |  23 +
 net/ieee802154/socket.c                 |  20 +-
 net/ieee802154/trace.h                  |  32 +-
 net/mac802154/Kconfig                   |   1 +
 net/mac802154/cfg.c                     | 101 +++--
 net/mac802154/driver-ops.h              |   8 +-
 net/mac802154/ieee802154_i.h            |   7 -
 net/mac802154/iface.c                   |  30 +-
 net/mac802154/mac_cmd.c                 |  42 +-
 net/mac802154/main.c                    |  32 ++
 net/mac802154/mib.c                     |  63 +--
 net/mac802154/rx.c                      |   5 -
 net/mac802154/util.c                    |   5 +-
 46 files changed, 2374 insertions(+), 1133 deletions(-)
 create mode 100644 drivers/bluetooth/btrtl.c
 create mode 100644 drivers/bluetooth/btrtl.h
 create mode 100644 drivers/net/ieee802154/at86rf230.h
 create mode 100644 drivers/net/ieee802154/atusb.c
 create mode 100644 drivers/net/ieee802154/atusb.h

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVZuB+AAoJECQj9vv5qNQSjQMP/iRENi04HiYZioU+E/8PH0C3
5Y5bpDq46/qOge+pLeSWVofKxwCk5XZNlrvnI0DrR+7wiGbWBY/fvkoMXnrZwkYz
gtYjslTXfbYaZ2v6hzZj4eWV6oNRqTaubZHhkCZyTHanVMYOHbeaZyrIYCl1gtYt
IZ+h+nG+w0kv5AGoAH75qoKcdNzDOAcHSN8STT2ZZEazmWquN20B7pl2R2WWF7ph
xfRY6C+7Ic/eQv2xeKBpVIX++iWiyYfnNN72rPgXbJq6Yos/etHm4HaMyoZHqsSN
vgNqero7GBp/Fby7DrIwOSA6L0gNfiNI6CHoH2svQr0SGA0mEHhHS8AeFPd7AmFl
EhHGytXVcFNI8480ImHtVFj4CX/YTQtrESX6ws7itjzytOCt1FBJaPl2EpGqugOg
2r8/OC93IDFXwbeQ8inFts8Fboo89XBj08DVXNNhNxH5TnUHHRhiljFfRWJK3sIa
bFm4GpFDjrwYQfPAy7dTKsUE9oKQ1Nbr1FWnqIokk9eq00qaD4yIMEXXRcuUU8rA
Q2T/0oIZnpVj3r8y7T55ixyxo6chla4z6r4yhyCgrEtCWqQRnZxKlXxXhI/GqyME
LniYhHgl83oGvc0AKyERCUcc1LPNp8b0i5w9J0WkGuq7veKpJ+MxfqapLsjN3nSY
S7F/EPPhe+0HZm+7ehM3
=YRcj
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
