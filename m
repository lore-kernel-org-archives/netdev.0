From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 21 Nov 2016 13:34:55 -0500 (EST)
Message-ID: <20161121.133455.984097712160891760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Clear congestion control state when changing algorithms on an
   existing socket, from Florian Westphal.

2) Fix register bit values in altr_tse_pcs portion of stmmac driver,
   from Jia Jie Ho.

3) Fix PTP handling in stammc driver for GMAC4, from Giuseppe
   CAVALLARO.

4) Fix udplite multicast delivery handling, it ignores the udp_table
   parameter passed into the lookups, from Pablo Neira Ayuso.

5) Synchronize the space estimated by rtnl_vfinfo_size and the space
   actually used by rtnl_fill_vfinfo.  From Sabrina Dubroca.

6) Fix memory leak in fib_info when splitting nodes, from Alexander
   Duyck.

7) If a driver does a napi_hash_del() explicitily and not via
   netif_napi_del(), it must perform RCU synchronization as needed.
   Fix this in virtio-net and bnxt drivers, from Eric Dumazet.

8) Likewise, it is not necessary to invoke napi_hash_del() is we are
   also doing neif_napi_del() in the same code path.  Remove such
   calls from be2net and cxgb4 drivers, also from Eric Dumazet.

9) Don't allocate an ID in peernet2id_alloc() if the netns is dead,
   from WANG Cong.

10) Fix OF node and device struct leaks in of_mdio, from Johan Hovold.

11) We cannot cache routes in ip6_tunnel when using inherited traffic
    classes, from Paolo Abeni.

12) Fix several crashes and leaks in cpsw driver, from Johan Hovold.

13) Splice operations cannot use freezable blocking calls in AF_UNIX,
    from WANG Cong.

14) Link dump filtering by master device and kind support added an
    error in loop index updates during the dump if we actually do
    filter, fix from Zhang Shengju.

Please pull, thanks a lot!

The following changes since commit e76d21c40bd6c67fd4e2c1540d77e113df962b4d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-11-14 14:15:53 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 7082c5c3f2407c52022507ffaf644dbbab97a883:

  tcp: zero ca_priv area when switching cc algorithms (2016-11-21 13:13:56 -0500)

----------------------------------------------------------------
Alex (1):
      net/phy/vitesse: Configure RGMII skew on VSC8601, if needed

Alexander Duyck (2):
      ipv4: Restore fib_trie_flush_external function and fix call ordering
      ipv4: Fix memory leak in exception case for splitting tries

Alexander Kochetkov (2):
      net: arc_emac: annonce IFF_MULTICAST support
      net: arc_emac: don't pass multicast packets to kernel in non-multicast mode

Alexey Khoroshilov (1):
      net: macb: add check for dma mapping error in start_xmit()

Benjamin Beichler (1):
      mac80211_hwsim: fix beacon delta calculation

David S. Miller (7):
      Merge branch 'stmmac-ptp'
      Merge branch 'fib-tables-fixes'
      Merge branch 'thunderx-fixes'
      Merge branch 'phy-dev-leaks'
      Merge branch 'cpsw-fixes'
      Merge tag 'mac80211-for-davem-2016-11-18' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'batadv-net-for-davem-20161119' of git://git.open-mesh.org/linux-merge

Eric Dumazet (5):
      gro_cells: mark napi struct as not busy poll candidates
      virtio-net: add a missing synchronize_net()
      be2net: do not call napi_hash_del()
      cxgb4: do not call napi_hash_del()
      bnxt: add a missing rcu synchronization

Felix Fietkau (4):
      Revert "mac80211: allow using AP_LINK_PS with mac80211-generated TIM IE"
      mac80211: update A-MPDU flag on tx dequeue
      mac80211: remove bogus skb vif assignment
      mac80211: fix A-MSDU aggregation with fast-xmit + txq

Filip Matusiak (1):
      mac80211: Ignore VHT IE from peer with wrong rx_mcs_map

Florian Fainelli (1):
      net: dsa: b53: Fix VLAN usage and how we treat CPU port

Florian Westphal (1):
      tcp: zero ca_priv area when switching cc algorithms

Gao Feng (1):
      net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit

Giuseppe CAVALLARO (3):
      stmmac: update the PTP header file
      stmmac: fix PTP support for GMAC4
      stmmac: fix PTP type ethtool stats

Guillaume Nault (1):
      l2tp: fix racy SOCK_ZAPPED flag check in l2tp_ip{,6}_bind()

Hangbin Liu (1):
      igmp: do not remove igmp souce list info when set link down

Jeremy Linton (1):
      net: sky2: Fix shutdown crash

Jia Jie Ho (1):
      net: ethernet: Fix SGMII unable to switch speed and autonego failure

Johan Hovold (10):
      of_mdio: fix node leak in of_phy_register_fixed_link error path
      of_mdio: fix device reference leak in of_phy_find_device
      net: phy: fixed_phy: fix of_node leak in fixed_phy_unregister
      net: ethernet: ti: cpsw: fix bad register access in probe error path
      net: ethernet: ti: cpsw: fix mdio device reference leak
      net: ethernet: ti: cpsw: fix deferred probe
      net: ethernet: ti: cpsw: fix of_node and phydev leaks
      net: ethernet: ti: cpsw: fix secondary-emac probe error path
      net: ethernet: ti: cpsw: add missing sanity check
      net: ethernet: ti: cpsw: fix fixed-link phy probe deferral

Johannes Berg (1):
      cfg80211: limit scan results cache size

Jon Paul Maloy (1):
      tipc: eliminate obsolete socket locking policy description

Josef Bacik (1):
      bpf: fix range arithmetic for bpf map access

Pablo Neira (1):
      udp: restore UDPlite many-cast delivery

Paolo Abeni (1):
      ip6_tunnel: disable caching when the traffic class is inherited

Pedersen, Thomas (1):
      cfg80211: add bitrate for 20MHz MCS 9

Peter Robinson (1):
      ethernet: stmmac: make DWMAC_STM32 depend on it's associated SoC

Radha Mohan Chintakuntla (1):
      net: thunderx: Introduce BGX_ID_MASK macro to extract bgx_id

Roman Mashak (1):
      net sched filters: pass netlink message flags in event notification

Sabrina Dubroca (3):
      rtnetlink: fix rtnl_vfinfo_size
      rtnetlink: fix rtnl message size computation for XDP
      rtnetlink: fix FDB size computation

Stefan Hajnoczi (1):
      netns: fix get_net_ns_by_fd(int pid) typo

Sunil Goutham (4):
      net: thunderx: Program LMAC credits based on MTU
      net: thunderx: Fix configuration of L3/L4 length checking
      net: thunderx: Fix VF driver's interface statistics
      net: thunderx: Fix memory leak and other issues upon interface toggle

Sven Eckelmann (2):
      batman-adv: Revert "fix splat on disabling an interface"
      batman-adv: Detect missing primaryif during tp_send as error

WANG Cong (2):
      net: check dead netns for peernet2id_alloc()
      af_unix: conditionally use freezable blocking calls in read

Zhang Shengju (1):
      rtnl: fix the loop index update error in rtnl_dump_ifinfo()

 drivers/net/dsa/b53/b53_common.c                      |  16 ++++----------
 drivers/net/ethernet/arc/emac_main.c                  |   7 +++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             |   4 ++++
 drivers/net/ethernet/cadence/macb.c                   |   6 ++++++
 drivers/net/ethernet/cavium/thunder/nic.h             |  64 ++++++++++++++++++++++++++++++------------------------
 drivers/net/ethernet/cavium/thunder/nic_main.c        |  37 ++++++++++++++++++++++----------
 drivers/net/ethernet/cavium/thunder/nic_reg.h         |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c   | 105 ++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c      | 153 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------------------------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c    | 118 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------------------------------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h    |  24 ++-------------------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c     |   4 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h     |   2 ++
 drivers/net/ethernet/chelsio/cxgb4/sge.c              |   1 -
 drivers/net/ethernet/emulex/benet/be_main.c           |   1 -
 drivers/net/ethernet/marvell/sky2.c                   |  13 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig           |   2 +-
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c    |   4 ++--
 drivers/net/ethernet/stmicro/stmmac/common.h          |  24 ++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/descs.h           |  20 ++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c    |  95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h    |   4 ++++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c        |  28 +++++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |   1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c  |  19 ++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c |  43 +++++++++++++++++++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  97 ++++++++++++++++++++++++++++++++++++++++++----------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c      |   9 ++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h      |  72 +++++++++++++++++++++++++++++++------------------------------
 drivers/net/ethernet/ti/cpsw.c                        |  95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/phy/fixed_phy.c                           |   2 +-
 drivers/net/phy/vitesse.c                             |  34 ++++++++++++++++++++++++++++-
 drivers/net/virtio_net.c                              |   5 +++++
 drivers/net/wireless/mac80211_hwsim.c                 |   2 +-
 drivers/of/of_mdio.c                                  |   6 +++++-
 include/linux/bpf_verifier.h                          |   5 +++--
 include/net/gro_cells.h                               |   3 +++
 include/net/ip_fib.h                                  |   1 +
 include/net/net_namespace.h                           |   2 +-
 kernel/bpf/verifier.c                                 |  70 ++++++++++++++++++++++++++++++++++++++++--------------------
 net/batman-adv/hard-interface.c                       |   1 +
 net/batman-adv/tp_meter.c                             |   1 +
 net/core/net_namespace.c                              |   2 ++
 net/core/rtnetlink.c                                  |  22 ++++++++++++-------
 net/ipv4/fib_frontend.c                               |  20 ++++++++++++-----
 net/ipv4/fib_trie.c                                   |  69 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/igmp.c                                       |  50 +++++++++++++++++++++++++++++++------------
 net/ipv4/tcp_cong.c                                   |   4 +++-
 net/ipv4/udp.c                                        |   6 +++---
 net/ipv6/ip6_tunnel.c                                 |  13 +++++++++--
 net/ipv6/udp.c                                        |   6 +++---
 net/l2tp/l2tp_eth.c                                   |   2 +-
 net/l2tp/l2tp_ip.c                                    |   5 +++--
 net/l2tp/l2tp_ip6.c                                   |   5 +++--
 net/mac80211/sta_info.c                               |   2 +-
 net/mac80211/tx.c                                     |  14 ++++++++----
 net/mac80211/vht.c                                    |  16 ++++++++++++++
 net/sched/cls_api.c                                   |   5 +++--
 net/tipc/socket.c                                     |  48 +----------------------------------------
 net/unix/af_unix.c                                    |  17 +++++++++------
 net/wireless/core.h                                   |   1 +
 net/wireless/scan.c                                   |  69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/wireless/util.c                                   |   3 ++-
 63 files changed, 1020 insertions(+), 560 deletions(-)
