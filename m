From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 01 Sep 2017 12:06:39 -0700 (PDT)
Message-ID: <20170901.120639.713876893010567301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix handling of pinned BPF map nodes in hash of maps, from Daniel
   Borkmann.

2) IPSEC ESP error paths leak memory, from Steffen Klassert.

3) We need an RCU grace period before freeing fib6_node objects,
   from Wei Wang.

4) Must check skb_put_padto() return value in HSR driver, from
   FLorian Fainelli.

5) Fix oops on PHY probe failure in ftgmac100 driver, from Andrew
   Jeffery.

6) Fix infinite loop in UDP queue when using SO_PEEK_OFF, from
   Eric Dumazet.

7) Use after free when tcf_chain_destroy() called multiple times,
   from Jiri Pirko.

8) Fix KSZ DSA tag layer multiple free of SKBS, from Florian
   Fainelli.

9) Fix leak of uninitialized memory in sctp_get_sctp_info(),
   inet_diag_msg_sctpladdrs_fill() and inet_diag_msg_sctpaddrs_fill().
   From Stefano Brivio.

10) L2TP tunnel refcount fixes from Guillaume Nault.

11) Don't leak UDP secpath in udp_set_dev_scratch(), from Yossi
    Kauperman.

12) Revert a PHY layer change wrt. handling of PHY_HALTED state
    in phy_stop_machine(), it causes regressions for multiple
    people.  From Florian Fainelli.

13) When packets are sent out of br0 we have to clear the offload_fwdq_mark
    value.

14) Several NULL pointer deref fixes in packet schedulers when their
    ->init() routine fails.  From Nikolay Aleksandrov.

15) Aquantium devices cannot checksum offload correctly when the packet
    is <= 60 bytes.  From Pavel Belous.

16) Fix vnet header access past end of buffer in AF_PACKET, from Benjamin
    Poirier.

17) Double free in probe error paths of nfp driver, from Dan Carpenter.

18) QOS capability not checked properly in DCB init paths of mlx5 driver,
    from Huy Nguyen.

19) Fix conflicts between firmware load failure and health_care timer
    in mlx5, also from Huy Nguyen.

20) Fix dangling page pointer when DMA mapping errors occur in mlx5,
    from Eran Ben ELisha.

21) ->ndo_setup_tc() in bnxt_en driver doesn't count rings properly, from
    Michael Chan.

22) Missing MSIX vector free in bnxt_en, also from Michael Chan.

23) Refcount leak in xfrm layer when using sk_policy, from Lorenzo
    Colitti.

24) Fix copy of uninitialized data in qlge driver, from Arnd Bergmann.

25) bpf_setsockopts() erroneously always returns -EINVAL even on
    success.  Fix from Yuchung Cheng.

26) tipc_rcv() needs to linearize the SKB before parsing the inner
    headers, from Parthasarathy Bhuvaragan.

27) Fix deadlock between link status updates and link removal in netvsc
    driver, from Stephen Hemminger.

28) Missed locking of page fragment handling in ESP output, from
    Steffen Klassert.

29) Fix refcnt leak in ebpf congestion control code, from Sabrina
    Dubroca.

30) sxgbe_probe_config_dt() doesn't check devm_kzalloc()'s return
    value, from Christophe Jaillet.

31) Fix missing ipv6 rx_dst_cookie update when rx_dst is updated
    during early demux, from Paolo Abeni.

32) Several info leaks in xfrm_user layer, from Mathias Krause.

33) Fix out of bounds read in cxgb4 driver, from Stefano Brivio.

34) Properly propagate obsolete state of route upwards in ipv6
    so that upper holders like xfrm can see it.  From Xin Long.

Please pull, thanks a lot!

The following changes since commit 6470812e22261d2342ef1597be62e63a0423d691:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2017-08-21 14:07:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to e8a732d1bc3ac313e22249c13a153c3fe54aa577:

  udp: fix secpath leak (2017-09-01 10:29:34 -0700)

----------------------------------------------------------------
Aleksander Morgado (1):
      cdc_ncm: flag the u-blox TOBY-L4 as wwan

Andrew Jeffery (1):
      net: ftgmac100: Fix oops in probe on failure to find associated PHY

Antoine Tenart (1):
      net: mvpp2: fix the mac address used when using PPv2.2

Arnd Bergmann (1):
      qlge: avoid memcpy buffer overflow

Benjamin Poirier (1):
      packet: Don't write vnet header beyond end of buffer

Bob Peterson (1):
      tipc: Fix tipc_sk_reinit handling of -EAGAIN

Christophe Jaillet (1):
      net: sxgbe: check memory allocation failure

Cong Wang (1):
      wl1251: add a missing spin_lock_init()

Dan Carpenter (1):
      nfp: double free on error in probe

Daniel Borkmann (1):
      bpf: fix map value attribute for hash of maps

David S. Miller (16):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'tipc-topology-server-fixes'
      Merge branch 'net-sched-couple-of-chain-fixes'
      Merge branch 'dst-tag-ksz-fix'
      Merge branch 'nfp-fixes'
      Merge branch 'bnxt_en-bug-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'tipc-buffer-reassignment-fixes'
      Merge branch 'r8169-Be-drop-monitor-friendly'
      Merge tag 'wireless-drivers-for-davem-2017-08-25' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'l2tp-tunnel-refs'
      Merge branch 'nfp-flow-dissector-layer'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'aquantia-fixes'
      Merge branch 'net-sched-init-failure-fixes'
      Merge tag 'mlx5-fixes-2017-08-30' of git://git.kernel.org/.../saeed/linux

Eran Ben Elisha (1):
      net/mlx5e: Fix dangling page pointer on DMA mapping error

Eric Dumazet (5):
      udp: on peeking bad csum, drop packets even if not at head
      net: dsa: use consume_skb()
      virtio_net: be drop monitor friendly
      net_sched: fix a refcount_t issue with noop_qdisc
      kcm: do not attach PF_KCM sockets to avoid deadlock

Florian Fainelli (13):
      net/hsr: Check skb_put_padto() return value
      net: phy: Deal with unbound PHY driver in phy_attached_print()
      fsl/man: Inherit parent device and of_node
      net: core: Specify skb_pad()/skb_put_padto() SKB freeing
      net: dsa: skb_put_padto() already frees nskb
      net: systemport: Be drop monitor friendly
      net: bcmgenet: Be drop monitor friendly
      net: systemport: Free DMA coherent descriptors on errors
      r8169: Do not increment tx_dropped in TX ring cleaning
      r8169: Be drop monitor friendly
      net: dsa: Don't dereference dst->cpu_dp->netdev
      net: dsa: bcm_sf2: Fix number of CFP entries for BCM7278
      Revert "net: phy: Correctly process PHY_HALTED in phy_stop_machine()"

Guillaume Nault (6):
      l2tp: initialise session's refcount before making it reachable
      l2tp: hold tunnel while looking up sessions in l2tp_netlink
      l2tp: hold tunnel while processing genl delete command
      l2tp: hold tunnel while handling genl tunnel updates
      l2tp: hold tunnel while handling genl TUNNEL_GET commands
      l2tp: hold tunnel used while creating sessions with netlink

Huy Nguyen (4):
      net/mlx5e: Check for qos capability in dcbnl_initialize
      net/mlx5e: Fix DCB_CAP_ATTR_DCBX capability for DCBNL getcap.
      net/mlx5: Skip mlx5_unload_one if mlx5_load_one fails
      net/mlx5: Remove the flag MLX5_INTERFACE_STATE_SHUTDOWN

Ido Schimmel (2):
      mlxsw: spectrum: Forbid linking to devices that have uppers
      bridge: switchdev: Clear forward mark when transmitting packet

Igor Russkikh (1):
      net:ethernet:aquantia: Fix for multicast filter handling.

Inbar Karmy (1):
      net/mlx5e: Don't override user RSS upon set channels

Jakub Kicinski (4):
      nfp: don't hold PF lock while enabling SR-IOV
      nfp: make sure representors are destroyed before their lower netdev
      nfp: avoid buffer leak when representor is missing
      nfp: TX time stamp packets before HW doorbell is rung

Jesper Dangaard Brouer (1):
      net: missing call of trace_napi_poll in busy_poll_stop

Jiri Pirko (2):
      net: sched: fix use after free when tcf_chain_destroy is called multiple times
      net: sched: don't do tcf_chain_flush from tcf_chain_destroy

Koichiro Den (1):
      xfrm: fix null pointer dereference on state and tmpl sort

Lorenzo Colitti (1):
      net: xfrm: don't double-hold dst when sk_policy in use.

Luca Coelho (1):
      iwlwifi: pcie: move rx workqueue initialization to iwl_trans_pcie_alloc()

Mathias Krause (4):
      xfrm_user: fix info leak in copy_user_offload()
      xfrm_user: fix info leak in xfrm_notify_sa()
      xfrm_user: fix info leak in build_expire()
      xfrm_user: fix info leak in build_aevent()

Maxime Ripard (1):
      net: stmmac: sun8i: Remove the compatibles

Michael Chan (3):
      bnxt_en: Fix .ndo_setup_tc() to include XDP rings.
      bnxt_en: Free MSIX vectors when unregistering the device from bnxt_re.
      bnxt_en: Do not setup MAC address in bnxt_hwrm_func_qcaps().

Moshe Shemesh (1):
      net/mlx5e: Fix inline header size for small packets

Nikolay Aleksandrov (9):
      sch_htb: fix crash on init failure
      sch_multiq: fix double free on init failure
      sch_hhf: fix null pointer dereference on init failure
      sch_hfsc: fix null pointer deref and double free on init failure
      sch_cbq: fix null pointer dereferences on init failure
      sch_fq_codel: avoid double free on init failure
      sch_netem: avoid null pointer deref on init failure
      sch_sfq: fix null pointer dereference on init failure
      sch_tbf: fix two null pointer dereferences on init failure

Noa Osherovich (1):
      net/mlx5: Fix arm SRQ command for ISSI version 0

Nogah Frankel (1):
      mlxsw: spectrum_switchdev: Fix mrouter flag update

Pablo Neira Ayuso (1):
      netfilter: nft_compat: check extension hook mask only if set

Paolo Abeni (1):
      udp6: set rx_dst_cookie on rx_dst updates

Parthasarathy Bhuvaragan (5):
      tipc: remove subscription references only for pending timers
      tipc: perform skb_linearize() before parsing the inner header
      tipc: reassign pointers after skb reallocation / linearization
      tipc: context imbalance at node read unlock
      tipc: permit bond slave as bearer

Paul Blakey (1):
      net/mlx5e: Properly resolve TC offloaded ipv6 vxlan tunnel source address

Pavel Belous (5):
      net:ethernet:aquantia: Extra spinlocks removed.
      net:ethernet:aquantia: Fix for number of RSS queues.
      net:ethernet:aquantia: Workaround for HW checksum bug.
      net:ethernet:aquantia: Fix for incorrect speed index.
      net:ethernet:aquantia: Show info message if bad firmware version detected.

Pieter Jansen van Vuuren (3):
      nfp: fix unchecked flow dissector use
      nfp: fix supported key layers calculation
      nfp: remove incorrect mask check for vlan matching

Quan Nguyen (1):
      drivers: net: xgene: Correct probe sequence handling

Roopa Prabhu (1):
      bridge: check for null fdb->dst before notifying switchdev drivers

Sabrina Dubroca (3):
      netfilter: ipt_CLUSTERIP: fix use-after-free of proc entry
      macsec: add genl family module alias
      tcp: fix refcnt leak with ebpf congestion control

Sekhar Nori (1):
      net: ti: cpsw-common: dont print error if ti_cm_get_macid() fails

Shahar Klein (1):
      net/mlx5: E-Switch, Unload the representors in the correct order

Stefano Brivio (3):
      ipv6: accept 64k - 1 packet length in ip6_find_1stfragopt()
      sctp: Avoid out-of-bounds reads from address storage
      cxgb4: Fix stack out-of-bounds read due to wrong size to t4_record_mbox()

Steffen Klassert (5):
      esp: Fix memleaks on error paths.
      esp: Fix error handling on layer 2 xmit.
      esp: Fix locking on page fragment allocation
      esp: Fix skb tailroom calculation
      ipv6: Fix may be used uninitialized warning in rt6_check

Stephan Gatzka (1):
      net: stmmac: socfgpa: Ensure emac bit set in sys manager for MII/GMII/SGMII.

Taehee Yoo (1):
      netfilter: x_tables: Fix use-after-free in ipt_do_table.

Tal Gilboa (1):
      net/mlx5e: Fix CQ moderation mode not set properly

Vladis Dronov (1):
      xfrm: policy: check policy direction value

Wei Wang (2):
      ipv6: add rcu grace period before freeing fib6_node
      ipv6: fix sparse warning on rt6i_node

Xin Long (3):
      netfilter: check for seqadj ext existence before adding it in nf_nat_setup_info
      ipv6: set dst.obsolete when a cached route has expired
      ipv6: do not set sk_destruct in IPV6_ADDRFORM sockopt

Ying Xue (1):
      tipc: fix a race condition of releasing subscriber object

Yossi Kuperman (1):
      udp: fix secpath leak

Yuchung Cheng (1):
      bpf: fix bpf_setsockopts return value

andy zhou (1):
      netfilter: nf_tables: Fix nft limit burst handling

stephen hemminger (1):
      netvsc: fix deadlock betwen link status and removal

 drivers/net/dsa/bcm_sf2.c                                    |   4 +++
 drivers/net/dsa/bcm_sf2.h                                    |   1 +
 drivers/net/dsa/bcm_sf2_cfp.c                                |   8 ++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c             |  27 ++++++++--------
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h               |   3 +-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c              |  92 ++++++++++++++++++++++++++-----------------------------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c             |   1 -
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h            |   1 -
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c              |  11 ++-----
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c    |   6 ++++
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c    |   6 ++++
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c |  10 ++++--
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h |   3 +-
 drivers/net/ethernet/broadcom/bcmsysport.c                   |   4 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                    |  41 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c                |   2 ++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c               |   6 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c                   |   6 ++--
 drivers/net/ethernet/faraday/ftgmac100.c                     |   1 -
 drivers/net/ethernet/freescale/fman/mac.c                    |   2 ++
 drivers/net/ethernet/marvell/mvpp2.c                         |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h                 |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c           |  24 +++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c         |   6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c            |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c              |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c              |   8 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c              |  17 ++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c               |   6 +---
 drivers/net/ethernet/mellanox/mlx5/core/srq.c                |  12 ++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c               |   6 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c     |  15 ++++++---
 drivers/net/ethernet/netronome/nfp/flower/match.c            | 139 ++++++++++++++++++++++++++++++++++++++++++-----------------------------------------
 drivers/net/ethernet/netronome/nfp/flower/offload.c          |  60 +++++++++++++++++++++++++-----------
 drivers/net/ethernet/netronome/nfp/nfp_main.c                |  16 +++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c          |  14 ++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c            |  26 +++++++++-------
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c                  |   2 +-
 drivers/net/ethernet/realtek/r8169.c                         |   5 ++-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c          |   2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c          |   5 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c            |   8 -----
 drivers/net/ethernet/ti/cpsw-common.c                        |   2 +-
 drivers/net/hyperv/netvsc_drv.c                              |   7 ++++-
 drivers/net/macsec.c                                         |   1 +
 drivers/net/phy/phy.c                                        |   3 --
 drivers/net/phy/phy_device.c                                 |   6 ++--
 drivers/net/usb/cdc_ncm.c                                    |   7 +++++
 drivers/net/virtio_net.c                                     |   2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h           |   2 ++
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c                 |  10 +-----
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c              |   9 ++++++
 drivers/net/wireless/ti/wl1251/main.c                        |   1 +
 include/linux/mlx5/driver.h                                  |   4 +--
 include/linux/netdevice.h                                    |   2 ++
 include/linux/skbuff.h                                       |  41 ++++++++++++++++++++++---
 include/net/ip6_fib.h                                        |  32 +++++++++++++++++--
 include/net/sch_generic.h                                    |   7 +++++
 include/net/tcp.h                                            |   4 +--
 include/net/udp.h                                            |   2 +-
 kernel/bpf/hashtab.c                                         |  30 ++++++++++--------
 net/bridge/br_device.c                                       |   3 ++
 net/bridge/br_switchdev.c                                    |   2 +-
 net/core/datagram.c                                          |   2 +-
 net/core/dev.c                                               |   4 ++-
 net/core/filter.c                                            |   8 ++---
 net/core/skbuff.c                                            |  13 +++++---
 net/dsa/dsa2.c                                               |   2 +-
 net/dsa/tag_ksz.c                                            |  12 +++++---
 net/dsa/tag_trailer.c                                        |   2 +-
 net/hsr/hsr_device.c                                         |   3 +-
 net/ipv4/esp4.c                                              |  20 +++++++-----
 net/ipv4/esp4_offload.c                                      |   2 +-
 net/ipv4/netfilter/arp_tables.c                              |  10 +++---
 net/ipv4/netfilter/ip_tables.c                               |   9 +++---
 net/ipv4/netfilter/ipt_CLUSTERIP.c                           |   4 ++-
 net/ipv4/tcp.c                                               |   2 +-
 net/ipv4/tcp_cong.c                                          |  19 +++++++++---
 net/ipv4/udp.c                                               |   6 ++--
 net/ipv6/addrconf.c                                          |   2 +-
 net/ipv6/esp6.c                                              |  16 +++++-----
 net/ipv6/esp6_offload.c                                      |   2 +-
 net/ipv6/ip6_fib.c                                           |  35 +++++++++++++++------
 net/ipv6/ipv6_sockglue.c                                     |   1 -
 net/ipv6/output_core.c                                       |   6 ++--
 net/ipv6/route.c                                             |  20 +++++++++---
 net/ipv6/udp.c                                               |  11 ++++++-
 net/kcm/kcmsock.c                                            |   4 +++
 net/l2tp/l2tp_core.c                                         |  72 ++++++++++++++-----------------------------
 net/l2tp/l2tp_core.h                                         |  13 ++++++++
 net/l2tp/l2tp_netlink.c                                      |  66 +++++++++++++++++++++++----------------
 net/netfilter/nf_nat_core.c                                  |   2 +-
 net/netfilter/nft_compat.c                                   |   4 +--
 net/netfilter/nft_limit.c                                    |  25 ++++++++-------
 net/packet/af_packet.c                                       |  12 ++++++--
 net/sched/cls_api.c                                          |  16 +++++++---
 net/sched/sch_api.c                                          |   6 ++--
 net/sched/sch_cbq.c                                          |  10 ++++--
 net/sched/sch_fq_codel.c                                     |   4 +--
 net/sched/sch_generic.c                                      |   2 +-
 net/sched/sch_hfsc.c                                         |  10 ++----
 net/sched/sch_hhf.c                                          |   3 ++
 net/sched/sch_htb.c                                          |   5 +--
 net/sched/sch_multiq.c                                       |   7 +----
 net/sched/sch_netem.c                                        |   4 +--
 net/sched/sch_sfq.c                                          |   6 ++--
 net/sched/sch_tbf.c                                          |   5 +--
 net/sctp/sctp_diag.c                                         |   7 +++--
 net/sctp/socket.c                                            |   3 +-
 net/tipc/bearer.c                                            |  26 +++++++---------
 net/tipc/bearer.h                                            |   2 ++
 net/tipc/msg.c                                               |   7 +++--
 net/tipc/node.c                                              |   4 ++-
 net/tipc/socket.c                                            |   6 ++--
 net/tipc/subscr.c                                            |  21 ++++++-------
 net/xfrm/xfrm_policy.c                                       |   7 ++++-
 net/xfrm/xfrm_state.c                                        |   8 +++++
 net/xfrm/xfrm_user.c                                         |   6 +++-
 119 files changed, 816 insertions(+), 559 deletions(-)
