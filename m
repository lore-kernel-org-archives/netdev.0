From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-12-11
Date: Fri, 11 Dec 2015 22:20:59 +0200
Message-ID: <20151211202059.GA19118@t440s.P-661HNU-F1>
References: <20151211201611.GA17376@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151211201611.GA17376-ae+CCJ+dGXjCW7GOcxkI+ioyn5ZhHHrn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

(resending since I forgot to sign the previous one)

Here's another set of Bluetooth & 802.15.4 patches for the 4.5 kernel:

 - 6LoWPAN debugfs support
 - New 802.15.4 driver for ADF7242 MAC IEEE802154
 - Initial code for 6LoWPAN Generic Header Compression (GHC) support
 - Refactor Bluetooth LE scan & advertising behind dedicated workqueue
 - Cleanups to Bluetooth H:5 HCI driver
 - Support for Toshiba Broadcom based Bluetooth controllers
 - Use continuous scanning when establishing Bluetooth LE connections

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit ad2c8c73d29702c3193f739390f6661f9a4ecad9:

  cgroup: fix sock_cgroup_data initialization on earlier compilers (2015-12-09 15:02:31 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 7302b9d90117496049dd4bfa28755f7c2ed55b27:

  ieee802154/adf7242: Driver for ADF7242 MAC IEEE802154 (2015-12-11 11:27:22 +0100)

----------------------------------------------------------------
Alexander Aring (4):
      6lowpan: add lowpan dev register helpers
      6lowpan: add debugfs support
      ipv6: add ipv6_addr_prefix_copy
      mac802154: tx: fix synced xmit deadlock

Andrei Emeltchenko (3):
      Bluetooth: Use hexadecimal notation for mask
      Bluetooth: Simplify setting Configuration Field
      Bluetooth: h5: Do not initialize Configuration field

Danny Schweizer (1):
      Bluetooth: Do not filter multicast addresses by default

Dmitry Tunin (1):
      Bluetooth: Add support of Toshiba Broadcom based devices

Johan Hedberg (19):
      Bluetooth: Run page scan updates through hdev->req_workqueue
      Bluetooth: Move __hci_update_background_scan up in hci_request.c
      Bluetooth: Move advertising instance management to hci_request.c
      Bluetooth: Move connectable changes to hdev->req_workqueue
      Bluetooth: Perform Class of Device changes through hdev->req_workqueue
      Bluetooth: Move discoverable changes to hdev->req_workqueue
      Bluetooth: Move discoverable timeout behind hdev->req_workqueue
      Bluetooth: HCI name update to hci_request.c
      Bluetooth: Move EIR update to hci_request.c
      Bluetooth: Move fast connectable code to hci_request.c
      Bluetooth: Perform HCI update for power on synchronously
      Bluetooth: Simplify read_adv_features code
      Bluetooth: Remove unnecessary HCI_ADVERTISING_INSTANCE flag
      Bluetooth: Fix updating wrong instance's scan_rsp data
      Bluetooth: Remove redundant check for req.cmd_q
      Bluetooth: Clean up advertising initialization in powered_update_hci()
      Bluetooth: Clean up current advertising instance tracking
      Bluetooth: Use continuous scanning when creating LE connections
      Bluetooth: Don't treat connection timeout as a failure

Loic Poulain (3):
      Bluetooth: hci_intel: Use shorter timeout for HCI commands
      Bluetooth: btintel: Add manufacturing enter/exit helpers
      Bluetooth: btintel: Create common Intel Version Read function

Markus Elfring (1):
      ieee802154-atusb: Delete an unnecessary check before the function call "kfree_skb"

Michael Hennerich (1):
      ieee802154/adf7242: Driver for ADF7242 MAC IEEE802154

Peter Hurley (1):
      Bluetooth: hci_ldisc: Remove dead code

Stefan Schmidt (7):
      6lowpan: clarify Kconfig entries for upcoming GHC support
      6lowpan: add nhc module for GHC hop-by-hopextension header detection
      6lowpan: add nhc module for GHC UDP detection
      6lowpan: add nhc module for GHC ICMPv6 detection
      6lowpan: add nhc module for GHC destination extension header detection
      6lowpan: add nhc module for GHC fragmentation extension header detection
      6lowpan: add nhc module for GHC routing extension header detection

Yichen Zhao (1):
      Bluetooth: Fix locking in bt_accept_dequeue after disconnection

 .../devicetree/bindings/net/ieee802154/adf7242.txt |   18 +
 MAINTAINERS                                        |    9 +
 drivers/bluetooth/btintel.c                        |  129 +-
 drivers/bluetooth/btintel.h                        |   19 +
 drivers/bluetooth/btusb.c                          |  138 +-
 drivers/bluetooth/hci_h5.c                         |   12 +-
 drivers/bluetooth/hci_intel.c                      |   52 +-
 drivers/bluetooth/hci_ldisc.c                      |    8 +-
 drivers/net/ieee802154/Kconfig                     |   11 +
 drivers/net/ieee802154/Makefile                    |    1 +
 drivers/net/ieee802154/adf7242.c                   | 1285 +++++++++++++++++++
 drivers/net/ieee802154/atusb.c                     |    3 +-
 include/net/6lowpan.h                              |   10 +-
 include/net/bluetooth/hci.h                        |    1 -
 include/net/bluetooth/hci_core.h                   |   18 +-
 include/net/ipv6.h                                 |   15 +
 net/6lowpan/6lowpan_i.h                            |   28 +
 net/6lowpan/Kconfig                                |   47 +-
 net/6lowpan/Makefile                               |    9 +
 net/6lowpan/core.c                                 |   59 +-
 net/6lowpan/debugfs.c                              |   53 +
 net/6lowpan/nhc_ghc_ext_dest.c                     |   27 +
 net/6lowpan/nhc_ghc_ext_frag.c                     |   28 +
 net/6lowpan/nhc_ghc_ext_hop.c                      |   27 +
 net/6lowpan/nhc_ghc_ext_route.c                    |   27 +
 net/6lowpan/nhc_ghc_icmpv6.c                       |   27 +
 net/6lowpan/nhc_ghc_udp.c                          |   27 +
 net/bluetooth/6lowpan.c                            |    8 +-
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/bnep/core.c                          |    7 +-
 net/bluetooth/hci_conn.c                           |   20 +-
 net/bluetooth/hci_core.c                           |   63 +-
 net/bluetooth/hci_event.c                          |    8 +-
 net/bluetooth/hci_request.c                        | 1233 ++++++++++++++++--
 net/bluetooth/hci_request.h                        |   28 +-
 net/bluetooth/mgmt.c                               | 1285 ++-----------------
 net/ieee802154/6lowpan/core.c                      |    6 +-
 net/mac802154/driver-ops.h                         |    3 -
 net/mac802154/tx.c                                 |    9 -
 39 files changed, 3174 insertions(+), 1586 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/adf7242.txt
 create mode 100644 drivers/net/ieee802154/adf7242.c
 create mode 100644 net/6lowpan/6lowpan_i.h
 create mode 100644 net/6lowpan/debugfs.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_dest.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_frag.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_hop.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_route.c
 create mode 100644 net/6lowpan/nhc_ghc_icmpv6.c
 create mode 100644 net/6lowpan/nhc_ghc_udp.c

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWazArAAoJECQj9vv5qNQStM8P/i5YOPasI+QyMe3YBexiPp0W
epj9ktEmFnDfHP/4djvjEGc1skialvPESFxsYWcUpeKYK2E6/m5kYKXtgU/iRuoN
dO6FpInQpnxyvy1beF3DK5X3L/yRRnIW+1xuacf82BIYNqofbF5S1xvVyzhPSASu
plE8qlFNasoEoa+WHKYSL2yXK7Fy3LvqRsYPFUND4Qe0Kc/kHGMP8lxZjrBb/2qx
l3YeGpgUZTKILqnG3PFa/0MnkjWfkaFKtLMbJ0j4oJFFSuISWilp1F2ib+fTOH3d
doGmwymkI0p/6C2tWJGBpMfFY9NyWVsqYvoKH0F6VQ7TF2/1LdZsbZPFjhUXZiTT
UvdJEmXoMGU/KOx9hrl0jsQp3Nrsd2f8jgpxSj9kyDdsjW6im8wagIhEqj/c9udK
SrDJsxHT9nJsIBiFx6F8ex+zZcPOwGKk008q7YxJ1rythAnPLwABO6zg9K5ijZ7t
YVJm16xr4c+e/kyS+utGGFXzAjDHHsJtqdcGWvMqJP0/05/W3hp2n4BsEgjoe1e6
3vGSgVr5bwnI1euRMvRtwFvyWsDEtKFkx0hmNLL9TvNeT93Ek3VGHQeihe6OQnEB
/GuC619jWZZirI0iZxuyKmVrfbziHiu60IaZ+1D2/ERY5qNqCoRDZO6HP5ApRQvu
9yBBgSdZwjq6b1tRcr6H
=7WER
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
