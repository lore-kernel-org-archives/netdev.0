From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFT PATCH 0/9] Cleanup and extension of netdev features
Date: Mon, 20 Jun 2011 21:14:54 +0200 (CEST)
Message-ID: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41912 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837Ab1FTTPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:15:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a preview of the cleanups pending after getting rid of old
ethtool ops from remaining drivers.

Patches inside:
 1. (placeholder for Intel patches)
 2. removal of old ethtool ops
	(most further patches depend on this one)
 3. break association of ETH_FLAG_* with netdev features
	this will allow to change the representation and access pattern
	of the feature sets if later needed; as a bonus, the features
	can be (almost) freely rearranged
 4. introducing netdev_features_t
	use new type wherever features are passed around (this needed
	new include - otherwise linux/skbuff.h would need linux/netdevice.h)
 5. cleanup of feature bits
 6. cleanup of feature name table
	(depends on #5)
 7. prepare ethtool [GS]FEATURES for larger netdev_features_t
 8. tadaaa: 64 bits for features
 9. a lone cleanup patch for NOCACHE_COPY feature

Bear in mind, that I only compile tested the whole series (x86 allyesco=
nfig).
I'll do per-patch builds after all needed patches are in net-next.

Note about netdev_features_t: I don't like the idea of converting it to
bitmap type and building wrappers around, so I won't even try to
implement it. Nevertheless, this series will make the conversion easier
if someone ever wants to go that way.

Best Regards,
Micha=C5=82 Miros=C5=82aw

---

Micha=C5=82 Miros=C5=82aw (9):
  [NOT SENT] Intel net drivers: convert to ndo_fix_features
  net: remove legacy ethtool ops
  net: ethtool: break association of ETH_FLAG_* with NETIF_F_*
  net: introduce and use netdev_features_t for device features sets
  net: Define enum for net device features.
  net: ethtool: use C99 array initialization for feature-names table
  ethtool: prepare for larger netdev_features_t type
  net: extend netdev_features_t to 64 bits
  net: move NOCACHE_COPY checks to netdev_fix_features()

 drivers/net/8139cp.c                  |    2 +-
 drivers/net/bnx2.c                    |    6 +-
 drivers/net/bnx2x/bnx2x_cmn.c         |    5 +-
 drivers/net/bnx2x/bnx2x_cmn.h         |    5 +-
 drivers/net/bonding/bond_main.c       |    9 +-
 drivers/net/cxgb4/cxgb4_main.c        |   12 +-
 drivers/net/dm9000.c                  |    3 +-
 drivers/net/e1000/e1000_ethtool.c     |   69 ----
 drivers/net/e1000/e1000_main.c        |   31 ++-
 drivers/net/e1000e/ethtool.c          |   88 -----
 drivers/net/e1000e/netdev.c           |   35 ++-
 drivers/net/forcedeth.c               |    7 +-
 drivers/net/gianfar.h                 |    2 +-
 drivers/net/gianfar_ethtool.c         |    4 +-
 drivers/net/ibmveth.c                 |    6 +-
 drivers/net/igb/igb_ethtool.c         |   67 ----
 drivers/net/igb/igb_main.c            |   33 ++-
 drivers/net/igbvf/ethtool.c           |   57 ----
 drivers/net/igbvf/netdev.c            |   25 ++-
 drivers/net/ixgb/ixgb.h               |    2 +
 drivers/net/ixgb/ixgb_ethtool.c       |   98 +------
 drivers/net/ixgb/ixgb_main.c          |   44 +++-
 drivers/net/ixgbe/ixgbe_ethtool.c     |  183 ++++--------
 drivers/net/ixgbe/ixgbe_main.c        |   42 ++-
 drivers/net/ixgbevf/ethtool.c         |   46 ---
 drivers/net/ixgbevf/ixgbevf_main.c    |   26 ++-
 drivers/net/jme.c                     |    8 +-
 drivers/net/ksz884x.c                 |    3 +-
 drivers/net/mv643xx_eth.c             |    2 +-
 drivers/net/myri10ge/myri10ge.c       |    2 +-
 drivers/net/netxen/netxen_nic_main.c  |    6 +-
 drivers/net/pch_gbe/pch_gbe_main.c    |    5 +-
 drivers/net/qlcnic/qlcnic.h           |    5 +-
 drivers/net/qlcnic/qlcnic_hw.c        |    9 +-
 drivers/net/qlcnic/qlcnic_main.c      |    2 +-
 drivers/net/r8169.c                   |    6 +-
 drivers/net/s2io.c                    |    4 +-
 drivers/net/sfc/efx.c                 |    2 +-
 drivers/net/sky2.c                    |    5 +-
 drivers/net/tg3.c                     |    7 +-
 drivers/net/usb/smsc75xx.c            |    3 +-
 drivers/net/usb/smsc95xx.c            |    3 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    4 +-
 drivers/net/vmxnet3/vmxnet3_int.h     |    2 +-
 drivers/net/vxge/vxge-main.c          |    9 +-
 drivers/net/xen-netfront.c            |    8 +-
 drivers/s390/net/qeth_l3_main.c       |    6 +-
 include/linux/ethtool.h               |   53 ---
 include/linux/netdev_features.h       |  152 +++++++++
 include/linux/netdevice.h             |  141 ++-------
 include/linux/skbuff.h                |    4 +-
 include/net/protocol.h                |    4 +-
 include/net/tcp.h                     |    3 +-
 include/net/udp.h                     |    3 +-
 net/8021q/vlan_dev.c                  |    5 +-
 net/bridge/br_if.c                    |    5 +-
 net/core/dev.c                        |   71 ++--
 net/core/ethtool.c                    |  563 ++++++-------------------=
-------
 net/core/net-sysfs.c                  |    3 +-
 net/core/skbuff.c                     |    2 +-
 net/ipv4/af_inet.c                    |    3 +-
 net/ipv4/tcp.c                        |    2 +-
 net/ipv4/udp.c                        |    3 +-
 net/ipv6/af_inet6.c                   |    3 +-
 net/ipv6/udp.c                        |    2 +-
 65 files changed, 683 insertions(+), 1347 deletions(-)
 create mode 100644 include/linux/netdev_features.h

--=20
1.7.2.5

