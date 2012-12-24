From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 00/29] rename random32 and net_random to prandom
Date: Mon, 24 Dec 2012 11:13:47 +0900
Message-ID: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 496f2f93b1cc286f5a4f4f9acdc1e5314978683f ("random32: rename random32
to prandom") renamed random32() and srandom32() to prandom_u32() and
prandom_seed() respectively.  Due to the volume of existing random32()
callers, they were preserved as backword compatibility wrapper macros.

This patch series aims for finishing the naming transition and removing
the backword compatibility wrapper macros.

The naming transition is mainly simple substitution work for random32()
and srandom32().  Furthermore, net_random() and net_srandom() are another
wrapper macros for random32() and srandom32().  They also should be
renamed to prandom_* while I'm at it.

This patch series also includes minor cleanup and bugfix which were found
while I was working on the substitution.

Akinobu Mita (29):
  raid6test: use prandom_bytes()
  uuid: use prandom_bytes()
  x86: pageattr-test: remove srandom32 call
  x86: rename random32() to prandom_u32()
  lib/: rename random32() to prandom_u32()
  mm/: rename random32() to prandom_u32()
  kernel/: rename random32() to prandom_u32()
  drbd: rename random32() to prandom_u32()
  infiniband: rename random32() and net_random() to prandom_u32()
  mmc: rename random32() to prandom_u32()
  video/uvesafb: rename random32() to prandom_u32()
  xfs: rename random32() to prandom_u32()
  ubifs: rename random32() to prandom_u32()
  uwb: rename random32() to prandom_u32()
  lguest: rename random32() to prandom_u32()
  scsi: rename random32() to prandom_u32()
  mtd: rename random32() to prandom_u32()
  drivers/net: rename random32() to prandom_u32()
  batman-adv: fix random jitter calculation
  batman-adv: rename random32() to prandom_u32()
  net/sunrpc: rename random32() and net_random() to prandom_u32()
  net/sched: rename random32() and net_random() to prandom_u32()
  net/ipv4: rename net_random() to prandom_u32()
  net/ipv6: rename net_random() to prandom_u32()
  net/netfilter: rename random32() and net_random() to prandom_u32()
  net/core:  rename random32() and net_random() to prandom_u32()
  net/core: remove duplicate statements by do-while loop
  net/: rename net_random() to prandom_u32()
  remove unused net_random(), net_srandom(), random32(), and
    srandom32()

 arch/x86/mm/pageattr-test.c                 |  5 ++--
 crypto/async_tx/raid6test.c                 |  9 ++-----
 drivers/block/drbd/drbd_receiver.c          |  5 ++--
 drivers/infiniband/core/cma.c               |  2 +-
 drivers/infiniband/hw/cxgb3/cxio_resource.c |  4 +--
 drivers/infiniband/hw/cxgb4/id_table.c      |  4 +--
 drivers/infiniband/hw/mlx4/mad.c            |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c     |  2 +-
 drivers/lguest/page_tables.c                |  2 +-
 drivers/mmc/core/core.c                     |  4 +--
 drivers/mtd/nand/nandsim.c                  |  6 ++---
 drivers/mtd/tests/mtd_nandecctest.c         | 10 +++----
 drivers/mtd/tests/mtd_stresstest.c          |  8 +++---
 drivers/mtd/ubi/debug.h                     |  6 ++---
 drivers/net/ethernet/broadcom/cnic.c        |  4 +--
 drivers/net/hamradio/baycom_epp.c           |  2 +-
 drivers/net/hamradio/hdlcdrv.c              |  2 +-
 drivers/net/hamradio/yam.c                  |  2 +-
 drivers/net/wireless/mwifiex/cfg80211.c     |  4 +--
 drivers/scsi/fcoe/fcoe_ctlr.c               |  4 +--
 drivers/scsi/lpfc/lpfc_hbadisc.c            |  6 ++---
 drivers/scsi/qla2xxx/qla_attr.c             |  7 +++--
 drivers/uwb/rsv.c                           |  4 +--
 drivers/video/uvesafb.c                     |  2 +-
 fs/ubifs/debug.c                            |  8 +++---
 fs/ubifs/lpt_commit.c                       | 14 +++++-----
 fs/ubifs/tnc_commit.c                       |  2 +-
 fs/xfs/xfs_alloc.c                          |  2 +-
 fs/xfs/xfs_error.c                          |  2 +-
 fs/xfs/xfs_ialloc.c                         |  2 +-
 fs/xfs/xfs_log.c                            |  2 +-
 include/linux/net.h                         |  3 ---
 include/linux/random.h                      |  7 -----
 include/net/red.h                           |  2 +-
 kernel/rcutree.c                            |  2 +-
 kernel/test_kprobes.c                       |  2 +-
 lib/fault-inject.c                          |  2 +-
 lib/list_sort.c                             |  2 +-
 lib/uuid.c                                  |  8 +-----
 mm/swapfile.c                               |  2 +-
 net/802/garp.c                              |  2 +-
 net/batman-adv/bat_iv_ogm.c                 |  4 +--
 net/core/neighbour.c                        |  4 +--
 net/core/pktgen.c                           | 42 ++++++++++++++---------------
 net/core/stream.c                           |  2 +-
 net/ipv4/devinet.c                          |  2 +-
 net/ipv4/igmp.c                             |  6 ++---
 net/ipv4/inet_connection_sock.c             |  2 +-
 net/ipv4/udp.c                              |  2 +-
 net/ipv6/addrconf.c                         |  4 +--
 net/ipv6/ip6_flowlabel.c                    |  2 +-
 net/ipv6/mcast.c                            |  8 +++---
 net/netfilter/ipvs/ip_vs_conn.c             |  2 +-
 net/netfilter/nf_conntrack_core.c           |  4 +--
 net/netfilter/xt_statistic.c                |  2 +-
 net/openvswitch/actions.c                   |  2 +-
 net/rds/bind.c                              |  2 +-
 net/sched/act_gact.c                        |  2 +-
 net/sched/sch_choke.c                       |  2 +-
 net/sched/sch_fq_codel.c                    |  2 +-
 net/sched/sch_netem.c                       | 19 ++++++-------
 net/sched/sch_sfb.c                         |  4 +--
 net/sched/sch_sfq.c                         |  6 ++---
 net/sctp/socket.c                           |  2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c         |  4 +--
 net/sunrpc/cache.c                          |  2 +-
 net/sunrpc/xprt.c                           |  2 +-
 net/sunrpc/xprtsock.c                       |  2 +-
 net/xfrm/xfrm_state.c                       |  2 +-
 69 files changed, 145 insertions(+), 164 deletions(-)

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
-- 
1.7.11.7
