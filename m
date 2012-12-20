From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 19 Dec 2012 16:06:33 -0800 (PST)
Message-ID: <20121219.160633.1231010819351416271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab2LTAGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 19:06:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Really fix tuntap SKB use after free bug, from Eric Dumazet.

2) Adjust SKB data pointer to point past the transport header before
   calling icmpv6_notify() so that the headers are in the state which
   that function expects.  From Duan Jiong.

3) Fix ambiguities in the new tuntap multi-queue APIs.  From
   Jason Wang.

4) mISDN needs to use del_timer_sync(), from Konstantin Khlebnikov.

5) Don't destroy mutex after freeing up device private in mac802154,
   fix also from Konstantin Khlebnikov.

6) Fix INET request socket leak in TCP and DCCP, from Christoph Paasch.

7) SCTP HMAC kconfig rework, from Neil Horman.

8) Fix SCTP jprobes function signature, otherwise things explode,
   from Daniel Borkmann.

9) Fix typo in ipv6-offload Makefile variable reference, from
   Simon Arlott.

10) Don't fail USBNET open just because remote wakeup isn't
    supported, from Oliver Neukum.

11) be2net driver bug fixes from Sathya Perla.

12) SOLOS PCI ATM driver bug fixes from Nathan Williams and David
    Woodhouse.
  =20
13) Fix MTU changing regression in 8139cp driver, from John Greene.

Please pull, thanks a lot!

The following changes since commit 17bc14b767cf0692420c43dbe5310ae98a5a=
7836:

  Revert "sched: Update_cfs_shares at period edge" (2012-12-14 07:20:43=
 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 152a2a8b5e1d4cbe91a7c66f1028db15164a3766=
:

  solos-pci: ensure all TX packets are aligned to 4 bytes (2012-12-19 1=
4:53:53 -0800)

----------------------------------------------------------------
Amerigo Wang (2):
      bridge: update selinux perm table for RTM_NEWMDB and RTM_DELMDB
      bridge: add flags to distinguish permanent mdb entires

Ang Way Chuang (1):
      bridge: remove temporary variable for MLDv2 maximum response code=
 computation

Bj=F8rn Mork (1):
      net: qmi_wwan: add ZTE MF880

Christoph Paasch (1):
      inet: Fix kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_reques=
t_recv_sock

Cong Ding (1):
      ipv6: addrconf.c: remove unnecessary "if"

Dan Williams (3):
      i2400m: add Intel 6150 device IDs
      qmi_wwan/cdc_ether: add Dell Wireless 5800 (Novatel E362) USB IDs
      cdc_ether: cleanup: use USB_DEVICE_AND_INTERFACE_INFO for Novatel=
 551/E362

Daniel Borkmann (1):
      sctp: jsctp_sf_eat_sack: fix jprobes function signature mismatch

David Woodhouse (1):
      solos-pci: ensure all TX packets are aligned to 4 bytes

Duan Jiong (1):
      ipv6: Change skb->data before using icmpv6_notify() to propagate =
redirect

Eric Dumazet (1):
      tuntap: reset network header before calling skb_get_rxhash()

Gabor Juhos (1):
      rt2x00: zero-out rx_status

Hannes Frederic Sowa (2):
      netlink: change presentation of portid in procfs to unsigned
      netlink: validate addr_len on bind

Jason Wang (2):
      tuntap: fix ambigious multiqueue API
      tuntap: fix sparse warning

John Greene (1):
      8139cp: Prevent dev_close/cp_interrupt race on MTU change

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Konstantin Khlebnikov (4):
      mISDN: fix race in timer canceling on module unloading
      stmmac: fix platform driver unregistering
      bonding: do not cancel works in bond_uninit()
      mac802154: fix destructon ordering for ieee802154 devices

Lennert Buytenhek (1):
      ksz884x: fix receive polling race condition

Marc Kleine-Budde (1):
      can: sja1000: fix compilation on x86

Nathan Williams (3):
      solos-pci: add GPIO support for newer versions on Geos board
      solos-pci: remove superfluous debug output
      solos-pci: add firmware upgrade support for new models

Neil Horman (1):
      sctp: Change defaults on cookie hmac selection

Oliver Neukum (3):
      usbnet: handle PM failure gracefully
      usbnet: generic manage_power()
      use generic usbnet_manage_power()

Sachin Kamat (2):
      drivers/net: Use of_match_ptr() macro in smc91x.c
      drivers/net: Use of_match_ptr() macro in smsc911x.c

Sathya Perla (2):
      be2net: fix be_close() to ensure all events are ack'ed
      be2net: fix wrong frag_idx reported by RX CQ

Shahed Shaikh (1):
      qlcnic: fix unused variable warnings

Shawn Guo (1):
      net: fec: forbid FEC_PTP on SoCs that do not support

Signed-off-by: Sony Chacko (1):
      qlcnic: update driver version

Simon Arlott (1):
      ipv6: Fix Makefile offload objects

Tony Lindgren (1):
      cpts: Fix build error caused by include of plat/clock.h

Vlad Yasevich (2):
      bridge: Do not unregister all PF_BRIDGE rtnl operations
      bridge: Correctly encode addresses when dumping mdb entries

Vladimir Kondratiev (1):
      wireless: fix Atheros drivers compilation

chas williams - CONTRACTOR (1):
      atm: use scnprintf() instead of sprintf()

 drivers/atm/solos-pci.c                              | 186 +++++++++++=
+++++++++++++++++++++++++++++----
 drivers/isdn/mISDN/dsp_core.c                        |   3 +-
 drivers/net/bonding/bond_main.c                      |   2 -
 drivers/net/can/sja1000/sja1000_of_platform.c        |   2 +-
 drivers/net/ethernet/emulex/benet/be.h               |   2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c          |   5 ++
 drivers/net/ethernet/emulex/benet/be_main.c          |  59 ++++++++++-=
---
 drivers/net/ethernet/freescale/Kconfig               |   3 +-
 drivers/net/ethernet/micrel/ksz884x.c                |  12 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h          |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c      |   5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c       |   5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |   5 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c |   3 +-
 drivers/net/ethernet/realtek/8139cp.c                |  18 +++--
 drivers/net/ethernet/smsc/smc91x.c                   |   4 +-
 drivers/net/ethernet/smsc/smsc911x.c                 |   4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h         |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  22 +++---
 drivers/net/ethernet/ti/cpts.c                       |   2 -
 drivers/net/tun.c                                    |  87 +++++++++++=
++++------
 drivers/net/usb/cdc_ether.c                          |  45 +++++------
 drivers/net/usb/cdc_ncm.c                            |  10 +--
 drivers/net/usb/qmi_wwan.c                           |  15 ++++
 drivers/net/usb/usbnet.c                             |  25 ++++--
 drivers/net/wimax/i2400m/i2400m-usb.h                |   3 +
 drivers/net/wimax/i2400m/usb.c                       |   6 ++
 drivers/net/wireless/Makefile                        |   2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c              |   8 ++
 include/linux/usb/usbnet.h                           |   3 +
 include/net/inet_connection_sock.h                   |   1 +
 include/net/ndisc.h                                  |   7 ++
 include/uapi/linux/if_bridge.h                       |   3 +
 net/atm/atm_sysfs.c                                  |  40 ++++------
 net/bridge/br_mdb.c                                  |  22 ++++--
 net/bridge/br_multicast.c                            |  13 ++--
 net/bridge/br_netlink.c                              |   1 -
 net/bridge/br_private.h                              |   5 +-
 net/dccp/ipv4.c                                      |   4 +-
 net/dccp/ipv6.c                                      |   3 +-
 net/ipv4/inet_connection_sock.c                      |  16 ++++
 net/ipv4/tcp_ipv4.c                                  |   6 +-
 net/ipv6/Makefile                                    |   2 +-
 net/ipv6/addrconf.c                                  |   3 +-
 net/ipv6/ndisc.c                                     |  17 ++++
 net/ipv6/tcp_ipv6.c                                  |   3 +-
 net/mac802154/ieee802154_dev.c                       |   4 +-
 net/netlink/af_netlink.c                             |   5 +-
 net/sctp/Kconfig                                     |  27 ++++++-
 net/sctp/probe.c                                     |   3 +-
 net/sctp/protocol.c                                  |   4 +-
 security/selinux/nlmsgtab.c                          |   2 +
 52 files changed, 545 insertions(+), 202 deletions(-)
