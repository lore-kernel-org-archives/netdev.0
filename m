From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 25 Sep 2015 22:09:38 -0700 (PDT)
Message-ID: <20150925.220938.1544327563815442625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) When we run a tap on netlink sockets, we have to copy mmap'd SKBs
   instead of cloning them.  From Daniel Borkmann.

2) When converting classical BPF into eBPF, fix the setting of
   the source reg to BPF_REG_X.  From Tycho Andersen.

3) Fix igmpv3/mldv2 report parsing in the bridge multicast code,
   from Linus Lussing.

4) Fix dst refcounting for ipv6 tunnels, from Martin KaFai Lau.

5) Set NLM_F_REPLACE flag properly when replacing ipv6 routes,
   from Roopa Prabhu.

6) Add some new cxgb4 PCI device IDs, from Hariprasad Shenai.

7) Fix headroom tests and SKB leaks in ipv6 fragmentation code,
   from FLorian Westphal.

8) Check DMA mapping errors in bna driver, from Ivan Vecera.

9) Several 8139cp bug fixes (dev_kfree_skb_any in interrupt context,
   misclearing of interrupt status in TX timeout handler, etc.) from
   David Woodhouse.

10) In tipc, reset SKB header pointer after skb_linearize(), from
    Erik Hugne.

11) Fix autobind races et al. in netlink code, from Herbert Xu with
    help from Tejun Heo and others.

12) Missing SET_NETDEV_DEV in sunvnet driver, from Sowmini Varadhan.

13) Fix various races in timewait timer and reqsk_queue_hadh_req, from
    Eric Dumazet.

14) Fix array overruns in mac80211, from Johannes Berg and Dan
    Carpenter.

15) Fix data race in rhashtable_rehash_one(), from Dmitriy Vyukov.

16) Fix race between poll_one_napi and napi_disable, from Neil Horman.

17) Fix byte order in geneve tunnel port config, from John
    W. Linville.

18) Fix handling of ARP replies over lightweight tunnels, from Jiri
    Benc.

19) We can loop when fib rule dumps cross multiple SKBs, fix from
    Wilson Kok and Roopa Prabhu.

20) Several reference count handling bug fixes in the PHY/MDIO layer
    from Russel King.

21) Fix lockdep splat in ppp_dev_uninit(), from Guillaume Nault.

22) Fix crash in icmp_route_lookup(), from David Ahern.

Please pull, thanks a lot!

The following changes since commit 64d1def7d33856824d2c5c6fd6d4579d4d54=
bb87:

  Merge tag 'sound-fix-4.3-rc1' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/tiwai/sound (2015-09-11 09:42:32 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to bdb06cbf77cb01911694cc9076ffa8196b7b9b61=
:

  net: Fix panic in icmp_route_lookup (2015-09-25 21:44:02 -0700)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      irda: ali-ircc: Fix deadlock in ali_ircc_sir_change_speed()

Arnd Bergmann (1):
      bnx2x: use ktime_get_seconds() for timestamp

Daniel Borkmann (1):
      netlink, mmap: transform mmap skb into full skb on taps

David Ahern (3):
      net: Add documentation for VRF device
      net: Fix vti use case with oif in dst lookups
      net: Fix panic in icmp_route_lookup

David S. Miller (10):
      Merge branch 'ip6tunnel_dst'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'vxlan-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'net-of-autoload'
      Merge branch 'phy-of-autoload'
      Merge branch 'netcp-fixes'
      Merge branch 'lwt_arp'
      Merge tag 'mac80211-for-davem-2015-09-22' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'phy-mdio-refcnt'

David Woodhouse (10):
      solos-pci: Increase headroom on received packets
      8139cp: Use dev_kfree_skb_any() instead of dev_kfree_skb() in cp_=
clean_rings()
      8139cp: Call __cp_set_rx_mode() from cp_tx_timeout()
      Fix AF_PACKET ABI breakage in 4.2
      8139cp: Do not re-enable RX interrupts in cp_tx_timeout()
      8139cp: Fix tx_queued debug message to print correct slot numbers
      8139cp: Fix TSO/scatter-gather descriptor setup
      8139cp: Reduce duplicate csum/tso code in cp_start_xmit()
      8139cp: Fix DMA unmapping of transmitted buffers
      8139cp: Dump contents of descriptor ring on TX timeout

Dmitriy Vyukov (1):
      lib: fix data race in rhashtable_rehash_one

Eric Dumazet (6):
      net/mlx4_en: really allow to change RSS key
      tcp_cubic: do not set epoch_start in the future
      tcp/dccp: fix timewait races in timer handling
      inet: fix races in reqsk_queue_hash_req()
      tcp: add proper TS val into RST packets
      bnx2x: byte swap rss_key to comply to Toeplitz specs

Erik Hugne (1):
      tipc: reinitialize pointer after skb linearize

=46lorian Westphal (3):
      netfilter: nf_log: don't zap all loggers on unregister
      netfilter: bridge: fix routing of bridge frames with call-iptable=
s=3D1
      ipv6: ip6_fragment: fix headroom tests and skb leak

Guillaume Nault (1):
      ppp: fix lockdep splat in ppp_dev_uninit()

Hariprasad Shenai (1):
      cxgb4: add device ID for few T5 adapters

Herbert Xu (2):
      netlink: Fix autobind race condition that leads to zero port ID
      netlink: Replace rhash_portid with bound

Ivan Vecera (1):
      bna: check for dma mapping errors

Javier Martinez Canillas (1):
      net: ks8851: Export OF module alias information

Jesse Gross (2):
      openvswitch: Fix mask generation for nested attributes.
      openvswitch: Zero flows on allocation.

Jiri Benc (8):
      vxlan: set needed headroom correctly
      vxlan: reject IPv6 addresses if IPv6 is not configured
      qlcnic: track vxlan port count
      be2net: allow offloading with the same port for IPv4 and IPv6
      bnx2x: track vxlan port count
      MAINTAINERS: remove bouncing email address for qlcnic
      ipv4: send arp replies to the correct tunnel
      lwtunnel: remove source and destination UDP port config option

Joe Stringer (2):
      openvswitch: Fix dependency on IPv6 defrag.
      openvswitch: Fix IPv6 exthdr handling with ct helpers.

Johan Hedberg (1):
      Bluetooth: Delay check for conn->smp in smp_conn_security()

Johannes Berg (1):
      mac80211: fix VHT MCS mask array overrun

John W. Linville (3):
      geneve: remove vlan-related feature assignment
      geneve: ensure ECN info is handled properly in all tx/rx paths
      geneve: use network byte order for destination port config parame=
ter

Julia Lawall (3):
      atm: he: drop null test before destroy functions
      net: core: drop null test before destroy functions
      dccp: drop null test before destroy functions

Karicheri, Muralidharan (6):
      net: netcp: remove dead code from the driver
      net: netcp: move netcp_register_interface() to after attach modul=
e
      net: netcp: add error check to netcp_allocate_rx_buf()
      net: netcp: check for interface handle in netcp_module_probe()
      net: netcp: allocate buffers to desc before re-enable interrupt
      net: netcp: fix deadlock reported by lockup detector

Kevin Hao (1):
      Revert "net/phy: Add Vitesse 8641 phy ID"

Linus L=FCssing (1):
      bridge: fix igmpv3 / mldv2 report parsing

Luis de Bethencourt (7):
      net: arc: Fix module autoload for OF platform driver
      net: systemport: Fix module autoload for OF platform driver
      net: bcmgenet: Fix module autoload for OF platform driver
      net: gianfar_ptp: Fix module autoload for OF platform driver
      net: moxa: Fix module autoload for OF platform driver
      net: phy: mdio-bcm-unimac: Fix module autoload for OF platform dr=
iver
      net: phy: mdio-gpio: Fix module autoload for OF platform driver

Marcelo Ricardo Leitner (1):
      sctp: fix race on protocol/netns initialization

Martin KaFai Lau (5):
      ipv6: Refactor common ip6gre_tunnel_init codes
      ipv6: Rename the dst_cache helper functions in ip6_tunnel
      ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
      ipv6: Avoid double dst_free
      ipv6: Replace spinlock with seqlock and rcu in ip6_tunnel

Matt Bennett (2):
      ip6_gre: Reduce log level in ip6gre_err() to debug
      ip6_tunnel: Reduce log level in ip6_tnl_err() to debug

Matthew Garrett (1):
      usbnet: New driver for QinHeng CH9200 devices

Michael Grzeschik (2):
      ARCNET: fix hard_header_len limit
      MAINTAINERS: add arcnet and take maintainership

Michael S. Tsirkin (1):
      macvtap: fix TUNSETSNDBUF values > 64k

Neil Armstrong (1):
      net: dsa: Fix Marvell Egress Trailer check

Neil Horman (1):
      netpoll: Close race condition between poll_one_napi and napi_disa=
ble

Nicolas Dichtel (2):
      iptunnel: make rx/tx bytes counters consistent
      ip6tunnel: make rx/tx bytes counters consistent

Nikola Forr=F3 (1):
      net: Fix behaviour of unreachable, blackhole and prohibit routes

Pablo Neira Ayuso (2):
      netfilter: nft_compat: skip family comparison in case of NFPROTO_=
UNSPEC
      netfilter: nf_log: wait for rcu grace after logger unregistration

Phil Sutter (1):
      net: qdisc: enhance default_qdisc documentation

Pravin B Shelar (1):
      skbuff: Fix skb checksum flag on skb pull

Roopa Prabhu (2):
      rtnetlink: catch -EOPNOTSUPP errors from ndo_bridge_getlink
      ipv6: include NLM_F_REPLACE in route replace notifications

Russell King (12):
      net: dsa: actually force the speed on the CPU port
      phy: fix of_mdio_find_bus() device refcount leak
      net: dsa: fix of_mdio_find_bus() device refcount leak
      phy: fix mdiobus module safety
      phy: add proper phy struct device refcounting
      of_mdio: fix MDIO phy device refcounting
      net: fix phy refcounting in a bunch of drivers
      phy: fixed-phy: properly validate phy in fixed_phy_update_state()
      phy: add phy_device_remove()
      net: fix net_device refcounting
      phy: marvell: add link partner advertised modes
      net: update docbook comment for __mdiobus_register()

Sara Sharon (1):
      mac80211: reset CQM history upon reconfiguration

Sasha Levin (1):
      atm: deal with setting entry before mkip was called

Simon Guinot (1):
      net: mvneta: fix DMA buffer unmapping in mvneta_rx()

Sjoerd Simons (1):
      net: stmmac: Use msleep rather then udelay for reset delay

Sowmini Varadhan (1):
      sunvnet: Invoke SET_NETDEV_DEV() to set up the vdev in vnet_new()

Sudeep Holla (1):
      net: gianfar: remove misuse of IRQF_NO_SUSPEND flag

Sudip Mukherjee (1):
      net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI not selected

Taku Izumi (1):
      fjes: fix off-by-one error at fjes_hw_update_zone_task()

Tobias Klauser (1):
      ch9200: Convert to use module_usb_driver

Tycho Andersen (1):
      ebpf: emit correct src_reg for conditional jumps

WANG Cong (1):
      net: revert "net_sched: move tp->root allocation into fw_init()"

Wilson Kok (1):
      fib_rules: fix fib rule dumps across multiple skbs

WingMan Kwok (1):
      net: netcp: ethss: fix error in calling sgmii api with incorrect =
offset

 Documentation/networking/vrf.txt                   |  96 +++++++++++++
 Documentation/sysctl/net.txt                       |  16 ++-
 MAINTAINERS                                        |   9 +-
 drivers/atm/he.c                                   |   7 +-
 drivers/atm/solos-pci.c                            |  12 +-
 drivers/net/arcnet/arcnet.c                        |   2 +-
 drivers/net/dsa/mv88e6xxx.c                        |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  24 ++--
 drivers/net/ethernet/arc/emac_arc.c                |   1 +
 drivers/net/ethernet/broadcom/bcmsysport.c         |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  20 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |  12 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     |   1 +
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   2 +
 drivers/net/ethernet/brocade/bna/bna_types.h       |   1 +
 drivers/net/ethernet/brocade/bna/bnad.c            |  29 +++-
 drivers/net/ethernet/brocade/bna/bnad.h            |   2 +
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |   4 +
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |   5 +
 drivers/net/ethernet/emulex/benet/be.h             |   1 +
 drivers/net/ethernet/emulex/benet/be_main.c        |  10 ++
 drivers/net/ethernet/freescale/gianfar.c           |  15 +-
 drivers/net/ethernet/freescale/gianfar_ptp.c       |   1 +
 drivers/net/ethernet/freescale/ucc_geth.c          |   8 +-
 drivers/net/ethernet/marvell/mvneta.c              |   6 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   2 -
 drivers/net/ethernet/micrel/ks8851.c               |   1 +
 drivers/net/ethernet/moxa/moxart_ether.c           |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  18 ++-
 drivers/net/ethernet/realtek/8139cp.c              | 111 +++++++------=
-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |  11 +-
 drivers/net/ethernet/sun/sunvnet.c                 |  17 ++-
 drivers/net/ethernet/ti/netcp_core.c               |  74 +++++-----
 drivers/net/ethernet/ti/netcp_ethss.c              |  47 +++---
 drivers/net/ethernet/via/Kconfig                   |   2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |   2 +
 drivers/net/fjes/fjes_hw.c                         |   8 +-
 drivers/net/geneve.c                               |  32 ++---
 drivers/net/irda/ali-ircc.c                        |   6 -
 drivers/net/macvtap.c                              |   4 +-
 drivers/net/phy/fixed_phy.c                        |   2 +-
 drivers/net/phy/marvell.c                          |   9 ++
 drivers/net/phy/mdio-bcm-unimac.c                  |   1 +
 drivers/net/phy/mdio-gpio.c                        |   1 +
 drivers/net/phy/mdio-mux.c                         |  19 ++-
 drivers/net/phy/mdio_bus.c                         |  31 ++--
 drivers/net/phy/phy_device.c                       |  62 ++++++--
 drivers/net/phy/vitesse.c                          |  14 --
 drivers/net/ppp/ppp_generic.c                      |   4 +-
 drivers/net/usb/Kconfig                            |  11 ++
 drivers/net/usb/Makefile                           |   2 +-
 drivers/net/usb/ch9200.c                           | 432 +++++++++++++=
++++++++++++++++++++++++++++++++++++++++++
 drivers/net/vrf.c                                  |   3 +-
 drivers/net/vxlan.c                                |  15 +-
 drivers/of/of_mdio.c                               |  27 +++-
 include/linux/netdevice.h                          |   1 +
 include/linux/phy.h                                |   6 +-
 include/linux/skbuff.h                             |   9 +-
 include/net/flow.h                                 |   1 +
 include/net/inet_timewait_sock.h                   |  14 +-
 include/net/ip6_fib.h                              |   3 +-
 include/net/ip6_tunnel.h                           |  17 ++-
 include/net/ip_fib.h                               |  30 ++--
 include/net/ip_tunnels.h                           |   2 +
 include/net/route.h                                |   2 +-
 include/uapi/linux/lwtunnel.h                      |   4 -
 lib/rhashtable.c                                   |   5 +-
 net/atm/clip.c                                     |   3 +
 net/bluetooth/smp.c                                |  12 +-
 net/bridge/br_multicast.c                          |   4 +-
 net/core/dev.c                                     |   2 +
 net/core/fib_rules.c                               |  14 +-
 net/core/filter.c                                  |   2 +-
 net/core/net-sysfs.c                               |   9 ++
 net/core/netpoll.c                                 |  10 +-
 net/core/rtnetlink.c                               |  26 ++--
 net/core/sock.c                                    |  12 +-
 net/dccp/ackvec.c                                  |  12 +-
 net/dccp/ccid.c                                    |   3 +-
 net/dccp/minisocks.c                               |   4 +-
 net/dsa/dsa.c                                      |  41 +++++-
 net/dsa/tag_trailer.c                              |   2 +-
 net/ipv4/arp.c                                     |  39 +++--
 net/ipv4/fib_trie.c                                |   2 +-
 net/ipv4/icmp.c                                    |   4 +-
 net/ipv4/inet_connection_sock.c                    |   8 +-
 net/ipv4/inet_timewait_sock.c                      |  16 ++-
 net/ipv4/ip_tunnel_core.c                          |  54 +++----
 net/ipv4/route.c                                   |   6 +-
 net/ipv4/tcp_cubic.c                               |  10 +-
 net/ipv4/tcp_minisocks.c                           |  13 +-
 net/ipv4/tcp_output.c                              |   1 +
 net/ipv4/udp.c                                     |   3 +-
 net/ipv4/xfrm4_policy.c                            |   2 +
 net/ipv6/addrconf.c                                |   7 +-
 net/ipv6/ip6_fib.c                                 |  26 +++-
 net/ipv6/ip6_gre.c                                 |  93 +++++++-----
 net/ipv6/ip6_output.c                              |  14 +-
 net/ipv6/ip6_tunnel.c                              | 147 +++++++++++++=
------
 net/ipv6/route.c                                   |  16 ++-
 net/mac80211/cfg.c                                 |  13 +-
 net/netfilter/nf_log.c                             |   9 +-
 net/netfilter/nft_compat.c                         |  24 +++-
 net/netlink/af_netlink.c                           |  63 ++++++--
 net/netlink/af_netlink.h                           |  10 ++
 net/openvswitch/Kconfig                            |   3 +-
 net/openvswitch/conntrack.c                        |   8 +-
 net/openvswitch/datapath.c                         |   4 +-
 net/openvswitch/flow_netlink.c                     |  82 ++++++++---
 net/openvswitch/flow_table.c                       |  23 +--
 net/openvswitch/flow_table.h                       |   2 +-
 net/packet/af_packet.c                             |  32 +++--
 net/sched/cls_fw.c                                 |  30 ++--
 net/sctp/protocol.c                                |  64 ++++++---
 net/tipc/msg.c                                     |   1 +
 117 files changed, 1697 insertions(+), 639 deletions(-)
 create mode 100644 Documentation/networking/vrf.txt
 create mode 100644 drivers/net/usb/ch9200.c
