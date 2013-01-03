From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v2 00/26] rename random32 to prandom
Date: Thu,  3 Jan 2013 21:18:56 +0900
Message-ID: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
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
and srandom32().  But this patch series also includes minor cleanup
which was found while I was working on the substitution.

* Changes from v1
- leave all net_random() and net_srandom callers as-is and preserve the
  macro definisions. Because that is a useful indirection.
  Spotted by Neil Horman.
- remove batman-adv fix which has been applied to net
- collect Acked-by:

Akinobu Mita (26):
  raid6test: use prandom_bytes()
  uuid: use prandom_bytes()
  x86: pageattr-test: remove srandom32 call
  x86: rename random32() to prandom_u32()
  lib/: rename random32() to prandom_u32()
  mm/: rename random32() to prandom_u32()
  kernel/: rename random32() to prandom_u32()
  drbd: rename random32() to prandom_u32()
  infiniband: rename random32() to prandom_u32()
  mmc: rename random32() to prandom_u32()
  video/uvesafb: rename random32() to prandom_u32()
  xfs: rename random32() to prandom_u32()
  ubifs: rename random32() to prandom_u32()
  uwb: rename random32() to prandom_u32()
  lguest: rename random32() to prandom_u32()
  scsi: rename random32() to prandom_u32()
  mtd: rename random32() to prandom_u32()
  drivers/net: rename random32() to prandom_u32()
  batman-adv: rename random32() to prandom_u32()
  net/sunrpc: rename random32() to prandom_u32()
  net/sched: rename random32() to prandom_u32()
  net/netfilter: rename random32() to prandom_u32()
  net/core:  rename random32() to prandom_u32()
  net/core: remove duplicate statements by do-while loop
  net: rename random32 to prandom
  remove unused random32() and srandom32()

 arch/x86/mm/pageattr-test.c                 |  5 ++--
 crypto/async_tx/raid6test.c                 |  9 ++-----
 drivers/block/drbd/drbd_receiver.c          |  5 ++--
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
 include/linux/net.h                         |  4 +--
 include/linux/random.h                      |  7 -----
 kernel/rcutree.c                            |  2 +-
 kernel/test_kprobes.c                       |  2 +-
 lib/fault-inject.c                          |  2 +-
 lib/list_sort.c                             |  2 +-
 lib/uuid.c                                  |  8 +-----
 mm/swapfile.c                               |  2 +-
 net/batman-adv/bat_iv_ogm.c                 |  4 +--
 net/core/pktgen.c                           | 42 ++++++++++++++---------------
 net/netfilter/nf_conntrack_core.c           |  4 +--
 net/sched/sch_choke.c                       |  2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c         |  4 +--
 43 files changed, 102 insertions(+), 119 deletions(-)

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
-- 
1.7.11.7
