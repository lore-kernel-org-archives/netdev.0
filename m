From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 09 Oct 2012 21:26:46 -0400 (EDT)
Message-ID: <20121009.212646.1551826953421239840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243Ab2JJB1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 21:27:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) UAPI changes for networking from David Howells

2) A netlink dump is an operation we can sleep within, and
   therefore we need to make sure the dump provider module
   doesn't disappear on us meanwhile.  Fix from Gao Feng.

3) Now that tunnels support GRO, we have to be more careful
   in skb_gro_reset_offset() otherwise we OOPS, from Eric
   Dumazet.

4) We can end up processing packets for VLANs we aren't
   actually configured to be on, fix from Florian Zumbiehl.

5) Fix routing cache removal regression in redirects and IPVS.  The core
   issue on the IPVS side is that it wants to rewrite who the nexthop
   is and we have to explicitly accomodate that case.  From Julian
   Anastasov.

6) Error code return fixes all over the networking drivers from
   Peter Senna Tschudin.

7) Fix routing cache removal regressions in IPSEC, from Steffen
   Klassert.

8) Fix deadlock in RDS during pings, from Jeff Liu.

9) Neighbour packet queue can trigger skb_under_panic() because we
   do not reset the network header of the SKB in the right spot.
   From Ramesh Nagappa.

Please pull, thanks a lot!

The following changes since commit 547b1e81afe3119f7daf702cc03b158495535a25:

  Fix staging driver use of VM_RESERVED (2012-10-09 21:06:41 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 5175a5e76bbdf20a614fb47ce7a38f0f39e70226:

  RDS: fix rds-ping spinlock recursion (2012-10-09 13:57:23 -0400)

----------------------------------------------------------------
Ajit Khaparde (1):
      be2net: Remove code that stops further access to BE NIC based on UE bits

Alexander Duyck (1):
      ixgbe/ixgbevf: Limit maximum jumbo frame size to 9.5K to avoid Tx hangs

Bruce Allan (1):
      e1000e: add device IDs for i218

Dan Carpenter (2):
      cxgb4: allocate enough data in t4_memory_rw()
      farsync: fix support for over 30 cards

David Howells (10):
      UAPI: (Scripted) Disintegrate include/linux/caif
      UAPI: (Scripted) Disintegrate include/linux/isdn
      UAPI: (Scripted) Disintegrate include/linux/netfilter
      UAPI: (Scripted) Disintegrate include/linux/netfilter/ipset
      UAPI: (Scripted) Disintegrate include/linux/netfilter_arp
      UAPI: (Scripted) Disintegrate include/linux/netfilter_bridge
      UAPI: (Scripted) Disintegrate include/linux/netfilter_ipv4
      UAPI: (Scripted) Disintegrate include/linux/netfilter_ipv6
      UAPI: (Scripted) Disintegrate include/linux/tc_act
      UAPI: (Scripted) Disintegrate include/linux/tc_ematch

David S. Miller (3):
      Merge git://git.kernel.org/.../torvalds/linux
      Merge tag 'disintegrate-net-20121009' of git://git.infradead.org/users/dhowells/linux-headers
      Merge tag 'disintegrate-isdn-20121009' of git://git.infradead.org/users/dhowells/linux-headers

Eric Dumazet (5):
      net: remove skb recycling
      ipv6: GRO should be ECN friendly
      net: gro: fix a potential crash in skb_gro_reset_offset
      net: gro: selective flush of packets
      ipv6: gro: fix PV6_GRO_CB(skb)->proto problem

Florian Zumbiehl (1):
      vlan: don't deliver frames for unknown vlans to protocols

Gao feng (2):
      netlink: add reference of module in netlink_dump_start
      infiniband: pass rdma_cm module to netlink_dump_start

Graham Gower (1):
      skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard

Greg Rose (1):
      ixgbevf: Set the netdev number of Tx queues

Haicheng Li (1):
      pch_gbe: Fix build error by selecting all the possible dependencies.

Julian Anastasov (6):
      ipv4: fix sending of redirects
      ipv4: fix forwarding for strict source routes
      ipv4: make sure nh_pcpu_rth_output is always allocated
      ipv4: introduce rt_uses_gateway
      ipv4: Add FLOWI_FLAG_KNOWN_NH
      ipvs: fix ARP resolving for direct routing mode

Mark Brown (1):
      netdev/phy: Prototype of_mdio_find_bus()

Michael Neuling (1):
      net: fix typo in freescale/ucc_geth.c

Peter Senna Tschudin (18):
      drivers/net/ethernet/dec/tulip/dmfe.c: fix error return code
      drivers/net/ethernet/natsemi/natsemi.c: fix error return code
      drivers/net/ethernet/sis/sis900.c: fix error return code
      drivers/net/irda/irtty-sir.c: fix error return code
      drivers/net/irda/mcs7780.c: fix error return code
      drivers/net/irda/pxaficp_ir.c: fix error return code
      drivers/net/irda/sa1100_ir.c: fix error return code
      drivers/net/irda/sh_irda.c: fix error return code
      drivers/net/irda/sh_sir.c: fix error return code
      drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c: fix error return code
      drivers/net/ethernet/amd/amd8111e.c: fix error return code
      drivers/net/ethernet/amd/au1000_eth.c: fix error return code
      drivers/net/ethernet/natsemi/xtsonic.c: fix error return code
      drivers/net/ethernet/renesas/sh_eth.c: fix error return code
      drivers/net/ethernet/sun/niu.c: fix error return code
      drivers/net/ethernet/sun/sungem.c: fix error return code
      drivers/net/ethernet/marvell/skge.c: fix error return code
      drivers/net/ethernet/marvell/sky2.c: fix error return code

Steffen Klassert (3):
      ipv4: Always invalidate or update the route on pmtu events
      ipv4: Don't create nh exeption when the device mtu is smaller than the reported pmtu
      ipv4: Don't report stale pmtu values to userspace

Stephen Hemminger (1):
      vxlan: fix more sparse warnings

Vipul Pandya (1):
      cxgb4: Address various sparse warnings

Wei Yongjun (2):
      vxlan: remove unused including <linux/version.h>
      ptp: use list_move instead of list_del/list_add

jeff.liu (1):
      RDS: fix rds-ping spinlock recursion

ramesh.nagappa@gmail.com (1):
      net: Fix skb_under_panic oops in neigh_resolve_output

 drivers/infiniband/core/cma.c                                  |   3 +-
 drivers/infiniband/core/netlink.c                              |   1 +
 drivers/net/ethernet/amd/amd8111e.c                            |   2 +
 drivers/net/ethernet/amd/au1000_eth.c                          |  10 +-
 drivers/net/ethernet/calxeda/xgmac.c                           |  19 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h                     |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c                |  54 +++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c                     |  15 ++-
 drivers/net/ethernet/dec/tulip/dmfe.c                          |  12 +-
 drivers/net/ethernet/emulex/benet/be_main.c                    |   7 +-
 drivers/net/ethernet/freescale/gianfar.c                       |  27 +----
 drivers/net/ethernet/freescale/gianfar.h                       |   2 -
 drivers/net/ethernet/freescale/ucc_geth.c                      |  29 +----
 drivers/net/ethernet/freescale/ucc_geth.h                      |   2 -
 drivers/net/ethernet/intel/e1000e/hw.h                         |   2 +
 drivers/net/ethernet/intel/e1000e/netdev.c                     |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe.h                       |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h                   |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c              |   7 ++
 drivers/net/ethernet/marvell/mv643xx_eth.c                     |  18 +--
 drivers/net/ethernet/marvell/skge.c                            |  13 +-
 drivers/net/ethernet/marvell/sky2.c                            |   5 +-
 drivers/net/ethernet/natsemi/natsemi.c                         |   4 +-
 drivers/net/ethernet/natsemi/xtsonic.c                         |   1 +
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig                  |   3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c               |   3 +-
 drivers/net/ethernet/realtek/8139cp.c                          |   2 +-
 drivers/net/ethernet/renesas/sh_eth.c                          |   1 +
 drivers/net/ethernet/sfc/ptp.c                                 |   9 +-
 drivers/net/ethernet/sis/sis900.c                              |   4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h                   |   1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c              |  20 +--
 drivers/net/ethernet/sun/niu.c                                 |   1 +
 drivers/net/ethernet/sun/sungem.c                              |   3 +-
 drivers/net/irda/irtty-sir.c                                   |   4 +-
 drivers/net/irda/mcs7780.c                                     |   4 +-
 drivers/net/irda/pxaficp_ir.c                                  |   4 +-
 drivers/net/irda/sa1100_ir.c                                   |   4 +-
 drivers/net/irda/sh_irda.c                                     |   4 +-
 drivers/net/irda/sh_sir.c                                      |   5 +-
 drivers/net/phy/mdio_bus.c                                     |   1 +
 drivers/net/vxlan.c                                            |   5 +-
 drivers/net/wan/farsync.c                                      |   2 +-
 include/linux/caif/Kbuild                                      |   2 -
 include/linux/if_vlan.h                                        |   8 +-
 include/linux/isdn/Kbuild                                      |   1 -
 include/linux/netdevice.h                                      |  19 +--
 include/linux/netfilter/Kbuild                                 |  77 ------------
 include/linux/netfilter/ipset/Kbuild                           |   4 -
 include/linux/netfilter/ipset/ip_set.h                         | 225 +---------------------------------
 include/linux/netfilter/ipset/ip_set_bitmap.h                  |  11 +-
 include/linux/netfilter/ipset/ip_set_hash.h                    |  19 +--
 include/linux/netfilter/ipset/ip_set_list.h                    |  19 +--
 include/linux/netfilter/nf_conntrack_common.h                  | 115 +-----------------
 include/linux/netfilter/nf_conntrack_ftp.h                     |  16 +--
 include/linux/netfilter/nf_conntrack_tcp.h                     |  49 +-------
 include/linux/netfilter/nfnetlink.h                            |  55 +--------
 include/linux/netfilter/nfnetlink_acct.h                       |  25 +---
 include/linux/netfilter/x_tables.h                             | 186 +---------------------------
 include/linux/netfilter/xt_hashlimit.h                         |  71 +----------
 include/linux/netfilter/xt_physdev.h                           |  21 +---
 include/linux/netfilter_arp/Kbuild                             |   2 -
 include/linux/netfilter_arp/arp_tables.h                       | 200 +-----------------------------
 include/linux/netfilter_bridge/Kbuild                          |  18 ---
 include/linux/netfilter_bridge/ebt_802_3.h                     |  61 +---------
 include/linux/netfilter_bridge/ebtables.h                      | 255 +--------------------------------------
 include/linux/netfilter_ipv4/Kbuild                            |  10 --
 include/linux/netfilter_ipv4/ip_tables.h                       | 218 +--------------------------------
 include/linux/netfilter_ipv6/Kbuild                            |  12 --
 include/linux/netfilter_ipv6/ip6_tables.h                      | 256 +--------------------------------------
 include/linux/netlink.h                                        |  20 ++-
 include/linux/skbuff.h                                         |  24 ----
 include/linux/tc_act/Kbuild                                    |   7 --
 include/linux/tc_ematch/Kbuild                                 |   4 -
 include/net/flow.h                                             |   1 +
 include/net/route.h                                            |   3 +-
 include/rdma/rdma_netlink.h                                    |   1 +
 include/uapi/linux/caif/Kbuild                                 |   2 +
 include/{ => uapi}/linux/caif/caif_socket.h                    |   0
 include/{ => uapi}/linux/caif/if_caif.h                        |   0
 include/uapi/linux/isdn/Kbuild                                 |   1 +
 include/{ => uapi}/linux/isdn/capicmd.h                        |   0
 include/uapi/linux/netfilter/Kbuild                            |  76 ++++++++++++
 include/uapi/linux/netfilter/ipset/Kbuild                      |   4 +
 include/uapi/linux/netfilter/ipset/ip_set.h                    | 231 +++++++++++++++++++++++++++++++++++
 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h             |  13 ++
 include/uapi/linux/netfilter/ipset/ip_set_hash.h               |  21 ++++
 include/uapi/linux/netfilter/ipset/ip_set_list.h               |  21 ++++
 include/uapi/linux/netfilter/nf_conntrack_common.h             | 117 ++++++++++++++++++
 include/uapi/linux/netfilter/nf_conntrack_ftp.h                |  18 +++
 include/{ => uapi}/linux/netfilter/nf_conntrack_sctp.h         |   0
 include/uapi/linux/netfilter/nf_conntrack_tcp.h                |  51 ++++++++
 include/{ => uapi}/linux/netfilter/nf_conntrack_tuple_common.h |   0
 include/{ => uapi}/linux/netfilter/nf_nat.h                    |   0
 include/uapi/linux/netfilter/nfnetlink.h                       |  56 +++++++++
 include/uapi/linux/netfilter/nfnetlink_acct.h                  |  27 +++++
 include/{ => uapi}/linux/netfilter/nfnetlink_compat.h          |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_conntrack.h       |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_cthelper.h        |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_cttimeout.h       |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_log.h             |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_queue.h           |   0
 include/uapi/linux/netfilter/x_tables.h                        | 187 ++++++++++++++++++++++++++++
 include/{ => uapi}/linux/netfilter/xt_AUDIT.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_CHECKSUM.h               |   0
 include/{ => uapi}/linux/netfilter/xt_CLASSIFY.h               |   0
 include/{ => uapi}/linux/netfilter/xt_CONNMARK.h               |   0
 include/{ => uapi}/linux/netfilter/xt_CONNSECMARK.h            |   0
 include/{ => uapi}/linux/netfilter/xt_CT.h                     |   0
 include/{ => uapi}/linux/netfilter/xt_DSCP.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_IDLETIMER.h              |   0
 include/{ => uapi}/linux/netfilter/xt_LED.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_LOG.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_MARK.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_NFLOG.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_NFQUEUE.h                |   0
 include/{ => uapi}/linux/netfilter/xt_RATEEST.h                |   0
 include/{ => uapi}/linux/netfilter/xt_SECMARK.h                |   0
 include/{ => uapi}/linux/netfilter/xt_TCPMSS.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_TCPOPTSTRIP.h            |   0
 include/{ => uapi}/linux/netfilter/xt_TEE.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_TPROXY.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_addrtype.h               |   0
 include/{ => uapi}/linux/netfilter/xt_cluster.h                |   0
 include/{ => uapi}/linux/netfilter/xt_comment.h                |   0
 include/{ => uapi}/linux/netfilter/xt_connbytes.h              |   0
 include/{ => uapi}/linux/netfilter/xt_connlimit.h              |   0
 include/{ => uapi}/linux/netfilter/xt_connmark.h               |   0
 include/{ => uapi}/linux/netfilter/xt_conntrack.h              |   0
 include/{ => uapi}/linux/netfilter/xt_cpu.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_dccp.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_devgroup.h               |   0
 include/{ => uapi}/linux/netfilter/xt_dscp.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_ecn.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_esp.h                    |   0
 include/uapi/linux/netfilter/xt_hashlimit.h                    |  73 +++++++++++
 include/{ => uapi}/linux/netfilter/xt_helper.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_iprange.h                |   0
 include/{ => uapi}/linux/netfilter/xt_ipvs.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_length.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_limit.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_mac.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_mark.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_multiport.h              |   0
 include/{ => uapi}/linux/netfilter/xt_nfacct.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_osf.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_owner.h                  |   0
 include/uapi/linux/netfilter/xt_physdev.h                      |  23 ++++
 include/{ => uapi}/linux/netfilter/xt_pkttype.h                |   0
 include/{ => uapi}/linux/netfilter/xt_policy.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_quota.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_rateest.h                |   0
 include/{ => uapi}/linux/netfilter/xt_realm.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_recent.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_sctp.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_set.h                    |   0
 include/{ => uapi}/linux/netfilter/xt_socket.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_state.h                  |   0
 include/{ => uapi}/linux/netfilter/xt_statistic.h              |   0
 include/{ => uapi}/linux/netfilter/xt_string.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_tcpmss.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_tcpudp.h                 |   0
 include/{ => uapi}/linux/netfilter/xt_time.h                   |   0
 include/{ => uapi}/linux/netfilter/xt_u32.h                    |   0
 include/uapi/linux/netfilter_arp/Kbuild                        |   2 +
 include/uapi/linux/netfilter_arp/arp_tables.h                  | 206 +++++++++++++++++++++++++++++++
 include/{ => uapi}/linux/netfilter_arp/arpt_mangle.h           |   0
 include/uapi/linux/netfilter_bridge/Kbuild                     |  18 +++
 include/uapi/linux/netfilter_bridge/ebt_802_3.h                |  62 ++++++++++
 include/{ => uapi}/linux/netfilter_bridge/ebt_among.h          |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_arp.h            |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_arpreply.h       |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_ip.h             |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_ip6.h            |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_limit.h          |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_log.h            |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_mark_m.h         |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_mark_t.h         |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_nat.h            |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_nflog.h          |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_pkttype.h        |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_redirect.h       |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_stp.h            |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_ulog.h           |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_vlan.h           |   0
 include/uapi/linux/netfilter_bridge/ebtables.h                 | 268 +++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/netfilter_ipv4/Kbuild                       |  10 ++
 include/uapi/linux/netfilter_ipv4/ip_tables.h                  | 229 +++++++++++++++++++++++++++++++++++
 include/{ => uapi}/linux/netfilter_ipv4/ipt_CLUSTERIP.h        |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ECN.h              |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_LOG.h              |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_REJECT.h           |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_TTL.h              |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ULOG.h             |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ah.h               |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ecn.h              |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ttl.h              |   0
 include/uapi/linux/netfilter_ipv6/Kbuild                       |  12 ++
 include/uapi/linux/netfilter_ipv6/ip6_tables.h                 | 267 ++++++++++++++++++++++++++++++++++++++++
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_HL.h              |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_LOG.h             |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_NPT.h             |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_REJECT.h          |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_ah.h              |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_frag.h            |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_hl.h              |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_ipv6header.h      |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_mh.h              |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_opts.h            |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_rt.h              |   0
 include/uapi/linux/tc_act/Kbuild                               |   7 ++
 include/{ => uapi}/linux/tc_act/tc_csum.h                      |   0
 include/{ => uapi}/linux/tc_act/tc_gact.h                      |   0
 include/{ => uapi}/linux/tc_act/tc_ipt.h                       |   0
 include/{ => uapi}/linux/tc_act/tc_mirred.h                    |   0
 include/{ => uapi}/linux/tc_act/tc_nat.h                       |   0
 include/{ => uapi}/linux/tc_act/tc_pedit.h                     |   0
 include/{ => uapi}/linux/tc_act/tc_skbedit.h                   |   0
 include/uapi/linux/tc_ematch/Kbuild                            |   4 +
 include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h                 |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_meta.h                |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h               |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_text.h                |   0
 net/8021q/vlan_core.c                                          |  10 +-
 net/core/dev.c                                                 |  59 ++++++---
 net/core/neighbour.c                                           |   6 +-
 net/core/skbuff.c                                              |  47 --------
 net/ipv4/fib_frontend.c                                        |   3 +-
 net/ipv4/fib_semantics.c                                       |   2 +
 net/ipv4/inet_connection_sock.c                                |   4 +-
 net/ipv4/ip_forward.c                                          |   2 +-
 net/ipv4/ip_output.c                                           |   4 +-
 net/ipv4/route.c                                               | 146 ++++++++++++----------
 net/ipv4/xfrm4_policy.c                                        |   1 +
 net/ipv6/af_inet6.c                                            |  22 ++--
 net/netfilter/ipvs/ip_vs_xmit.c                                |   6 +-
 net/netlink/af_netlink.c                                       |  29 +++--
 net/rds/send.c                                                 |   2 +-
 238 files changed, 2392 insertions(+), 2292 deletions(-)
 rename include/{ => uapi}/linux/caif/caif_socket.h (100%)
 rename include/{ => uapi}/linux/caif/if_caif.h (100%)
 rename include/{ => uapi}/linux/isdn/capicmd.h (100%)
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_hash.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_list.h
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_common.h
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_ftp.h
 rename include/{ => uapi}/linux/netfilter/nf_conntrack_sctp.h (100%)
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_tcp.h
 rename include/{ => uapi}/linux/netfilter/nf_conntrack_tuple_common.h (100%)
 rename include/{ => uapi}/linux/netfilter/nf_nat.h (100%)
 create mode 100644 include/uapi/linux/netfilter/nfnetlink.h
 create mode 100644 include/uapi/linux/netfilter/nfnetlink_acct.h
 rename include/{ => uapi}/linux/netfilter/nfnetlink_compat.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_conntrack.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_cthelper.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_cttimeout.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_log.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_queue.h (100%)
 create mode 100644 include/uapi/linux/netfilter/x_tables.h
 rename include/{ => uapi}/linux/netfilter/xt_AUDIT.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CHECKSUM.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CLASSIFY.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CONNMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CONNSECMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CT.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_DSCP.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_IDLETIMER.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_LED.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_MARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_NFLOG.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_NFQUEUE.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_RATEEST.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_SECMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TCPMSS.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TCPOPTSTRIP.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TEE.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TPROXY.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_addrtype.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_cluster.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_comment.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connbytes.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connlimit.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connmark.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_conntrack.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_cpu.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_dccp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_devgroup.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_dscp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_ecn.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_esp.h (100%)
 create mode 100644 include/uapi/linux/netfilter/xt_hashlimit.h
 rename include/{ => uapi}/linux/netfilter/xt_helper.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_iprange.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_ipvs.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_length.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_limit.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_mac.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_mark.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_multiport.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_nfacct.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_osf.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_owner.h (100%)
 create mode 100644 include/uapi/linux/netfilter/xt_physdev.h
 rename include/{ => uapi}/linux/netfilter/xt_pkttype.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_policy.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_quota.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_rateest.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_realm.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_recent.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_sctp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_set.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_socket.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_state.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_statistic.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_string.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_tcpmss.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_tcpudp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_time.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_u32.h (100%)
 create mode 100644 include/uapi/linux/netfilter_arp/arp_tables.h
 rename include/{ => uapi}/linux/netfilter_arp/arpt_mangle.h (100%)
 create mode 100644 include/uapi/linux/netfilter_bridge/ebt_802_3.h
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_among.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_arp.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_arpreply.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ip.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ip6.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_limit.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_log.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_mark_m.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_mark_t.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_nat.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_nflog.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_pkttype.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_redirect.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_stp.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ulog.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_vlan.h (100%)
 create mode 100644 include/uapi/linux/netfilter_bridge/ebtables.h
 create mode 100644 include/uapi/linux/netfilter_ipv4/ip_tables.h
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_CLUSTERIP.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ECN.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_REJECT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_TTL.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ULOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ah.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ecn.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ttl.h (100%)
 create mode 100644 include/uapi/linux/netfilter_ipv6/ip6_tables.h
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_HL.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_NPT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_REJECT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_ah.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_frag.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_hl.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_ipv6header.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_mh.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_opts.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_rt.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_csum.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_gact.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_ipt.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_mirred.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_nat.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_pedit.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_skbedit.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_meta.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_text.h (100%)
