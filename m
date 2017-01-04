From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 04 Jan 2017 16:45:57 -0500 (EST)
Message-ID: <20170104.164557.1621720319769096524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdADVp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 16:45:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) stmmac_drv_probe() can race with stmmac_open() because we register the
   netdevice too early.  Fix from Florian Fainelli.

2) UFO handling in __ip6_append_data() and ip6_finish_output() use different
   tests for deciding whether a frame will be fragmented or not, put them
   in sync.  Fix from Zheng Li.

3) The rtnetlink getstats handlers need to validate that the netlink
   request is large enough, fix from Mathias Krause.

4) Use after free in mlx4 driver, from Jack Morgenstein.

5) Fix setting of garbage UID value in sockets during setattr() calls,
   from Eric Biggers.

6) Packet drop_monitor doesn't format the netlink messages properly such
   that nlmsg_next fails to work, fix from Reiter Wolfgang.

7) Fix handling of wildcard addresses in l2tp lookups, from Guillaume
   Nault.

8) __skb_flow_dissect() can crash on pptp packets, from Ian Kumlien.

9) IGMP code doesn't reset group query timers properly, from Michal
   Tesar.

10) Fix overzealous MAIN/LOCAL route table combining in ipv4, from
    Alexander Duyck.

11) vxlan offload check needs to be more strict in be2net driver,
    from Sabrina Dubroca.

12) Moving l3mdev to packet hooks lost RX stat counters unintentionally,
    fix from David Ahern.

Please pull, thanks a lot!

The following changes since commit 8f18e4d03ed8fa5e4a300c94550533bd8ce4ff9a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-12-27 16:04:37 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 71eae1ca77fd6be218d8a952d97bba827e56516d:

  sh_eth: enable RX descriptor word 0 shift on SH7734 (2017-01-04 16:12:14 -0500)

----------------------------------------------------------------
Alexander Alemayhu (1):
      Documentation/networking: fix typo in mpls-sysctl

Alexander Duyck (1):
      ipv4: Do not allow MAIN to be alias for new LOCAL w/ custom rules

Augusto Mecking Caringi (1):
      net: atm: Fix warnings in net/atm/lec.c when !CONFIG_PROC_FS

Bartosz Folta (1):
      net: macb: Updated resource allocation function calls to new version of API.

Colin Ian King (1):
      net: wan: slic_ds26522: fix spelling mistake: "configurated" -> "configured"

Daniel Jurgens (1):
      net/mlx5: Cancel recovery work in remove flow

David Ahern (2):
      net: ipv4: dst for local input routes should use l3mdev if relevant
      net: vrf: Add missing Rx counters

David S. Miller (7):
      Merge branch 'mlx5-fixes'
      Merge branch 'mlx4-misc-fixes'
      Merge branch 'l2tp-socket-lookup-fixes'
      Merge tag 'mac80211-for-davem-2017-01-02' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'dwmac-oxnas-leaks'
      Merge branch 'systemport-padding-and-TSB-insertion'
      Merge branch 'dpaa_eth-fixes'

Edward Cree (1):
      sfc: don't report RX hash keys to ethtool when RSS wasn't enabled

Eli Cohen (1):
      net/mlx5: Avoid shadowing numa_node

Eric Biggers (1):
      net: socket: don't set sk_uid to garbage value in ->setattr()

Eugenia Emantayev (1):
      net/mlx4_en: Fix bad WQE issue

Florian Fainelli (4):
      net: stmmac: Fix race between stmmac_drv_probe and stmmac_open
      net: stmmac: Fix error path after register_netdev move
      net: systemport: Utilize skb_put_padto()
      net: systemport: Pad packet before inserting TSB

Gal Pressman (2):
      Revert "net/mlx5e: Expose PCIe statistics to ethtool"
      Revert "net/mlx5: Add MPCNT register infrastructure"

Guillaume Nault (2):
      l2tp: consider '::' as wildcard address in l2tp_ip6 socket lookup
      l2tp: take remote address into account in l2tp_ip and l2tp_ip6 socket lookups

Huy Nguyen (1):
      net/mlx5e: Check ets capability before initializing ets settings

Ian Kumlien (1):
      flow_dissector: Update pptp handling to avoid null pointer deref.

Jack Morgenstein (2):
      net/mlx4_core: Use-after-free causes a resource leak in flow-steering detach
      net/mlx4_core: Fix raw qp flow steering rules under SRIOV

Johan Hovold (3):
      net: stmmac: dwmac-oxnas: fix of-node leak
      net: stmmac: dwmac-oxnas: fix fixed-link-phydev leaks
      net: stmmac: dwmac-oxnas: use generic pm implementation

Johannes Berg (1):
      mac80211: initialize fast-xmit 'info' later

Leon Romanovsky (1):
      net/mlx4: Remove BUG_ON from ICM allocation routine

Madalin Bucur (1):
      dpaa_eth: cleanup after init_phy() failure

Maor Gottlieb (2):
      net/mlx5: Mask destination mac value in ethtool steering rules
      net/mlx5: Release FTE lock in error flow

Mathias Krause (1):
      rtnl: stats - add missing netlink message size checks

Michal Tesar (1):
      igmp: Make igmp group member RFC 3376 compliant

Mohamad Haj Yahia (1):
      net/mlx5: Prevent setting multicast macs for VFs

Nicolas Pitre (1):
      LiquidIO VF: s/select/imply/ for PTP_1588_CLOCK

Noa Osherovich (1):
      net/mlx5: Check FW limitations on log_max_qp before setting it

Or Gerlitz (1):
      net/mlx5: Disable RoCE on the e-switch management port under switchdev mode

Paul Blakey (1):
      net/sched: cls_flower: Fix missing addr_type in classify

Peter Chen (1):
      net: usb: asix_devices: add .reset_resume for USB PM

Reiter Wolfgang (2):
      drop_monitor: add missing call to genlmsg_end
      drop_monitor: consider inserted data in genlmsg_end

Roy Pledge (1):
      dpaa_eth: Initialize CGR structure before init

Sabrina Dubroca (1):
      benet: stricter vxlan offloading check in be_features_check

Saeed Mahameed (2):
      net/mlx5e: Don't sync netdev state when not registered
      net/mlx5e: Disable netdev after close

Sergei Shtylyov (2):
      sh_eth: fix branch prediction in sh_eth_interrupt()
      sh_eth: enable RX descriptor word 0 shift on SH7734

Slava Shwartsman (1):
      net/mlx4_en: Fix type mismatch for 32-bit systems

Varun Prakash (1):
      libcxgb: fix error check for ip6_route_output()

Wei Zhang (1):
      net: fix incorrect original ingress device index in PKTINFO

Zheng Li (1):
      ipv6: Should use consistent conditional judgement for ip6 fragment between __ip6_append_data and ip6_finish_output

 Documentation/networking/mpls-sysctl.txt                   |  4 ++--
 drivers/infiniband/hw/mlx4/main.c                          | 14 ++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.c                 | 23 +++++++++++------------
 drivers/net/ethernet/cadence/macb_pci.c                    | 27 ++++++++++-----------------
 drivers/net/ethernet/cavium/Kconfig                        |  2 +-
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c          | 12 +++++-------
 drivers/net/ethernet/emulex/benet/be_main.c                |  4 +++-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c             |  6 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c              |  8 ++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c                 |  8 +++++++-
 drivers/net/ethernet/mellanox/mlx4/icm.c                   |  7 ++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c                  | 18 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c      | 28 +++++-----------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c         |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c       | 17 -----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c          | 51 ++++++++++++++++-----------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h         | 32 +-------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 11 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c          |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c             | 15 +++++++++++----
 drivers/net/ethernet/renesas/sh_eth.c                      |  3 ++-
 drivers/net/ethernet/sfc/ef10.c                            |  3 ++-
 drivers/net/ethernet/sfc/ethtool.c                         |  2 ++
 drivers/net/ethernet/sfc/net_driver.h                      |  2 ++
 drivers/net/ethernet/sfc/siena.c                           |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c          | 89 +++++++++++++++++++++++++++++++++--------------------------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c          | 23 +++++++++++++----------
 drivers/net/usb/asix_devices.c                             |  1 +
 drivers/net/vrf.c                                          |  3 +++
 drivers/net/wan/slic_ds26522.c                             |  2 +-
 include/linux/mlx4/device.h                                |  2 ++
 include/linux/mlx5/device.h                                |  5 -----
 include/linux/mlx5/driver.h                                |  1 -
 include/linux/mlx5/mlx5_ifc.h                              | 93 ---------------------------------------------------------------------------------------------
 net/atm/lec.c                                              |  2 ++
 net/core/drop_monitor.c                                    | 39 ++++++++++++++++++++++++++++++---------
 net/core/flow_dissector.c                                  |  5 +++--
 net/core/rtnetlink.c                                       |  6 ++++++
 net/ipv4/fib_frontend.c                                    |  2 +-
 net/ipv4/igmp.c                                            |  7 ++++++-
 net/ipv4/ip_sockglue.c                                     |  8 +++++++-
 net/ipv4/route.c                                           |  3 ++-
 net/ipv6/ip6_output.c                                      |  2 +-
 net/l2tp/l2tp_ip.c                                         | 19 ++++++-------------
 net/l2tp/l2tp_ip6.c                                        | 24 ++++++++----------------
 net/mac80211/tx.c                                          |  3 ++-
 net/sched/cls_flower.c                                     |  4 ++++
 net/socket.c                                               |  2 +-
 50 files changed, 273 insertions(+), 377 deletions(-)
