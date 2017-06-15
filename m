From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Thu, 15 Jun 2017 23:29:26 +0300
Message-ID: <20170615202933.20934-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series focuses on RDMA in general with emphasis on required changes
toward adding iWARP support. The vast majority of the changes introduced
are in qed/qede, with a couple of small changes to qedr
[mentioned below].

The infrastructure changes:
 - Patch #1 adds the ability to pass PBL memory externally for a newly
created chain.
 - Patches #4, #5 rename qede_roce.[ch] into qede_rdma.[ch] + change
prefixes from _roce_ to _rdma_, as the API between qede and qedr is
agnostic to the variant of the RDMA protocol used. These patches also
touch qedr [basically to align it with the renaming, nothing more].
 - Patch #7 replaces the current SPQ async mechanism into serving
registered callbacks [before adding iWARP which would add another client
in need of this sort of functionallity].

The non-infrastrucutre changes:
 - Patches #2, #3 contain DCB-related changes to better align RDMA with
configured DCB.
 - Patch #6 contains a minor [mostly theoretical fix] to release flow.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Michal Kalderon (4):
  qed*: Rename qede_roce.[ch]
  qed*: Set rdma generic functions prefix
  qed: Wait for resources before FUNC_CLOSE
  qed: SPQ async callback registration

Yuval Mintz (3):
  qed: Chain support for external PBL
  qed: RoCE EDPM to honor PFC
  qed: Disable RoCE dpm when DCBx change occurs

 drivers/infiniband/hw/qedr/main.c                  |  10 +-
 drivers/infiniband/hw/qedr/qedr.h                  |   2 +-
 drivers/infiniband/hw/qedr/verbs.c                 |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c         |  24 ++++
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |  35 +++--
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c        |  30 ++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c          |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   6 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c         |  87 ++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_roce.h         |   9 +-
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |  17 +++
 drivers/net/ethernet/qlogic/qed/qed_spq.c          |  60 +++++----
 drivers/net/ethernet/qlogic/qed/qed_sriov.c        |  16 ++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.h        |  18 ---
 drivers/net/ethernet/qlogic/qede/Makefile          |   2 +-
 drivers/net/ethernet/qlogic/qede/qede.h            |   5 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  21 ++-
 .../qlogic/qede/{qede_roce.c => qede_rdma.c}       | 144 ++++++++++-----------
 include/linux/qed/qed_chain.h                      |   7 +
 include/linux/qed/qed_if.h                         |   3 +-
 include/linux/qed/{qede_roce.h => qede_rdma.h}     |  37 +++---
 22 files changed, 348 insertions(+), 202 deletions(-)
 rename drivers/net/ethernet/qlogic/qede/{qede_roce.c => qede_rdma.c} (59%)
 rename include/linux/qed/{qede_roce.h => qede_rdma.h} (67%)

-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
