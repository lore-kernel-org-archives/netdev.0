From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 10 Jun 2016 00:29:03 -0700 (PDT)
Message-ID: <20160610.002903.1174544551061029546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) nfnetlink timestamp taken from wrong skb, fix from Florian Westphal.

2) Revert some msleep conversions in rtlwifi as these spots are in
   atomic context, from Larry Finger.

3) Validate that NFTA_SET_TABLE attribute is actually specified when
   we call nf_tables_getset().  From Phil Turnbull.

4) Don't do mdio_reset in stmmac driver with spinlock held as that can
   sleep, from Vincent Palatin.

5) sk_filter() does things other than run a BPF filter, so we should
   not elide it's call just because sk->sk_filter is NULL.  Fix from
   Eric Dumazet.

6) Fix missing backlog updates in several packet schedulers, from Cong
   Wang.

7) bnx2x driver should allow VLAN add/remove while the interface is down,
   from Michal Schmidt.

8) Several RDS/TCP race fixes from Sowmini Varadhan.

9) fq_codel scheduler doesn't return correct queue length in dumps,
   from Eric Dumazet.

10) Fix TCP stats for tail loss probe and early retransmit in ipv6,
    from Yuchung Cheng.

11) Properly initialize udp_tunnel_socket_cfg in l2tp_tunnel_create(),
    from Guillaume Nault.

12) qfq scheduler leaks SKBs if a kzalloc fails, fix from Florian
    Westphal.

13) sock_fprog passed into PACKET_FANOUT_DATA needs compat handling,
    from Willem de Bruijn.

Please pull, thanks a lot!

The following changes since commit 6b15d6650c5301ce023d8df0cc3a60b1a76d377e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-05-31 22:28:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 50219538ffc0493a2b451a3aa0191138ef8bfe9d:

  vmxnet3: segCnt can be 1 for LRO packets (2016-06-10 00:15:11 -0700)

----------------------------------------------------------------
Arnd Bergmann (1):
      qed: fix qed_fill_link() error handling

Ben Dooks (2):
      net-sysfs: fix missing <linux/of_net.h>
      stmmac: fix parameter to dwmac4_set_umac_addr()

Bert Kenward (1):
      sfc: report supported link speeds on SFP connections

Bob Copeland (1):
      mac80211: mesh: flush mesh paths unconditionally

Colin Ian King (3):
      net/ethoc: fix null dereference on error exit path
      net: fec: fix spelling mistakes and add missing newline
      gtp: #define _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__

Daniel Borkmann (2):
      bpf, trace: use READ_ONCE for retrieving file ptr
      net: sched: fix tc_should_offload for specific clsact classes

David S. Miller (12):
      Merge tag 'mac80211-for-davem-2016-06-01' of git://git.kernel.org/.../jberg/mac80211
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mediatek-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-06-04' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'rds-packet-assembly-fixes'
      Merge branch 'bnxt_en-fixes'
      Merge branch 'u32-hwoffload-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'cls_u32-hwoffload-fixes'
      Merge branch 'mlxsw-fixes'
      Merge tag 'mac80211-for-davem-2016-06-09' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'mlx5-fixes'

Eli Cohen (1):
      net/mlx5e: Fix blue flame quota logic

Eran Ben Elisha (1):
      net/mlx5e: Use ndo_stop explicitly at shutdown flow

Eric Dumazet (4):
      Possible problem with e6afc8ac ("udp: remove headers from UDP packets before queueing")
      fq_codel: fix NET_XMIT_CN behavior
      fq_codel: return non zero qlen in class dumps
      net_sched: add missing paddattr description

Eric W. Biederman (1):
      netfilter: nf_queue: Make the queue_handler pernet

Felix Fietkau (1):
      mac80211: fix fast_tx header alignment

Florian Westphal (4):
      netfilter: nfnetlink_queue: fix timestamp attribute
      netfilter: conntrack: remove leftover binary sysctl define
      netfilter: x_tables: don't reject valid target size on some architectures
      qfq: don't leak skb if kzalloc fails

Franky Lin (1):
      brcmfmac: add eth_type_trans back for PCIe full dongle

Geert Uytterhoeven (1):
      MAINTAINERS: Add file patterns for wireless device tree bindings

Guillaume Nault (1):
      l2tp: fix configuration passed to setup_udp_tunnel_sock()

Hariprasad Shenai (1):
      cxgb4: Add device id of T540-BT adapter

Helge Deller (2):
      soreuseport: Fix reuseport_bpf testcase on 32bit architectures
      soreuseport: add compat case for setsockopt SO_ATTACH_REUSEPORT_CBPF

Ido Schimmel (2):
      mlxsw: spectrum: Make split flow match firmware requirements
      mlxsw: spectrum: Don't sleep during ndo_get_phys_port_name()

Ivan Khoronzhuk (1):
      net: ethernet: ti: cpsw: fix rx-usecs interrupt pacing consistency

Jaap Jan Meijer (1):
      brcmfmac: add fallback for devices that do not report per-chain values

Jakub Kicinski (4):
      net: cls_u32: fix error code for invalid flags
      net: cls_u32: be more strict about skip-sw flag
      net: cls_u32: catch all hardware offload errors
      net: cls_u32: be more strict about skip-sw flag for knodes

Jakub Sitnicki (1):
      ipv6: Skip XFRM lookup if dst_entry in socket cache is valid

Johannes Berg (1):
      cfg80211: remove get/set antenna and tx power warnings

John Crispin (4):
      net-next: mediatek: use mdiobus_free() in favour of kfree()
      net-next: mediatek: fix gigabit and flow control advertisement
      net-next: mediatek: add fixed-phy support
      net-next: mediatek: properly handle RGMII modes

Kangjie Lu (2):
      tipc: fix an infoleak in tipc_nl_compat_link_dump
      rds: fix an infoleak in rds_inc_info_copy

Larry Finger (1):
      rtlwifi: Fix scheduling while atomic error from commit 49f86ec21c01

Majd Dibbiny (2):
      net/mlx5: Fix the size of modify QP mailbox
      net/mlx5: Fix masking of reserved bits in XRCD number

Maor Gottlieb (3):
      net/mlx5: Fix root flow table update
      net/mlx5: Fix flow steering NIC capabilities check
      net/mlx5: Fix E-Switch flow steering capabilities check

Marco Angaroni (1):
      ipvs: update real-server binding of outgoing connections in SIP-pe

Martin Willi (1):
      mac80211_hwsim: Add missing check for HWSIM_ATTR_SIGNAL

Michael Chan (3):
      bnxt_en: Fix tx push race condition.
      bnxt_en: Enable and disable RX CTAG and RX STAG VLAN acceleration together.
      bnxt_en: Simplify VLAN receive logic.

Michal Schmidt (1):
      bnx2x: allow adding VLANs while interface is down

Mohamad Haj Yahia (2):
      net/mlx5: E-Switch, Fix vport enable flow
      net/mlx5: E-Switch, always set mc_promisc for allmulti vports

Noa Osherovich (1):
      net/mlx5: E-Switch, Modify node guid on vf set MAC

Or Gerlitz (2):
      net/mlx5: E-Switch, Use the correct free() function
      net/mlx5: E-Switch, Use the correct error check on returned pointers

Pablo Neira Ayuso (1):
      netfilter: nf_ct_helper: bail out on duplicated helpers

Paolo Abeni (1):
      netfilter: nf_dup_ipv6: set again FLOWI_FLAG_KNOWN_NH at flowi6_flags

Phil Turnbull (1):
      netfilter: nf_tables: validate NFTA_SET_TABLE parameter

Prasun Maiti (1):
      wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel

Shahar Klein (1):
      net/mlx5: Fix MLX5_CMD_OP_MAX to be defined correctly

Shrikrishna Khare (1):
      vmxnet3: segCnt can be 1 for LRO packets

Shweta Choudaha (1):
      ip6gre: Allow live link address change

Sowmini Varadhan (3):
      RDS: TCP: Add/use rds_tcp_reset_callbacks to reset tcp socket safely
      RDS: TCP: Retransmit half-sent datagrams when switching sockets in rds_tcp_reset_callbacks
      RDS: TCP: fix race windows in send-path quiescence by rds_tcp_accept_one()

Taehee Yoo (1):
      netfilter: nf_ct_helper: Fix helper unregister count.

Toshiaki Makita (1):
      bridge: Don't insert unnecessary local fdb entry on changing mac address

Vincent Palatin (1):
      stmmac: do not sleep in atomic context for mdio_reset

WANG Cong (7):
      sch_hfsc: always keep backlog updated
      sch_prio: update backlog as well
      sch_drr: update backlog as well
      sch_red: update backlog as well
      sch_tbf: update backlog as well
      net_sched: keep backlog updated with qlen
      act_police: fix a crash during removal

Willem de Bruijn (1):
      packet: compat support for sock_fprog

Wu Fengguang (1):
      rxrpc: fix ptr_ret.cocci warnings

Yangbo Lu (1):
      gianfar: fix the last transmit buffer descriptor

Yuchung Cheng (1):
      tcp: record TLP and ER timer stats in v6 stats

 MAINTAINERS                                                 |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c            | 151 +++++++++++++++++++++-----------------------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                   |  46 ++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h          |   1 +
 drivers/net/ethernet/ethoc.c                                |   7 ++-
 drivers/net/ethernet/freescale/fec_main.c                   |   8 +--
 drivers/net/ethernet/freescale/gianfar.c                    |   3 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c                 |  40 ++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c           |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c             |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c           |  69 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c           |  40 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/qp.c                |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c             |  38 +++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c              | 203 +++++++++++++++++++++++++++++++++++++------------------------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h              |   5 ++
 drivers/net/ethernet/qlogic/qed/qed_main.c                  |  45 ++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_sriov.h                 |   4 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c                |   2 +
 drivers/net/ethernet/sfc/mcdi_port.c                        |   7 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c           |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c           |   6 +-
 drivers/net/ethernet/ti/cpsw.c                              |   2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                           |   2 +-
 drivers/net/vmxnet3/vmxnet3_int.h                           |   4 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c |  16 ++++++
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c   |   2 +
 drivers/net/wireless/mac80211_hwsim.c                       |   1 +
 drivers/net/wireless/realtek/rtlwifi/core.c                 |   6 +-
 include/linux/mlx5/device.h                                 |   8 ++-
 include/linux/mlx5/mlx5_ifc.h                               |  12 +++-
 include/linux/mlx5/qp.h                                     |   1 +
 include/linux/mlx5/vport.h                                  |   2 +
 include/net/compat.h                                        |   1 +
 include/net/ip_vs.h                                         |   2 +-
 include/net/netfilter/nf_queue.h                            |   4 +-
 include/net/netns/netfilter.h                               |   2 +
 include/net/pkt_cls.h                                       |  10 +++-
 include/net/sch_generic.h                                   |   6 +-
 include/uapi/linux/gtp.h                                    |   2 +-
 kernel/trace/bpf_trace.c                                    |   4 +-
 net/bridge/br_fdb.c                                         |   2 +
 net/compat.c                                                |  20 ++++++-
 net/core/gen_stats.c                                        |   2 +
 net/core/net-sysfs.c                                        |   1 +
 net/ipv4/udp.c                                              |  10 ++--
 net/ipv6/ip6_gre.c                                          |   3 +
 net/ipv6/ip6_output.c                                       |  11 +---
 net/ipv6/netfilter/nf_dup_ipv6.c                            |   1 +
 net/ipv6/tcp_ipv6.c                                         |   4 +-
 net/ipv6/udp.c                                              |  12 ++--
 net/l2tp/l2tp_core.c                                        |   2 +-
 net/mac80211/mesh.c                                         |   4 ++
 net/mac80211/sta_info.h                                     |   2 +-
 net/netfilter/ipvs/ip_vs_conn.c                             |   5 +-
 net/netfilter/ipvs/ip_vs_core.c                             |   5 +-
 net/netfilter/nf_conntrack_ftp.c                            |   1 +
 net/netfilter/nf_conntrack_helper.c                         |   9 ++-
 net/netfilter/nf_conntrack_irc.c                            |   1 +
 net/netfilter/nf_conntrack_sane.c                           |   1 +
 net/netfilter/nf_conntrack_sip.c                            |   1 +
 net/netfilter/nf_conntrack_standalone.c                     |   2 -
 net/netfilter/nf_conntrack_tftp.c                           |   1 +
 net/netfilter/nf_queue.c                                    |  17 +++---
 net/netfilter/nf_tables_api.c                               |   2 +
 net/netfilter/nfnetlink_queue.c                             |  20 ++++---
 net/netfilter/x_tables.c                                    |   4 +-
 net/packet/af_packet.c                                      |  25 +++++++++
 net/rds/rds.h                                               |   2 +
 net/rds/recv.c                                              |   2 +
 net/rds/send.c                                              |   1 +
 net/rds/tcp.c                                               |  78 +++++++++++++++++++++++++-
 net/rds/tcp.h                                               |   1 +
 net/rds/tcp_connect.c                                       |   2 +-
 net/rds/tcp_listen.c                                        |  20 +++----
 net/rds/threads.c                                           |  10 +++-
 net/rxrpc/rxkad.c                                           |   4 +-
 net/sched/act_police.c                                      |  33 ++++-------
 net/sched/cls_flower.c                                      |   6 +-
 net/sched/cls_u32.c                                         |  72 +++++++++++++-----------
 net/sched/sch_drr.c                                         |   4 ++
 net/sched/sch_fq_codel.c                                    |  26 ++++++---
 net/sched/sch_generic.c                                     |   2 +
 net/sched/sch_hfsc.c                                        |  12 ++--
 net/sched/sch_ingress.c                                     |  12 ++++
 net/sched/sch_prio.c                                        |   4 ++
 net/sched/sch_qfq.c                                         |   6 +-
 net/sched/sch_red.c                                         |   4 ++
 net/sched/sch_tbf.c                                         |   4 ++
 net/tipc/netlink_compat.c                                   |   3 +-
 net/wireless/core.c                                         |   2 -
 net/wireless/wext-core.c                                    |  25 ++++++++-
 tools/testing/selftests/net/reuseport_bpf.c                 |  10 ++--
 93 files changed, 828 insertions(+), 460 deletions(-)
