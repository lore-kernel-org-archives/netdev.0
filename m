From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 03 May 2016 16:38:40 -0400 (EDT)
Message-ID: <20160503.163840.1589101784197713416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some straggler bug fixes:

1) Batman-adv DAT must consider VLAN IDs when choosing candidate nodes, from
   Antonio Quartulli.

2) Fix botched reference counting of vlan objects and neigh nodes in batman-adv,
   from Sven Eckelmann.

3) netem can crash when it sees GSO packets, the fix is to segment then upon
   ->enqueue.  Fix from Neil Horman with help from Eric Dumazet.

4) Fix VXLAN dependencies in mlx5 driver Kconfig, from Matthew Finlay.

5) Handle VXLAN ops outside of rcu lock, via a workqueue, in mlx5, since it
   can sleep.  Fix also from Matthew Finlay.

6) Check mdiobus_scan() return values properly in pxa168_eth and macb
   drivers.  From Sergei Shtylyov.

7) If the netdevice doesn't support checksumming, disable segmentation.
   From Alexandery Duyck.

8) Fix races between RDS tcp accept and sending, from Sowmini Varadhan.

9) In macb driver, probe MDIO bus before we register the netdev, otherwise
   we can try to open the device before it is really ready for that.  Fix
      from Florian Fainelli.

10) Netlink attribute size for ILA "tunnels" not calculated properly, fix
    from Nicolas Dichtel.

Please pull, thanks a lot!

The following changes since commit 33656a1f2ee5346c742d63ddd0e0970c95a56b70:

  Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs (2016-05-02 09:59:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 79e8dc8b80bff0bc5bbb90ca5e73044bf207c8ac:

  ipv6/ila: fix nlsize calculation for lwtunnel (2016-05-03 16:21:33 -0400)

----------------------------------------------------------------
Alexander Duyck (2):
      net: Disable segmentation if checksumming is not supported
      vxlan: Add checksum check to the features check function

Anna-Maria Gleixner (1):
      net: mvneta: Remove superfluous SMP function call

Antonio Quartulli (2):
      batman-adv: fix DAT candidate selection (must use vid)
      batman-adv: B.A.T.M.A.N V - make sure iface is reactivated upon NETDEV_UP event

David S. Miller (4):
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge
      Merge branch 'mlx5-fixes'
      Merge branch 'tunnel-csum-and-sg-offloads'
      Merge branch 'rds-fixes'

Florian Fainelli (1):
      net: macb: Probe MDIO bus before registering netdev

Gal Pressman (1):
      net/mlx5: Unmap only the relevant IO memory mapping

Matthew Finlay (3):
      net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue
      net/mlx5e: Implement a mlx5e workqueue
      net/mlx5e: Use workqueue for vxlan ops

Neil Horman (1):
      netem: Segment GSO packets on enqueue

Nicolas Dichtel (1):
      ipv6/ila: fix nlsize calculation for lwtunnel

Sergei Shtylyov (2):
      pxa168_eth: fix mdiobus_scan() error check
      macb: fix mdiobus_scan() error check

Sowmini Varadhan (2):
      RDS:TCP: Synchronize rds_tcp_accept_one with rds_send_xmit when resetting t_sock
      RDS: TCP: Synchronize accept() and connect() paths on t_conn_lock.

Sven Eckelmann (2):
      batman-adv: Fix reference counting of vlan object for tt_local_entry
      batman-adv: Fix reference counting of hardif_neigh_node object for neigh_node

 drivers/net/ethernet/cadence/macb.c               | 34 +++++++++++++++++++++-------------
 drivers/net/ethernet/marvell/mvneta.c             |  6 ++----
 drivers/net/ethernet/marvell/pxa168_eth.c         |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 34 +++++++++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/uar.c     |  6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c   | 50 ++++++++++++++++++++++++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 +++++++++--
 include/linux/if_ether.h                          |  5 +++++
 include/net/vxlan.h                               |  4 +++-
 net/batman-adv/bat_v.c                            | 12 ++++++++++++
 net/batman-adv/distributed-arp-table.c            | 17 ++++++++++-------
 net/batman-adv/hard-interface.c                   |  3 +++
 net/batman-adv/originator.c                       | 16 +++++-----------
 net/batman-adv/translation-table.c                | 42 ++++--------------------------------------
 net/batman-adv/types.h                            |  7 +++++++
 net/core/dev.c                                    |  2 +-
 net/ipv6/ila/ila_lwt.c                            |  3 +--
 net/rds/tcp.c                                     |  3 ++-
 net/rds/tcp.h                                     |  4 ++++
 net/rds/tcp_connect.c                             |  8 ++++++++
 net/rds/tcp_listen.c                              | 54 ++++++++++++++++++++++++++++++++++++------------------
 net/sched/sch_netem.c                             | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 24 files changed, 259 insertions(+), 127 deletions(-)
