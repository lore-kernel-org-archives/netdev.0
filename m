From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 13 Oct 2016 12:27:02 -0400 (EDT)
Message-ID: <20161013.122702.1613023365348643871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756484AbcJMQ2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:28:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix various build warnings in tlan/qed/xen-netback drivers, from Arnd Bergmann.

2) Propagate proper error code in strparser's strp_recv(), from Geert
   Uytterhoeven.

3) Fix accidental broadcast of RTM_GETTFILTER responses, from Eric Dumazret.

4) Need to use list_for_each_entry_safe() in qed driver, from Wei
   Yongjun.

5) Openvswitch 802.1AD bug fixes from Jiri Benc.

6) Cure BUILD_BUG_ON() in mlx5 driver, from Tom Herbert.

7) Fix UDP ipv6 checksumming in netvsc driver, from Stephen Hemminger.

8) stmmac driver fixes from Giuseppe CAVALLARO.

9) Fix access to mangled IP6CB in tcp, from Eric Dumazet.

10) Fix info leaks in tipc and rtnetlink, from Dan Carpenter.

Please pull, thanks a lot!

The following changes since commit 6b25e21fa6f26d0f0d45f161d169029411c84286:

  Merge tag 'drm-for-v4.9' of git://people.freedesktop.org/~airlied/linux (2016-10-11 18:12:22 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 4eb6753c3324873752f56543e149956e39dd32b6:

  net: bridge: add the multicast_flood flag attribute to brport_attrs (2016-10-13 12:16:36 -0400)

----------------------------------------------------------------
Andrew Lunn (1):
      net: phy: Trigger state machine on state change and not polling.

Arnd Bergmann (3):
      tlan: avoid unused label with PCI=n
      qed: fix old-style function definition
      xen-netback: fix type mismatch warning

Bjørn Mork (1):
      qmi_wwan: add support for Quectel EC21 and EC25

Dan Carpenter (3):
      tipc: info leak in __tipc_nl_add_udp_addr()
      net: rtnl: info leak in rtnl_fill_vfinfo()
      liquidio: CN23XX: fix a loop timeout

David Ahern (1):
      net: ipv4: Do not drop to make_route if oif is l3mdev

David S. Miller (2):
      Merge branch 'ovs-8021AD-fixes'
      netvsc: Remove mistaken udp.h inclusion.

David Vrabel (1):
      xen-netback: fix guest Rx stall detection (after guest Rx refactor)

Eric Dumazet (2):
      net_sched: do not broadcast RTM_GETTFILTER result
      ipv6: tcp: restore IP6CB for pktoptions skbs

Geert Uytterhoeven (1):
      strparser: Propagate correct error code in strp_recv()

Giuseppe CAVALLARO (2):
      stmmac: fix ptp init for gmac4
      stmmac: fix error check when init ptp

Jiri Benc (3):
      openvswitch: vlan: remove wrong likely statement
      openvswitch: fix vlan subtraction from packet length
      openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev

Nikolay Aleksandrov (1):
      net: bridge: add the multicast_flood flag attribute to brport_attrs

Paul Durrant (1):
      xen-netback: (re-)create a debugfs node for hash information

Tobias Klauser (1):
      net: axienet: Remove unused parameter from __axienet_device_reset

Tom Herbert (1):
      net/mlx5: Add MLX5_ARRAY_SET64 to fix BUILD_BUG_ON

Vlad Tsyrklevich (1):
      drivers/ptp: Fix kernel memory disclosure

WANG Cong (1):
      net_sched: reorder pernet ops and act ops registrations

Wei Yongjun (1):
      qed: Fix to use list_for_each_entry_safe() when delete items

stephen hemminger (1):
      netvsc: fix checksum on UDP IPV6

 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c     |  4 ++--
 drivers/net/ethernet/qlogic/qed/qed_ll2.c               |  4 ++--
 drivers/net/ethernet/qlogic/qed/qed_roce.c              |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c       | 21 ++++++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c        | 10 ++++++----
 drivers/net/ethernet/ti/tlan.c                          |  2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c       | 11 +++++------
 drivers/net/hyperv/netvsc_drv.c                         | 71 +++++++++++++++++++++--------------------------------------------------
 drivers/net/phy/phy.c                                   | 22 ++++++++++++++++++++--
 drivers/net/usb/qmi_wwan.c                              | 30 ++++++++++++++++++++++++++++--
 drivers/net/xen-netback/common.h                        |  4 ++++
 drivers/net/xen-netback/hash.c                          | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/rx.c                            |  8 +++++---
 drivers/net/xen-netback/xenbus.c                        | 37 +++++++++++++++++++++++++++++++++++--
 drivers/ptp/ptp_chardev.c                               |  1 +
 include/linux/mlx5/device.h                             | 13 +++++++++++--
 include/net/l3mdev.h                                    | 24 ++++++++++++++++++++++++
 net/bridge/br_sysfs_if.c                                |  1 +
 net/core/rtnetlink.c                                    |  2 ++
 net/ipv4/route.c                                        |  3 ++-
 net/ipv6/tcp_ipv6.c                                     | 20 +++++++++++---------
 net/openvswitch/flow.c                                  |  2 +-
 net/openvswitch/vport-internal_dev.c                    |  2 +-
 net/openvswitch/vport.c                                 |  3 ++-
 net/sched/act_api.c                                     | 19 +++++++++++--------
 net/sched/cls_api.c                                     | 18 +++++++++++-------
 net/strparser/strparser.c                               |  2 +-
 net/tipc/udp_media.c                                    |  2 ++
 29 files changed, 294 insertions(+), 114 deletions(-)
