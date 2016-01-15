From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 15 Jan 2016 16:11:16 -0500 (EST)
Message-ID: <20160115.161116.1645643543977219799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A quick set of bug fixes after there initial networking merge:

1) Netlink multicast group storage allocator only was tested with nr_groups
   equal to 1, make it work for other values too. From Matti Vaittinen.

2) Check build_skb() return value in macb and hip04_eth drivers, from
   Weidong Wang.

3) Don't leak x25_asy on x25_asy_open() failure.

4) More DMA map/unmap fixes in 3c59x from Neil Horman.

5) Don't clobber IP skb control block during GSO segmentation, from
   Konstantin Khlebnikov.

6) ECN helpers for ipv6 don't fixup the checksum, from Eric Dumazet.

7) Fix SKB segment utilization estimation in xen-netback, from David
   Vrabel.

8) Fix lockdep splat in bridge addrlist handling, from Nikolay Aleksandrov.

Please pull, thanks a lot!

The following changes since commit 67990608c8b95d2b8ccc29932376ae73d5818727:

  Merge tag 'pm+acpi-4.5-rc1-1' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2016-01-12 20:25:09 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 750afbf8ee9c6a1c74a1fe5fc9852146b1d72687:

  bgmac: Fix reversed test of build_skb() return value. (2016-01-15 16:07:13 -0500)

----------------------------------------------------------------
Dan Carpenter (1):
      mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB

David S. Miller (8):
      Merge git://git.kernel.org/.../torvalds/linux
      genetlink: Fix off-by-one in genl_allocate_reserve_groups()
      x25_asy: Free x25_asy on x25_asy_open() failure.
      Merge branch '3c59x-dma-fixes'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge
      Merge branch 'hisi-fixes'
      Merge branch 'xen-netback-fixes'
      bgmac: Fix reversed test of build_skb() return value.

David Vrabel (3):
      xen-netback: use skb to determine number of required guest Rx requests
      xen-netback: delete NAPI instance when queue fails to initialize
      xen-netback: free queues after freeing the net device

Eric Dumazet (1):
      ipv6: update skb->csum when CE mark is propagated

Geert Uytterhoeven (1):
      net: sctp: Move sequence start handling into sctp_transport_get_idx()

Konstantin Khlebnikov (1):
      net: preserve IP control block during GSO segmentation

Markus Elfring (1):
      fsl/fman: Delete one function call "put_device" in dtsec_config()

Matti Vaittinen (1):
      net: netlink: Fix multicast group storage allocation for families with more than one groups

Nathan Sullivan (1):
      net: macb: clear interrupts when disabling them

Neil Horman (2):
      3c59x: balance page maps and unmaps
      3c59x: fix another page map/single unmap imbalance

Nikolay Aleksandrov (1):
      bridge: fix lockdep addr_list_lock false positive splat

Rabin Vincent (1):
      net: bpf: reject invalid shifts

Simon Wunderlich (1):
      batman-adv: fix lockdep splat when doing mcast_free

Sjoerd Simons (1):
      net: phy: turn carrier off on phy attach

Sven Eckelmann (1):
      batman-adv: Fix list removal of batadv_hardif_neigh_node

Xin Long (1):
      sctp: support to lookup with ep+paddr in transport rhashtable

Yoshinori Sato (1):
      net: smsc: Add support h8300

wangweidong (2):
      bgmac: fix a missing check for build_skb
      hip04_eth: fix missing error handle for build_skb failed

yankejian (2):
      dts: hisi: fixes no syscon fault when init mdio
      net: hns: fixes no syscon error when init mdio

 Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                      |  5 +++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi                  |  4 ++--
 drivers/net/ethernet/3com/3c59x.c                             |  9 +++++++--
 drivers/net/ethernet/broadcom/bgmac.c                         |  5 +++++
 drivers/net/ethernet/cadence/macb.c                           |  4 ++++
 drivers/net/ethernet/freescale/fman/fman_dtsec.c              |  1 -
 drivers/net/ethernet/hisilicon/hip04_eth.c                    |  5 ++++-
 drivers/net/ethernet/hisilicon/hns_mdio.c                     |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c      |  1 +
 drivers/net/ethernet/smsc/Kconfig                             |  4 ++--
 drivers/net/ethernet/smsc/smc91x.h                            | 11 +++++++++++
 drivers/net/phy/phy_device.c                                  |  5 +++++
 drivers/net/wan/x25_asy.c                                     |  4 +++-
 drivers/net/xen-netback/interface.c                           | 17 ++++++-----------
 drivers/net/xen-netback/netback.c                             | 20 +++++++++-----------
 include/linux/skbuff.h                                        |  3 ++-
 include/net/inet_ecn.h                                        | 19 ++++++++++++++++---
 net/batman-adv/multicast.c                                    |  2 ++
 net/batman-adv/originator.c                                   | 18 ++++++++++++------
 net/bridge/br_device.c                                        |  8 ++++++++
 net/core/dev.c                                                |  5 +++++
 net/ipv4/ip_output.c                                          |  1 +
 net/ipv6/xfrm6_mode_tunnel.c                                  |  2 +-
 net/netlink/genetlink.c                                       |  2 +-
 net/openvswitch/datapath.c                                    |  5 +----
 net/sctp/input.c                                              | 38 +++++++++++++++++++++++---------------
 net/sctp/proc.c                                               |  6 +++---
 net/xfrm/xfrm_output.c                                        |  2 ++
 29 files changed, 158 insertions(+), 66 deletions(-)
