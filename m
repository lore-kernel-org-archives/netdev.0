From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-03-02
Date: Mon, 2 Mar 2015 08:53:54 +0200
Message-ID: <20150302065354.GA3613@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the first bluetooth-next pull request targeting the 4.1 kernel:

 - ieee802154/6lowpan cleanups
 - SCO routing to host interface support for the btmrvl driver
 - AMP code cleanups
 - Fixes to AMP HCI init sequence
 - Refactoring of the HCI callback mechanism
 - Added shutdown routine for Intel controllers in the btusb driver
 - New config option to enable/disable Bluetooth debugfs information
 - Fix for early data reception on L2CAP fixed channels

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 855e7e7174bade3f2b63077a81eea5aab525dbf6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux (2015-02-11 19:48:14 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to c91799c50a14137ecee6d60d2f1d9ab8bc895e52:

  at86rf230: add warning if edge-triggered irq (2015-02-27 18:42:44 +0100)

----------------------------------------------------------------
Alexander Aring (12):
      ieee802154: correct ieee802154_is_valid_psdu_len
      ieee802154: cleanup ieee802154_be64_to_le64
      ieee802154: cleanup ieee802154_le64_to_be64
      6lowpan: add generic nhc layer interface
      6lowpan: add udp compression via nhc layer
      6lowpan: nhc: add other known rfc6282 compressions
      at86rf230: copy pdata to driver allocated space
      at86rf230: add support for external xtal trim
      at86rf230: remove tx_timeout
      at86rf230: add irqmask mode setting
      at86rf230: add irq low-level for polarity
      at86rf230: add warning if edge-triggered irq

Alexander Ploumistos (1):
      Bluetooth: ath3k: Add support Atheros AR5B195 combo Mini PCIe card

Amitkumar Karwar (1):
      Bluetooth: btmrvl: support SCO routing to host interface

Jiri Slaby (1):
      Bluetooth: make hci_test_bit's addr const

Johan Hedberg (14):
      Bluetooth: btusb: Remove unneeded btusb_wait_on_bit_timeout()
      Bluetooth: Fix accepting early data on fixed channels
      Bluetooth: Fix AMP init for certain AMP controllers
      Bluetooth: Add new hci_cb entries to the tail rather than the head
      Bluetooth: Convert hci_cb_list_lock to a mutex
      Bluetooth: Convert L2CAP security callback to use hci_cb
      Bluetooth: Convert connect_cfm to be triggered through hci_cb
      Bluetooth: Convert disconn_cfm to be triggered through hci_cb
      Bluetooth: Remove bogus check for pending mgmt Set HS command
      Bluetooth: Fix checking for pending Set SSP in Set HS handler
      Bluetooth: Use hci_copy_identity_addr() helper for SMP chan creation
      Bluetooth: Rename hci_send_to_control to hci_send_to_channel
      Bluetooth: Remove unnecessary queue_monitor_skb() function
      Bluetooth: Update New CSRK event to match latest specification

Lukasz Rymanowski (3):
      Bluetooth: Do not allow LE connection if LE is not enabled
      Bluetooth: Improve error handling in connect acl
      Bluetooth: Enhance error codes pair device command

Marcel Holtmann (7):
      Bluetooth: Move A2MP_FEAT_EXT declaration into A2MP source
      Bluetooth: Make amp_mgr_list and amp_mgr_list_lock static
      Bluetooth: Make amp_mgr_lookup_by_state function static
      Bluetooth: Make a2mp_send function static
      Bluetooth: Make __next_ident function static.
      Bluetooth: btusb: Use matching names for Broadcom firmware files
      Bluetooth: Provide option to enable/disable debugfs information

Nicholas Mc Guire (1):
      at86rf230: assign wait_for_completion_timeout to appropriately typed var

Nicolas Dichtel (1):
      ieee802154: fix netns settings

Tedd Ho-Jeong An (2):
      Bluetooth: Add shutdown callback before closing the device
      Bluetooth: Add device shutdown routine for Intel Bluetooth device

 .../bindings/net/ieee802154/at86rf230.txt          |   8 +-
 drivers/bluetooth/ath3k.c                          |   1 +
 drivers/bluetooth/btmrvl_drv.h                     |   1 +
 drivers/bluetooth/btmrvl_main.c                    |  14 ++
 drivers/bluetooth/btusb.c                          | 120 +++++++---
 drivers/net/ieee802154/at86rf230.c                 | 120 +++++++---
 include/linux/ieee802154.h                         |  12 +-
 include/linux/spi/at86rf230.h                      |   1 +
 include/net/bluetooth/hci_core.h                   | 146 ++++--------
 include/net/bluetooth/mgmt.h                       |   7 +-
 include/net/mac802154.h                            |   9 +-
 net/6lowpan/Kconfig                                |  57 ++++-
 net/6lowpan/Makefile                               |  13 +-
 net/6lowpan/iphc.c                                 | 200 +++-------------
 net/6lowpan/nhc.c                                  | 241 ++++++++++++++++++++
 net/6lowpan/nhc.h                                  | 146 ++++++++++++
 net/6lowpan/nhc_dest.c                             |  28 +++
 net/6lowpan/nhc_fragment.c                         |  27 +++
 net/6lowpan/nhc_hop.c                              |  27 +++
 net/6lowpan/nhc_ipv6.c                             |  27 +++
 net/6lowpan/nhc_mobility.c                         |  27 +++
 net/6lowpan/nhc_routing.c                          |  27 +++
 net/6lowpan/nhc_udp.c                              | 157 +++++++++++++
 net/bluetooth/Kconfig                              |   8 +
 net/bluetooth/Makefile                             |   3 +-
 net/bluetooth/a2mp.c                               |  44 ++--
 net/bluetooth/a2mp.h                               |   8 -
 net/bluetooth/hci_conn.c                           |  20 +-
 net/bluetooth/hci_core.c                           |  48 ++--
 net/bluetooth/hci_debugfs.h                        |  22 ++
 net/bluetooth/hci_event.c                          |  38 +--
 net/bluetooth/hci_sock.c                           |  45 +---
 net/bluetooth/l2cap_core.c                         |  40 +++-
 net/bluetooth/mgmt.c                               |  18 +-
 net/bluetooth/sco.c                                |  21 +-
 net/bluetooth/smp.c                                |  34 ++-
 net/ieee802154/6lowpan/core.c                      |   6 +-
 net/ieee802154/core.c                              |   1 +
 38 files changed, 1283 insertions(+), 489 deletions(-)
 create mode 100644 net/6lowpan/nhc.c
 create mode 100644 net/6lowpan/nhc.h
 create mode 100644 net/6lowpan/nhc_dest.c
 create mode 100644 net/6lowpan/nhc_fragment.c
 create mode 100644 net/6lowpan/nhc_hop.c
 create mode 100644 net/6lowpan/nhc_ipv6.c
 create mode 100644 net/6lowpan/nhc_mobility.c
 create mode 100644 net/6lowpan/nhc_routing.c
 create mode 100644 net/6lowpan/nhc_udp.c

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9AkCAAoJECQj9vv5qNQSJNQP/10c2SlvFuQvR+dSdQHctlqf
kFsppkY3mlNwZI6ZgGWt2oZyb0Nk6oVIYwu0W+eqnstrZlB1oFe5KgUL1uC+9oRw
r+BplWMdaRChzh5+oLKdavYkDYzYbaVVnIXIhw9wxJA5w6n0bOVOBoeA9CIED74z
TbRrKiIVRi5z4WOSc/D9YciPRgkYoZgxAr8NMKRg3YtikC5DH6vKEVMOTx/HIzfe
ETuErsDa1NhG1+tXoL+ga46fA1+HMwI5zd0Pt+9e1uskRIJIE9jb2cEDVe5GTTFn
YoK1Bg56p4UdihksJNlu1cqCvP17MWn0pLbU7P4ZSyF+mnso3A/ZVrZpmTU49BIH
o1WXViOc6WtDSGU6A/WEILpPbqEg96zzdzAmsVE8jCqORngp7nJTqq0f45oigZ6g
T8XNZw8I3cjQgBb+IhVW0Ws23oe12ODrhHJJBdhYTK/Y+vIjCKJUPMDityc7EAxF
L+6TUZ4yQqwqGgFKKnABq8TGSp77pllwUBKnGVKitYPJjWR74+WKq5hdthUBwE+L
C9ZkD8wy84FXrKNyECAZvtgBZiWfaC5RxEBhio8yOu0AeCt6QH56QyZInvKhjVYq
mbf0WM1Dp7q8BY8/LVYa7QHTy4MIHklRaD5iGbx3LOjNfIH54jcXavV4blTW1FQq
gfZAtWvpYGpE5cpR+nv8
=G9Bg
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
