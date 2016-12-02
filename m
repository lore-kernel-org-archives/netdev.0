From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 02 Dec 2016 14:40:27 -0500 (EST)
Message-ID: <20161202.144027.865199162953716867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Lots more phydev and probe error path leaks in various drivers by
   Johan Hovold.

2) Fix race in packet_set_ring(), from Philip Pettersson.

3) Use after free in dccp_invalid_packet(), from Eric Dumazet.

4) Signnedness overflow in SO_{SND,RCV}BUFFORCE, also from Eric
   Dumazet.

5) When tunneling between ipv4 and ipv6 we can be left with the wrong
   skb->protocol value as we enter the IPSEC engine and this causes
   all kinds of problems.  Set it before the output path does any
   dst_output() calls, from Eli Cooper.

6) bcmgenet uses wrong device struct pointer in DMA API calls,
   fix from Florian Fainelli.

7) Various netfilter nat bug fixes from FLorian Westphal.

8) Fix memory leak in ipvlan_link_new(), from Gao Feng.

9) Locking fixes, particularly wrt. socket lookups, in l2tp from
   Guillaume Nault.

10) Avoid invoking rhash teardowns in atomic context by moving
    netlink cb->done() dump completion from a worker thread.  Fix
    from Herbert Xu.

11) Buffer refcount problems in tun and macvtap on errors, from
    Jason Wang.

12) We don't set Kconfig symbol DEFAULT_TCP_CONG properly when the
    user selects BBR.  Fix from Julian Wollrath.

13) Fix deadlock in transmit path on altera TSE driver, from Lino
    Sanfilippo.

14) Fix unbalanced reference counting in dsa_switch_tree, from Nikita
    Yushchenko.

15) tc_tunnel_key needs to be properly exported to userspace via uapi,
    fix from Roi Dayan.

16) rds_tcp_init_net() doesn't unregister notifier in error path, fix
    from Sowmini Varadhan.

17) Stale packet header pointer access after pskb_expand_head() in
    genenve driver, fix from Sabrina Dubroca.

Please pull, thanks a lot!

The following changes since commit d8e435f3ab6fea2ea324dce72b51dd7761747523:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs (2016-11-26 17:21:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to b98b0bc8c431e3ceb4b26b0dfc8db509518fb290:

  net: avoid signed overflows for SO_{SND|RCV}BUFFORCE (2016-12-02 14:10:14 -0500)

----------------------------------------------------------------
Alexander Duyck (2):
      igb/igbvf: Don't use lco_csum to compute IPv4 checksum
      ixgbe/ixgbevf: Don't use lco_csum to compute IPv4 checksum

Amir Vadai (1):
      net/sched: pedit: make sure that offset is valid

Anders K. Pedersen (1):
      netfilter: nf_tables: fix inconsistent element expiration calculation

Arnaldo Carvalho de Melo (1):
      GSO: Reload iph after pskb_may_pull

Arnd Bergmann (1):
      irda: fix overly long udelay()

Artem Savkov (1):
      ip6_offload: check segs for NULL in ipv6_gso_segment.

Borislav Petkov (1):
      amd-xgbe: Fix unused suspend handlers build warning

Brian Norris (1):
      mwifiex: printk() overflow with 32-byte SSIDs

Chris Brandt (1):
      sh_eth: remove unchecked interrupts for RZ/A1

Cyrille Pitchen (1):
      net: macb: fix the RX queue reset in macb_rx()

Dan Carpenter (1):
      net: renesas: ravb: unintialized return value

Daniel Borkmann (1):
      net, sched: respect rcu grace period on cls destruction

Daniele Di Proietto (1):
      openvswitch: Fix skb leak in IPv6 reassembly.

Daniele Palmas (1):
      NET: usb: qmi_wwan: add support for Telit LE922A PID 0x1040

David Ahern (3):
      netfilter: Update ip_route_me_harder to consider L3 domain
      netfilter: Update nf_send_reset6 to consider L3 domain
      net: handle no dst on skb in icmp6_send

David S. Miller (11):
      Merge branch 'more-phydev-leaks'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'fix-RTL8211F-TX-delay-handling'
      Merge branch 'mlx4-fixes'
      Merge branch 'fixed-phy-phydev-leaks'
      Merge branch 'l2tp-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-11-29' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'stmmac-probe-error-handling-and-phydev-leaks'
      Merge tag 'linux-can-fixes-for-4.9-20161201' of git://git.kernel.org/.../mkl/linux-can

Eli Cooper (3):
      ipv4: Set skb->protocol properly for local output
      ipv6: Set skb->protocol properly for local output
      Revert: "ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"

Eric Dumazet (2):
      net/dccp: fix use-after-free in dccp_invalid_packet
      net: avoid signed overflows for SO_{SND|RCV}BUFFORCE

Florian Fainelli (1):
      net: bcmgenet: Utilize correct struct device for all DMA operations

Florian Westphal (6):
      xfrm: unbreak xfrm_sk_policy_lookup
      netfilter: fix nf_conntrack_helper documentation
      netfilter: nat: fix cmp return value
      netfilter: nat: switch to new rhlist interface
      netfilter: nat: fix crash when conntrack entry is re-used
      netfilter: ipv6: nf_defrag: drop mangled skb on ream error

Gao Feng (2):
      driver: ipvlan: Fix one possible memleak in ipvlan_link_new
      driver: macvtap: Unregister netdev rx_handler if macvtap_newlink fails

Grygorii Strashko (1):
      net: ethernet: ti: cpsw: fix ASSERT_RTNL() warning during resume

Guillaume Nault (5):
      l2tp: lock socket before checking flags in connect()
      l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()
      l2tp: fix racy socket lookup in l2tp_ip and l2tp_ip6 bind()
      l2tp: fix lookup for sockets not bound to a device in l2tp_ip
      l2tp: fix address test in __l2tp_ip6_bind_lookup()

Haishuang Yan (1):
      vxlan: fix a potential issue when create a new vxlan fdb entry.

Hariprasad Shenai (1):
      cxgb4: Add PCI device ID for new adapter

Herbert Xu (1):
      netlink: Call cb->done from a worker thread

Hongxu Jia (1):
      netfilter: arp_tables: fix invoking 32bit "iptable -P INPUT ACCEPT" failed in 64bit kernel

Jack Morgenstein (1):
      net/mlx4: Fix uninitialized fields in rule when adding promiscuous mode to device managed flow steering

Jason Wang (2):
      tun: handle ubuf refcount correctly when meet errors
      macvtap: handle ubuf refcount correctly when meet errors

Jiri Pirko (1):
      sched: cls_flower: remove from hashtable only in case skip sw flag is not set

Johan Hovold (28):
      net: dsa: fix fixed-link-phy device leaks
      net: bcmgenet: fix phydev reference leak
      net: fsl/fman: fix phydev reference leak
      net: fsl/fman: fix fixed-link-phydev reference leak
      net: qcom/emac: fix of_node and phydev leaks
      net: dsa: slave: fix of-node leak and phy priority
      of_mdio: add helper to deregister fixed-link PHYs
      net: ethernet: altera: fix fixed-link phydev leaks
      net: ethernet: aurora: nb8800: fix fixed-link phydev leaks
      net: ethernet: bcmsysport: fix fixed-link phydev leaks
      net: ethernet: bcmgenet: fix fixed-link phydev leaks
      net: ethernet: fec: fix fixed-link phydev leaks
      net: ethernet: fs_enet: fix fixed-link phydev leaks
      net: ethernet: gianfar: fix fixed-link phydev leaks
      net: ethernet: ucc_geth: fix fixed-link phydev leaks
      net: ethernet: marvell: mvneta: fix fixed-link phydev leaks
      net: ethernet: mediatek: fix fixed-link phydev leaks
      net: ethernet: renesas: ravb: fix fixed-link phydev leaks
      net: ethernet: dwc_eth_qos: fix fixed-link phydev leaks
      net: ethernet: ti: davinci_emac: fix fixed-link phydev and of-node leaks
      net: dsa: slave: fix fixed-link phydev leaks
      net: ethernet: stmmac: dwmac-socfpga: fix use-after-free on probe errors
      net: ethernet: stmmac: dwmac-sti: fix probe error path
      net: ethernet: stmmac: dwmac-rk: fix probe error path
      net: ethernet: stmmac: dwmac-generic: fix probe error path
      net: ethernet: stmmac: dwmac-meson8b: fix probe error path
      net: ethernet: stmmac: platform: fix outdated function header
      net: ethernet: stmmac: fix of-node and fixed-link-phydev leaks

Jon Paul Maloy (1):
      tipc: fix link statistics counter errors

Josef Bacik (1):
      bpf: fix states equal logic for varlen access

Julian Wollrath (1):
      tcp: Set DEFAULT_TCP_CONG to bbr if DEFAULT_BBR is set

Kristian Evensen (1):
      cdc_ether: Fix handling connection notification

Laura Garcia Liebana (1):
      netfilter: nft_hash: validate maximum value of u32 netlink hash attribute

Lino Sanfilippo (2):
      net: ethernet: altera: TSE: Remove unneeded dma sync for tx buffers
      net: ethernet: altera: TSE: do not use tx queue lock in tx completion handler

Liping Zhang (1):
      netfilter: nft_range: add the missing NULL pointer check

Martin Blumenstingl (2):
      Documentation: devicetree: clarify usage of the RGMII phy-modes
      net: phy: realtek: fix enabling of the TX-delay for RTL8211F

Michael Holzheu (1):
      bpf/samples: Fix PT_REGS_IP on s390x and use it

Michal Kubeèek (1):
      tipc: check minimum bearer MTU

Miroslav Urbanek (1):
      flowcache: Increase threshold for refusing new allocations

Nicolas Dichtel (1):
      vti6: flush x-netns xfrm cache when vti interface is removed

Nikita Yushchenko (2):
      net: dsa: fix unbalanced dsa_switch_tree reference counting
      net: fec: cache statistics while device is down

Philip Pettersson (1):
      packet: fix race condition in packet_set_ring

Roi Dayan (1):
      net/sched: Export tc_tunnel_key so its UAPI accessible

Sabrina Dubroca (1):
      geneve: avoid use-after-free of skb->data

Sowmini Varadhan (1):
      RDS: TCP: unregister_netdevice_notifier() in error path of rds_tcp_init_net

Stephane Grosjean (2):
      can: peak: Fix bittiming fields size in bits
      can: peak: Add support for PCAN-USB X6 USB interface

Tariq Toukan (1):
      Revert "net/mlx4_en: Avoid unregister_netdev at shutdown flow"

Tobias Brunner (2):
      esp4: Fix integrity verification when ESN are used
      esp6: Fix integrity verification when ESN are used

Tobias Klauser (1):
      net/rtnetlink: fix attribute name in nlmsg_size() comments

Yi Zhao (1):
      xfrm_user: fix return value from xfrm_user_rcv_msg

Zumeng Chen (1):
      net: macb: ensure ordering write to re-enable RX smoothly

allan (1):
      net: asix: Fix AX88772_suspend() USB vendor commands failure issues

 Documentation/devicetree/bindings/net/ethernet.txt    |  24 ++++++++++++++++++++----
 Documentation/networking/nf_conntrack-sysctl.txt      |   7 +++++--
 drivers/net/can/usb/peak_usb/pcan_ucan.h              |  37 +++++++++++++++++++++++++++++--------
 drivers/net/can/usb/peak_usb/pcan_usb_core.c          |   2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_core.h          |   2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c            | 104 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/ethernet/altera/altera_tse_main.c         |  21 ++++++++-------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c             |   4 ++--
 drivers/net/ethernet/aurora/nb8800.c                  |   9 +++++++--
 drivers/net/ethernet/broadcom/bcmsysport.c            |  17 ++++++++++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.c        |   8 +++++---
 drivers/net/ethernet/broadcom/genet/bcmmii.c          |  10 +++++++++-
 drivers/net/ethernet/cadence/macb.c                   |   5 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h    |   1 +
 drivers/net/ethernet/freescale/fec.h                  |   2 ++
 drivers/net/ethernet/freescale/fec_main.c             |  28 ++++++++++++++++++++++++----
 drivers/net/ethernet/freescale/fman/fman_memac.c      |   3 +++
 drivers/net/ethernet/freescale/fman/mac.c             |   2 ++
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |   7 ++++++-
 drivers/net/ethernet/freescale/gianfar.c              |   8 ++++++++
 drivers/net/ethernet/freescale/ucc_geth.c             |  23 ++++++++++++++++-------
 drivers/net/ethernet/intel/igb/igb_main.c             |   8 ++++++--
 drivers/net/ethernet/intel/igbvf/netdev.c             |   8 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |   8 ++++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |   8 ++++++--
 drivers/net/ethernet/marvell/mvneta.c                 |   5 +++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.c           |   4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  17 ++---------------
 drivers/net/ethernet/mellanox/mlx4/main.c             |   5 +----
 drivers/net/ethernet/mellanox/mlx4/mcg.c              |   7 ++++++-
 drivers/net/ethernet/qualcomm/emac/emac-phy.c         |   1 +
 drivers/net/ethernet/qualcomm/emac/emac.c             |   4 ++++
 drivers/net/ethernet/renesas/ravb_main.c              |  19 ++++++++++++++-----
 drivers/net/ethernet/renesas/sh_eth.c                 |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c   |  17 +++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c   |  25 +++++++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c   |  17 ++++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c     |  23 ++++++++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c   |  32 ++++++++++++++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c        |  21 +++++++++++++++++----
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c   |  39 ++++++++++++++++++++++++++-------------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c       |  23 ++++++++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c     |  19 ++++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c     |  26 +++++++++++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |   1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  33 +++++++++++++++++++++++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h |   2 ++
 drivers/net/ethernet/synopsys/dwc_eth_qos.c           |  20 +++++++++++++-------
 drivers/net/ethernet/ti/cpsw.c                        |  20 ++++++--------------
 drivers/net/ethernet/ti/davinci_emac.c                |  10 +++++++++-
 drivers/net/geneve.c                                  |  14 ++++----------
 drivers/net/ipvlan/ipvlan_main.c                      |  17 ++++++++++++-----
 drivers/net/irda/w83977af_ir.c                        |   4 +++-
 drivers/net/macvtap.c                                 |  19 ++++++++++++-------
 drivers/net/phy/realtek.c                             |  20 ++++++++++++--------
 drivers/net/tun.c                                     |  10 ++++------
 drivers/net/usb/asix_devices.c                        |   6 +++---
 drivers/net/usb/cdc_ether.c                           |  38 +++++++++++++++++++++++++++++++-------
 drivers/net/usb/qmi_wwan.c                            |   1 +
 drivers/net/vxlan.c                                   |  10 +++++++---
 drivers/net/wireless/marvell/mwifiex/cfg80211.c       |  13 +++++++------
 drivers/of/of_mdio.c                                  |  15 +++++++++++++++
 include/linux/mlx4/device.h                           |   1 -
 include/linux/of_mdio.h                               |   4 ++++
 include/net/ipv6.h                                    |   2 ++
 include/net/netfilter/nf_conntrack.h                  |   6 +++---
 include/net/netfilter/nf_tables.h                     |   2 +-
 include/uapi/linux/tc_act/Kbuild                      |   1 +
 kernel/bpf/verifier.c                                 |  10 ++++++++--
 net/core/flow.c                                       |   6 ++----
 net/core/rtnetlink.c                                  |   4 ++--
 net/core/sock.c                                       |   4 ++--
 net/dccp/ipv4.c                                       |  12 +++++++-----
 net/dsa/dsa.c                                         |  13 ++++---------
 net/dsa/dsa2.c                                        |   4 +++-
 net/dsa/slave.c                                       |  19 ++++++++++++++++---
 net/ipv4/Kconfig                                      |   1 +
 net/ipv4/af_inet.c                                    |   2 +-
 net/ipv4/esp4.c                                       |   2 +-
 net/ipv4/ip_output.c                                  |   2 ++
 net/ipv4/netfilter.c                                  |   5 ++++-
 net/ipv4/netfilter/arp_tables.c                       |   4 ++--
 net/ipv6/datagram.c                                   |   4 +++-
 net/ipv6/esp6.c                                       |   2 +-
 net/ipv6/icmp.c                                       |   6 ++++--
 net/ipv6/ip6_offload.c                                |   2 +-
 net/ipv6/ip6_tunnel.c                                 |   1 -
 net/ipv6/ip6_vti.c                                    |  31 +++++++++++++++++++++++++++++++
 net/ipv6/netfilter/nf_conntrack_reasm.c               |   4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c             |   2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                   |   1 +
 net/ipv6/output_core.c                                |   2 ++
 net/l2tp/l2tp_ip.c                                    |  63 ++++++++++++++++++++++++++++++++++-----------------------------
 net/l2tp/l2tp_ip6.c                                   |  79 ++++++++++++++++++++++++++++++++++++++++++-------------------------------------
 net/netfilter/nf_nat_core.c                           |  49 ++++++++++++++++++++++++++++++-------------------
 net/netfilter/nf_tables_api.c                         |  14 +++++++++-----
 net/netfilter/nft_hash.c                              |   7 +++++--
 net/netfilter/nft_range.c                             |   6 ++++++
 net/netlink/af_netlink.c                              |  27 +++++++++++++++++++++++----
 net/netlink/af_netlink.h                              |   2 ++
 net/openvswitch/conntrack.c                           |   5 ++++-
 net/packet/af_packet.c                                |  18 ++++++++++++------
 net/rds/tcp.c                                         |   2 ++
 net/sched/act_pedit.c                                 |  24 ++++++++++++++++++++----
 net/sched/cls_basic.c                                 |   4 ----
 net/sched/cls_bpf.c                                   |   4 ----
 net/sched/cls_cgroup.c                                |   7 +++----
 net/sched/cls_flow.c                                  |   1 -
 net/sched/cls_flower.c                                |  41 ++++++++++++++++++++++++++++++++---------
 net/sched/cls_matchall.c                              |   1 -
 net/sched/cls_rsvp.h                                  |   3 ++-
 net/sched/cls_tcindex.c                               |   1 -
 net/tipc/bearer.c                                     |  11 +++++++++--
 net/tipc/bearer.h                                     |  13 +++++++++++++
 net/tipc/link.c                                       |  35 +++++++++++++++++++----------------
 net/tipc/udp_media.c                                  |   5 +++++
 net/xfrm/xfrm_policy.c                                |  10 ++++++----
 net/xfrm/xfrm_user.c                                  |   2 +-
 samples/bpf/bpf_helpers.h                             |   2 +-
 samples/bpf/sampleip_kern.c                           |   2 +-
 samples/bpf/trace_event_kern.c                        |   2 +-
 121 files changed, 1064 insertions(+), 450 deletions(-)
