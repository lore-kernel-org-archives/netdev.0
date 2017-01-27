From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 27 Jan 2017 12:25:02 -0500 (EST)
Message-ID: <20170127.122502.1284714928446657879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) GTP fixes from Andreas Schultz (missing genl module alias, clear IP
   DF on transmit).

2) Netfilter needs to reflect the fwmark when sending resets, from
   Pau Espin Pedrol.

3) nftable dump OOPS fix from Liping Zhang.

4) Fix erroneous setting of VIRTIO_NET_HDR_F_DATA_VALID on transmit,
   from Rolf Neugebauer.

5) Fix build error of ipt_CLUSTERIP when procfs is disabled, from Arnd
   Bergmann.

6) Fix regression in handling of NETIF_F_SG in harmonize_features(),
   from Eric Dumazet.

7) Fix RTNL deadlock wrt. lwtunnel module loading, from David Ahern.

8) tcp_fastopen_create_child() needs to setup tp->max_window, from
   Alexey Kodanev.

9) Missing kmemdup() failure check in ipv6 segment routing code, from
   Eric Dumazet.

10) Don't execute unix_bind() under the bindlock, otherwise we deadlock
    with splice.  From WANG Cong.

11) ip6_tnl_parse_tlv_enc_lim() potentially reallocates the skb buffer,
    therefore callers must reload cached header pointers into that
    skb.  Fix from Eric Dumazet.

12) Fix various bugs in legacy IRQ fallback handling in alx driver,
    from Tobias Regnery.

13) Do not allow lwtunnel drivers to be unloaded while they are
    referenced by active instances, from Robert Shearman.

14) Fix truncated PHY LED trigger names, from Geert Uytterhoeven.

15) Fix a few regressions from virtio_net XDP support, from John
    Fastabend and Jakub Kicinski.

Please pull, thanks a lot!

The following changes since commit 4b19a9e20bf99d62e1c47554f8eb2d9f520642ba:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-01-17 09:33:10 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 950eabbd6ddedc1b08350b9169a6a51b130ebaaf:

  ISDN: eicon: silence misleading array-bounds warning (2017-01-27 11:27:34 -0500)

----------------------------------------------------------------
Alexander Alemayhu (1):
      netfilter: nf_tables: fix spelling mistakes

Alexey Kodanev (1):
      tcp: initialize max window for a new fastopen socket

Alvaro G. M (1):
      net: phy: dp83848: add DP83620 PHY support

Andreas Schultz (3):
      gtp: add genl family modules alias
      gtp: clear DF bit on GTP packet tx
      gtp: fix cross netns recv on gtp socket

Arnd Bergmann (5):
      netfilter: ipt_CLUSTERIP: fix build error without procfs
      net/mlx5e: Remove unused variable
      qed: avoid possible stack overflow in qed_ll2_acquire_connection
      bcm63xx_enet: avoid uninitialized variable warning
      ISDN: eicon: silence misleading array-bounds warning

Balakrishnan Raman (1):
      vxlan: do not age static remote mac entries

Bjørn Mork (1):
      qmi_wwan/cdc_ether: add device ID for HP lt2523 (Novatel E371) WWAN card

Colin Ian King (1):
      net: sctp: fix array overrun read on sctp_timer_tbl

Daniel Borkmann (1):
      bpf: don't trigger OOM killer under pressure with map alloc

Daniel Gonzalez Cabanelas (1):
      net: phy: bcm63xx: Utilize correct config_intr function

David Ahern (2):
      lwtunnel: fix autoload of lwt modules
      net: mpls: Fix multipath selection for LSR use case

David S. Miller (17):
      Merge tag 'linux-can-fixes-for-4.10-20170118' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'ethtool-set-channels-fix'
      Merge branch 'xen-netback-leaks'
      Revert "net: sctp: fix array overrun read on sctp_timer_tbl"
      Merge branch 'amd-xgbe-fixes'
      Merge tag 'mac80211-for-davem-2017-01-24' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'ip6_tnl_parse_tlv_enc_lim-fixes'
      Merge branch 'vxlan-fdb-fixes'
      Merge branch 'alx-mq-fixes'
      Merge branch 'tipc-topology-fixes'
      Merge branch 'lwt-module-unload'
      Merge branch 'bnxt_en-rtnl-fixes'
      Merge branch 'phy-truncated-led-names'
      Merge branch 'r8152-napi-fixes'
      Merge tag 'batadv-net-for-davem-20170125' of git://git.open-mesh.org/linux-merge
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'gtp-fixes'

Einar Jón (1):
      can: c_can_pci: fix null-pointer-deref in c_can_start() - set device pointer

Eran Ben Elisha (3):
      net: ethtool: Initialize buffer when querying device channel settings
      net/mlx4_en: Remove unnecessary checks when setting num channels
      net/mlx5e: Remove unnecessary checks when setting num channels

Eric Dumazet (6):
      net: fix harmonize_features() vs NETIF_F_HIGHDMA
      gianfar: Do not reuse pages from emergency reserve
      ipv6: seg6_genl_set_tunsrc() must check kmemdup() return value
      net/mlx5e: Do not recycle pages from emergency reserve
      ip6_tunnel: must reload ipv6h in ip6ip6_tnl_xmit()
      ipv6: fix ip6_tnl_parse_tlv_enc_lim()

Florian Fainelli (3):
      net: phy: Avoid deadlock during phy_error()
      net: dsa: Check return value of phy_connect_direct()
      net: dsa: Bring back device detaching in dsa_slave_suspend()

Florian Westphal (2):
      netfilter: conntrack: remove GC_MAX_EVICTS break
      netfilter: conntrack: refine gc worker heuristics, redux

Geert Uytterhoeven (3):
      net: phy: leds: Clear phy_num_led_triggers on failure to avoid crash
      net: phy: leds: Break dependency of phy.h on phy_led_triggers.h
      net: phy: leds: Fix truncated LED trigger names

Hariprasad Shenai (1):
      MAINTAINERS: update cxgb4 maintainer

Ido Schimmel (1):
      mlxsw: spectrum_router: Correctly reallocate adjacency entries

Igor Druzhinin (2):
      xen-netback: fix memory leaks on XenBus disconnect
      xen-netback: protect resource cleaning on XenBus disconnect

Ivan Vecera (1):
      bridge: netlink: call br_changelink() during br_dev_newlink()

Jakub Kicinski (1):
      virtio_net: reject XDP programs using header adjustment

Jason Baron (1):
      tcp: correct memory barrier usage in tcp_check_space()

Jason Wang (1):
      virtio-net: restore VIRTIO_HDR_F_DATA_VALID on receiving

Jesper Dangaard Brouer (1):
      bpf: fix samples xdp_tx_iptunnel and tc_l2_redirect with fake KBUILD_MODNAME

Jingju Hou (1):
      net: phy: marvell: Add Wake from LAN support for 88E1510 PHY

Johannes Berg (1):
      mac80211: don't try to sleep in rate_control_rate_init()

John Crispin (2):
      Documentation: devicetree: change the mediatek ethernet compatible string
      net-next: ethernet: mediatek: change the compatible string

John Fastabend (1):
      virtio_net: use dev_kfree_skb for small buffer XDP receive

Julia Lawall (1):
      stmmac: add missing of_node_put

Kazuya Mizuguchi (1):
      ravb: unmap descriptors when freeing rings

Kefeng Wang (1):
      ipv6: addrconf: Avoid addrconf_disable_change() using RCU read-side lock

Lance Richardson (1):
      vxlan: fix byte order of vxlan-gpe port number

Lendacky, Thomas (2):
      amd-xgbe: Add a hardware quirk for register definitions
      amd-xgbe: Check xgbe_init() return code

Liping Zhang (4):
      netfilter: rpfilter: fix incorrect loopback packet judgment
      netfilter: nf_tables: fix possible oops when dumping stateful objects
      netfilter: nf_tables: validate the name size when possible
      netfilter: nft_log: restrict the log prefix length to 127

Martin Blumenstingl (1):
      Documentation: net: phy: improve explanation when to specify the PHY ID

Martin KaFai Lau (1):
      bpf: Fix test_lru_sanity5() in test_lru_map.c

Michael Chan (4):
      bnxt_en: Fix "uninitialized variable" bug in TPA code path.
      bnxt_en: Fix bnxt_reset() in the slow path task.
      bnxt_en: Fix RTNL lock usage on bnxt_update_link().
      bnxt_en: Fix RTNL lock usage on bnxt_get_port_module_status().

Michael S. Tsirkin (1):
      virtio_net: fix PAGE_SIZE > 64k

Pablo Neira (1):
      tcp: don't annotate mark on control socket from tcp_v6_send_response()

Pablo Neira Ayuso (3):
      netfilter: nf_tables: fix set->nelems counting with no NLM_F_EXCL
      netfilter: nf_tables: deconstify walk callback function
      netfilter: nf_tables: bump set->ndeact on set flush

Parthasarathy Bhuvaragan (6):
      tipc: fix nametbl_lock soft lockup at node/link events
      tipc: add subscription refcount to avoid invalid delete
      tipc: fix connection refcount error
      tipc: fix nametbl_lock soft lockup at module exit
      tipc: ignore requests when the connection state is not CONNECTED
      tipc: fix cleanup at module unload

Pau Espin Pedrol (2):
      netfilter: use fwmark_reflect in nf_send_reset
      tcp: fix mark propagation with fwmark_reflect enabled

Robert Shearman (2):
      net: Specify the owning module for lwtunnel ops
      lwtunnel: Fix oops on state free after encap module unload

Rolf Neugebauer (1):
      virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit

Roopa Prabhu (1):
      vxlan: don't flush static fdb entries on admin down

Sean Nyekjaer (1):
      net: phy: micrel: add support for KSZ8795

Sven Eckelmann (1):
      batman-adv: Decrease hardif refcnt on fragmentation send error

Thomas Huth (1):
      ibmveth: Add a proper check for the availability of the checksum features

Tobias Regnery (3):
      alx: fix wrong condition to free descriptor memory
      alx: fix fallback to msi or legacy interrupts
      alx: work around hardware bug in interrupt fallback path

Vineeth Remanan Pillai (1):
      xen-netfront: Fix Rx stall during network stress and OOM

WANG Cong (1):
      af_unix: move unix_mknod() out of bindlock

William Breathitt Gray (1):
      netfilter: Fix typo in NF_CONNTRACK Kconfig option description

Xin Long (2):
      sctp: sctp_addr_id2transport should verify the addr before looking up assoc
      sctp: sctp gso should set feature with NETIF_F_SG when calling skb_segment

Yegor Yefremov (1):
      can: ti_hecc: add missing prepare and unprepare of the clock

hayeswang (6):
      r8152: fix rtl8152_post_reset function
      r8152: don't execute runtime suspend if the tx is not empty
      r8152: avoid start_xmit to call napi_schedule during autosuspend
      r8152: avoid start_xmit to schedule napi when napi is disabled
      r8152: re-schedule napi for tx
      r8152: check rx after napi is enabled

 Documentation/devicetree/bindings/net/mediatek-net.txt |   2 +-
 Documentation/devicetree/bindings/net/phy.txt          |   5 +++--
 MAINTAINERS                                            |   2 +-
 drivers/isdn/hardware/eicon/message.c                  |   3 ++-
 drivers/net/can/c_can/c_can_pci.c                      |   1 +
 drivers/net/can/ti_hecc.c                              |  16 +++++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-common.h            |   2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c               |   8 +++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               |   4 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c               |  15 +++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h                   |   2 ++
 drivers/net/ethernet/atheros/alx/main.c                |  11 +++++++---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c           |   6 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c              |  80 +++++++++++++++++++++++++++++++++++++++++------------------------------
 drivers/net/ethernet/freescale/gianfar.c               |   2 +-
 drivers/net/ethernet/ibm/ibmveth.c                     |   7 +++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.c            |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c        |   7 +------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  11 ----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c        |   3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c  |  10 +++++----
 drivers/net/ethernet/qlogic/qed/qed_ll2.c              |  88 ++++++++++++++++++++++++++++++++++---------------------------------------------
 drivers/net/ethernet/qlogic/qed/qed_ll2.h              |  24 +++++++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_roce.c             |   2 +-
 drivers/net/ethernet/renesas/ravb_main.c               | 112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
 drivers/net/gtp.c                                      |  13 ++++++------
 drivers/net/macvtap.c                                  |   2 +-
 drivers/net/phy/bcm63xx.c                              |  21 +++++++++++++++++--
 drivers/net/phy/dp83848.c                              |   3 +++
 drivers/net/phy/marvell.c                              |   2 ++
 drivers/net/phy/micrel.c                               |  14 +++++++++++++
 drivers/net/phy/phy.c                                  |  15 +++++++++-----
 drivers/net/phy/phy_led_triggers.c                     |   9 ++++++--
 drivers/net/tun.c                                      |   2 +-
 drivers/net/usb/cdc_ether.c                            |   8 ++++++++
 drivers/net/usb/qmi_wwan.c                             |   7 +++++++
 drivers/net/usb/r8152.c                                |  34 +++++++++++++++++++++++++------
 drivers/net/virtio_net.c                               |  25 +++++++++++++++++++----
 drivers/net/vxlan.c                                    |  12 +++++++----
 drivers/net/xen-netback/interface.c                    |   6 ++++--
 drivers/net/xen-netback/xenbus.c                       |  13 ++++++++++++
 drivers/net/xen-netfront.c                             |   2 +-
 include/linux/bpf.h                                    |   2 ++
 include/linux/micrel_phy.h                             |   2 ++
 include/linux/phy.h                                    |   1 -
 include/linux/phy_led_triggers.h                       |   4 ++--
 include/linux/virtio_net.h                             |   6 ++++--
 include/net/ipv6.h                                     |   2 +-
 include/net/lwtunnel.h                                 |  13 ++++++++++++
 include/net/netfilter/nf_tables.h                      |   6 +++---
 include/net/netfilter/nft_fib.h                        |   6 ++++++
 include/uapi/linux/netfilter/nf_log.h                  |   2 ++
 include/uapi/linux/netfilter/nf_tables.h               |   4 ++--
 kernel/bpf/arraymap.c                                  |  18 +++++++---------
 kernel/bpf/hashtab.c                                   |  22 ++++++++------------
 kernel/bpf/stackmap.c                                  |  20 ++++++++----------
 kernel/bpf/syscall.c                                   |  26 ++++++++++++++++++++++++
 net/batman-adv/fragmentation.c                         |  10 ++++-----
 net/bridge/br_netlink.c                                |  33 +++++++++++++++++-------------
 net/core/dev.c                                         |   4 ++--
 net/core/ethtool.c                                     |   2 +-
 net/core/lwt_bpf.c                                     |   1 +
 net/core/lwtunnel.c                                    |  66 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 net/dccp/ipv6.c                                        |   4 ++--
 net/dsa/slave.c                                        |   8 ++++----
 net/ipv4/fib_frontend.c                                |   8 ++++++++
 net/ipv4/ip_output.c                                   |   1 +
 net/ipv4/ip_tunnel_core.c                              |   2 ++
 net/ipv4/netfilter/ipt_CLUSTERIP.c                     |   7 ++++++-
 net/ipv4/netfilter/ipt_rpfilter.c                      |   8 ++++----
 net/ipv4/netfilter/nf_reject_ipv4.c                    |   2 ++
 net/ipv4/netfilter/nft_fib_ipv4.c                      |  15 +++++---------
 net/ipv4/tcp_fastopen.c                                |   1 +
 net/ipv4/tcp_input.c                                   |   2 +-
 net/ipv6/addrconf.c                                    |   4 +---
 net/ipv6/ila/ila_lwt.c                                 |   1 +
 net/ipv6/inet6_connection_sock.c                       |   2 +-
 net/ipv6/ip6_gre.c                                     |   3 +++
 net/ipv6/ip6_output.c                                  |   4 ++--
 net/ipv6/ip6_tunnel.c                                  |  36 +++++++++++++++++++++-----------
 net/ipv6/netfilter/ip6t_rpfilter.c                     |   8 ++++----
 net/ipv6/netfilter/nf_reject_ipv6.c                    |   3 +++
 net/ipv6/netfilter/nft_fib_ipv6.c                      |  13 ++++--------
 net/ipv6/route.c                                       |  12 ++++++++++-
 net/ipv6/seg6.c                                        |   2 ++
 net/ipv6/seg6_iptunnel.c                               |   1 +
 net/ipv6/tcp_ipv6.c                                    |   4 ++--
 net/mac80211/rate.c                                    |   2 --
 net/mpls/af_mpls.c                                     |  48 ++++++++++++++++++++++---------------------
 net/mpls/mpls_iptunnel.c                               |   1 +
 net/netfilter/Kconfig                                  |   2 +-
 net/netfilter/nf_conntrack_core.c                      |  44 +++++++++++++++++++---------------------
 net/netfilter/nf_log.c                                 |   1 -
 net/netfilter/nf_tables_api.c                          |  67 +++++++++++++++++++++++++++++++++++-------------------------
 net/netfilter/nft_dynset.c                             |   3 ++-
 net/netfilter/nft_log.c                                |   3 ++-
 net/netfilter/nft_lookup.c                             |   3 ++-
 net/netfilter/nft_objref.c                             |   6 ++++--
 net/netfilter/nft_set_hash.c                           |   2 +-
 net/netfilter/nft_set_rbtree.c                         |   2 +-
 net/packet/af_packet.c                                 |   4 ++--
 net/sctp/ipv6.c                                        |   3 ++-
 net/sctp/offload.c                                     |   2 +-
 net/sctp/socket.c                                      |   6 +++++-
 net/tipc/node.c                                        |   9 ++++++--
 net/tipc/server.c                                      |  48 +++++++++++++++++++------------------------
 net/tipc/subscr.c                                      | 124 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------------
 net/tipc/subscr.h                                      |   1 +
 net/unix/af_unix.c                                     |  27 ++++++++++++++----------
 samples/bpf/tc_l2_redirect_kern.c                      |   1 +
 samples/bpf/xdp_tx_iptunnel_kern.c                     |   1 +
 tools/testing/selftests/bpf/test_lru_map.c             |  53 ++++++++++++++++++++++++------------------------
 113 files changed, 916 insertions(+), 562 deletions(-)
