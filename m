From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 0/9] Cleanup and extension of netdev features
Date: Wed, 16 Nov 2011 02:29:54 +0100 (CET)
Message-ID: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46022 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757689Ab1KPB36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:29:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fd38f734 (igbvf: convert to ndo_fix_features) removed last use
of old ethtool ops for controlling netdevice's features. This series
finishes the cleanup and extends feature pool to 64 bits.

Also, there's additional patch that removes NETIF_F_NO_CSUM as it is
now, and has been for some time, equivalent to NETIF_F_HW_CSUM.

To see the new features in action, you need ethtool patched with:

http://patchwork.ozlabs.org/patch/96374/

Not much has changed in those patches compared to the version I posted
in June. v4->v5 is a rebase to current net-next.

Only compile tested. Kernels newer than 3.1-rcSomething don't boot for
me because of some block layer or dm-crypt issue I don't have time to
debug now. :-(

Best Regards,
Micha=C5=82 Miros=C5=82aw

---

Micha=C5=82 Miros=C5=82aw (9):
  net: remove legacy ethtool ops
  net: ethtool: break association of ETH_FLAG_* with NETIF_F_*
  net: split netdev features to separate header
  net: introduce and use netdev_features_t for device features sets
  net: Define enum for net device features.
  net: ethtool: use C99 array initialization for feature-names table
  ethtool: prepare for larger netdev_features_t type
  net: extend netdev_features_t to 64 bits
  net: remove NETIF_F_NO_CSUM feature bit

 drivers/ieee802154/fakehard.c                      |    2 +-
 drivers/misc/sgi-xp/xpnet.c                        |    2 +-
 drivers/net/bonding/bond_main.c                    |   11 +-
 drivers/net/can/dev.c                              |    2 +-
 drivers/net/can/slcan.c                            |    2 +-
 drivers/net/dummy.c                                |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   13 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   13 +-
 drivers/net/ethernet/atheros/atlx/atl2.c           |   13 +-
 drivers/net/ethernet/atheros/atlx/atlx.c           |   13 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    5 +-
 drivers/net/ethernet/broadcom/tg3.c                |   11 +-
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    7 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |    2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.h            |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    9 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   12 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    8 +-
 drivers/net/ethernet/davicom/dm9000.c              |    5 +-
 drivers/net/ethernet/freescale/gianfar.c           |    2 +-
 drivers/net/ethernet/freescale/gianfar.h           |    4 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |    4 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |    6 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |   14 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    5 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   12 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    3 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    3 +-
 drivers/net/ethernet/jme.c                         |    8 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 +-
 drivers/net/ethernet/marvell/sky2.c                |   13 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    3 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    5 +-
 drivers/net/ethernet/neterion/s2io.c               |    4 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    9 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |   11 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    5 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    9 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |   10 +-
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    6 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    3 +-
 drivers/net/ifb.c                                  |    2 +-
 drivers/net/loopback.c                             |    2 +-
 drivers/net/tun.c                                  |    7 +-
 drivers/net/usb/smsc75xx.c                         |    3 +-
 drivers/net/usb/smsc95xx.c                         |    3 +-
 drivers/net/veth.c                                 |    2 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    4 +-
 drivers/net/vmxnet3/vmxnet3_int.h                  |    2 +-
 drivers/net/xen-netback/interface.c                |    3 +-
 drivers/net/xen-netfront.c                         |    8 +-
 drivers/s390/net/qeth_l3_main.c                    |    6 +-
 include/linux/ethtool.h                            |   53 --
 include/linux/netdev_features.h                    |  146 +++++
 include/linux/netdevice.h                          |  137 +----
 include/linux/skbuff.h                             |    5 +-
 include/net/protocol.h                             |    4 +-
 include/net/sock.h                                 |    6 +-
 include/net/tcp.h                                  |    3 +-
 include/net/udp.h                                  |    3 +-
 lib/vsprintf.c                                     |   19 +
 net/8021q/vlan_dev.c                               |    9 +-
 net/bridge/br_device.c                             |    7 +-
 net/bridge/br_if.c                                 |    5 +-
 net/bridge/br_private.h                            |    3 +-
 net/core/dev.c                                     |   71 +--
 net/core/ethtool.c                                 |  559 ++++--------=
--------
 net/core/skbuff.c                                  |    2 +-
 net/ipv4/af_inet.c                                 |    3 +-
 net/ipv4/tcp.c                                     |    3 +-
 net/ipv4/udp.c                                     |    3 +-
 net/ipv6/af_inet6.c                                |    3 +-
 net/ipv6/udp.c                                     |    3 +-
 83 files changed, 568 insertions(+), 842 deletions(-)
 create mode 100644 include/linux/netdev_features.h

--=20
1.7.7.1
