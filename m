From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 28 Mar 2014 17:38:35 -0400 (EDT)
Message-ID: <20140328.173835.768770272285036750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) We've discovered a common error in several networking drivers, they
   put VLAN offload features into ->vlan_features, which would suggest
   that they support offloading 2 or more levels of VLAN encapsulation.
   Not only do these devices not do that, but we don't have the
   infrastructure yet to handle that at all.

   Fixes from Vlad Yasevich.

2) Fix tcpdump crash with bridging and vlans, also from Vlad.

3) Some MAINTAINERS updates for random32 and bonding.

4) Fix late reseeds of prandom generator, from Sasha Levin.

5) Bridge doesn't handle stacked vlans properly, fix from Toshiaki
   Makita.

6) Fix deadlock in openvswitch, from Flavio Leitner.

7) get_timewait4_sock() doesn't report delay times correctly, fix
   from Eric Dumazet.

8) Duplicate address detection and addrconf verification need to
   run in contexts where RTNL can be obtained.  Move them to run
   from a workqueue.  From Hannes Frederic Sowa.

9) Fix route refcount leaking in ip tunnels, from Pravin B Shelar.

10) Don't return -EINTR from non-blocking recvmsg() on AF_UNIX
    sockets, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 632b06aa2842b12c6d6a510ec080fb6ebdb38ea5:

  Merge branch 'nfsd-next' of git://linux-nfs.org/~bfields/linux (2014-03-25 15:24:11 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 5f2feca20e0f4878fa16787bd50fcd82fb365be7:

  Merge branch 'vlan_offloads' (2014-03-28 17:17:16 -0400)

----------------------------------------------------------------

David S. Miller (2):
      Merge branch 'mvneta'
      Merge branch 'vlan_offloads'

Eric Dumazet (2):
      net: unix: non blocking recvmsg() should not return -EINTR
      tcp: fix get_timewait4_sock() delay computation on 64bit

Flavio Leitner (1):
      openvswitch: fix a possible deadlock and lockdep warning

Hannes Frederic Sowa (1):
      ipv6: move DAD and addrconf_verify processing to workqueue

Jason Wang (1):
      virtio-net: correct error handling of virtqueue_kick()

Jay Vosburgh (1):
      MAINTAINERS: bonding: change email address

Michael S. Tsirkin (2):
      vhost: fix total length when packets are too short
      vhost: validate vhost_get_vq_desc return value

Oliver Neukum (1):
      usbnet: include wait queue head in device structure

Pravin B Shelar (1):
      ip_tunnel: Fix dst ref-count.

Sasha Levin (2):
      random32: assign to network folks in MAINTAINERS
      random32: avoid attempt to late reseed if in the middle of seeding

Thomas Petazzoni (3):
      net: mvneta: rename MVNETA_GMAC2_PSC_ENABLE to MVNETA_GMAC2_PCS_ENABLE
      net: mvneta: fix usage as a module on RGMII configurations
      net: mvneta: use devm_ioremap_resource() instead of of_iomap()

Toshiaki Makita (2):
      bridge: Fix inabillity to retrieve vlan tags when tx offload is disabled
      bridge: Fix handling stacked vlan tags

Veaceslav Falico (1):
      MAINTAINERS: bonding: change email address

Vlad Yasevich (8):
      tg3: Do not include vlan acceleration features in vlan_features
      vlan: Set hard_header_len according to available acceleration
      net: Account for all vlan headers in skb_mac_gso_segment
      bridge: Fix crash with vlan filtering and tcpdump
      qlge: Do not propaged vlan tag offloads to vlans
      ifb: Remove vlan acceleration from vlan_features
      veth: Turn off vlan rx acceleration in vlan_features
      vlan: Warn the user if lowerdev has bad vlan features.

Wei Yang (1):
      net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset

Zoltan Kiss (1):
      core, nfqueue, openvswitch: Orphan frags in skb_zerocopy and handle errors

 MAINTAINERS                                  |   5 ++-
 drivers/net/ethernet/broadcom/tg3.c          |   5 +--
 drivers/net/ethernet/marvell/mvneta.c        |  60 +++++++++-----------------
 drivers/net/ethernet/mellanox/mlx4/main.c    |   6 ++-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   4 +-
 drivers/net/ifb.c                            |   3 +-
 drivers/net/usb/usbnet.c                     |  33 ++++++++------
 drivers/net/veth.c                           |   5 ++-
 drivers/net/virtio_net.c                     |   6 +--
 drivers/vhost/net.c                          |  20 ++++++++-
 include/linux/netdev_features.h              |   7 +++
 include/linux/netdevice.h                    |   2 +-
 include/linux/skbuff.h                       |   4 +-
 include/linux/usb/usbnet.h                   |   2 +-
 include/net/if_inet6.h                       |   4 +-
 lib/random32.c                               |  13 +++++-
 net/8021q/vlan.c                             |   4 +-
 net/8021q/vlan_dev.c                         |   6 ++-
 net/bridge/br_device.c                       |   6 +--
 net/bridge/br_input.c                        |  11 ++---
 net/bridge/br_vlan.c                         |  44 +++++++++++--------
 net/core/dev.c                               |  13 ++++--
 net/core/skbuff.c                            |  30 +++++++++----
 net/ipv4/gre_demux.c                         |   8 ++++
 net/ipv4/ip_tunnel.c                         |   3 --
 net/ipv4/ip_tunnel_core.c                    |   1 +
 net/ipv4/tcp_ipv4.c                          |   2 +-
 net/ipv6/addrconf.c                          | 193 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------
 net/netfilter/nfnetlink_queue_core.c         |   9 +++-
 net/openvswitch/datapath.c                   |   6 ++-
 net/openvswitch/flow.c                       |  26 +++--------
 net/unix/af_unix.c                           |  17 +++++---
 32 files changed, 363 insertions(+), 195 deletions(-)
