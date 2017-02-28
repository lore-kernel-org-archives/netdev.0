From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 27 Feb 2017 20:42:10 -0500 (EST)
Message-ID: <20170227.204210.1772732114863103750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't save TIPC header values before the header has been validated,
   from Jon Paul Maloy.

2) Fix memory leak in RDS, from Zhu Yanjun.

3) We miss to initialize the UID in the flow key in some paths, from
   Julian Anastasov.

4) Fix latent TOS masking bug in the routing cache removal from years
   ago, also from Julian.

5) We forget to set the sockaddr port in sctp_copy_local_addr_list(),
   fix from Xin Long.

6) Missing module ref count drop in packet scheduler actions, from
   Roman Mashak.

7) Fix RCU annotations in rht_bucket_nested, from Herbert Xu.

8) Fix use after free which happens because L2TP's ipv4 support
   returns non-zero values from it's backlog_rcv function which ipv4
   interprets as protocol values.  Fix from Paul Hüber.

Please pull, thanks a lot!

The following changes since commit f1ef09fde17f9b77ca1435a5b53a28b203afb81c:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace (2017-02-23 20:33:51 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 2f44f75257d57f0d5668dba3a6ada0f4872132c9:

  Merge branch 'qed-fixes' (2017-02-27 09:22:10 -0500)

----------------------------------------------------------------
Brian Russell (1):
      vxlan: don't allow overwrite of config src addr

Colin Ian King (1):
      lib: fix spelling mistake: "actualy" -> "actually"

David Forster (1):
      vti6: return GRE_KEY for vti6

David Howells (1):
      rxrpc: Kernel calls get stuck in recvmsg

David S. Miller (2):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'qed-fixes'

Dmitry V. Levin (2):
      uapi: stop including linux/sysctl.h in uapi/linux/netfilter.h
      uapi: fix linux/netfilter/xt_hashlimit.h userspace compilation error

Eric Dumazet (1):
      net/mlx4_en: fix overflow in mlx4_en_init_timestamp()

Florian Fainelli (1):
      net: phy: Add missing driver check in phy_aneg_done()

Florian Westphal (1):
      netfilter: nft_ct: fix random validation errors for zone set support

Geert Uytterhoeven (2):
      drivers: net: xgene: Simplify xgene_enet_setup_mss() to kill warning
      lib: Allow compile-testing of parman

Herbert Xu (2):
      rhashtable: Fix use before NULL check in bucket_table_free
      rhashtable: Fix RCU dereference annotation in rht_bucket_nested

Jarno Rajahalme (2):
      netfilter: nf_ct_expect: nf_ct_expect_related_report(): Return zero on success.
      netfilter: nf_ct_expect: Change __nf_ct_expect_check() return value.

Jon Paul Maloy (1):
      tipc: move premature initilalization of stack variables

Julian Anastasov (3):
      ipv4: add missing initialization for flowi4_uid
      ipv4: mask tos for input route
      xfrm: provide correct dst in xfrm_neigh_lookup

LABBE Corentin (3):
      net: stmmac: unify registers dumps methods
      net: vxge: fix typo argumnet argument
      net: s2io: fix typo argumnet argument

Marc Dionne (1):
      rxrpc: Fix an assertion in rxrpc_read()

Marcelo Ricardo Leitner (1):
      sctp: deny peeloff operation on asocs with threads sleeping on it

Matthias Schiffer (1):
      vxlan: correctly validate VXLAN ID against VXLAN_N_VID

Mintz, Yuval (2):
      qed: Fix race with multiple VFs
      qed: Don't use attention PTT for configuring BW

Pablo Neira Ayuso (1):
      netfilter: nft_set_bitmap: incorrect bitmap size

Paul Hüber (1):
      l2tp: avoid use-after-free caused by l2tp_ip_backlog_recv

Roman Mashak (2):
      net sched actions: decrement module reference count after table flush.
      net sched actions: do not overwrite status of action creation.

Wu Fengguang (1):
      RDS: IB: fix ifnullfree.cocci warnings

Xin Long (2):
      sctp: set sin_port for addr param when checking duplicate address
      ipv6: check sk sk_type and protocol early in ip_mroute_set/getsockopt

Zhu Yanjun (1):
      rds: fix memory leak error

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c     | 13 +++----------
 drivers/net/ethernet/mellanox/mlx4/en_clock.c        | 18 ++++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h         |  1 -
 drivers/net/ethernet/neterion/s2io.c                 |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c    |  2 +-
 drivers/net/ethernet/qlogic/qed/qed.h                |  4 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c            |  6 +++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c            |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c          | 39 +++++++++++++++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h          |  4 +++-
 drivers/net/ethernet/stmicro/stmmac/common.h         |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 10 +++-------
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c  | 16 ++++++----------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c  | 30 ++++++++++--------------------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c   | 15 +++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c    | 12 +++---------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c     | 78 ++++++++++++++++++++++++++++++++++++++----------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 22 ++--------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  5 -----
 drivers/net/phy/phy.c                                |  2 +-
 drivers/net/vxlan.c                                  | 14 ++++++--------
 include/uapi/linux/netfilter.h                       |  1 -
 include/uapi/linux/netfilter/xt_hashlimit.h          |  1 +
 lib/Kconfig                                          |  2 +-
 lib/rhashtable.c                                     |  9 ++++-----
 lib/test_parman.c                                    |  2 +-
 net/ipv4/fib_frontend.c                              |  6 +++---
 net/ipv4/route.c                                     |  2 ++
 net/ipv6/ip6_vti.c                                   |  4 ++++
 net/ipv6/ip6mr.c                                     | 11 ++++++++---
 net/l2tp/l2tp_ip.c                                   |  2 +-
 net/netfilter/nf_conntrack_expect.c                  |  6 +++---
 net/netfilter/nft_ct.c                               |  1 +
 net/netfilter/nft_set_bitmap.c                       |  2 +-
 net/rds/ib.c                                         |  3 +--
 net/rds/tcp.c                                        |  7 ++++---
 net/rxrpc/key.c                                      |  2 +-
 net/rxrpc/recvmsg.c                                  |  8 ++++++--
 net/sched/act_api.c                                  |  9 +++------
 net/sctp/protocol.c                                  |  6 +++++-
 net/sctp/socket.c                                    |  8 ++++++--
 net/tipc/node.c                                      | 12 +++++++-----
 net/xfrm/xfrm_policy.c                               | 29 +++++++++++++++++++++--------
 43 files changed, 209 insertions(+), 224 deletions(-)
