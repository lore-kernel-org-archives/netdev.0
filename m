From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 00/13] RDS: Major clean-up with couple of new features for 4.6
Date: Fri, 26 Feb 2016 21:43:45 -0800
Message-ID: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Series is generated against net-next but also applies against Linus's tip
cleanly. The diff-stat looks bit scary since almost ~4K lines of code is
getting removed.

Brief summary of the series:

- Drop the stale iWARP support:
	RDS iWarp support code has become stale and non testable for
	sometime.  As discussed and agreed earlier on list [1], am dropping
	its support for good. If new iWarp user(s) shows up in future,
	the plan is to adapt existing IB RDMA with special sink case.
- RDS gets SO_TIMESTAMP support
- Long due RDS maintainer entry gets updated
- Some RDS IB code refactoring towards new FastReg Memory registration (FRMR)
- Lastly the initial support for FRMR
	
RDS IB RDMA performance with FRMR is not yet as good as FMR and I do have
some patches in progress to address that. But they are not ready for 4.6
so I left them out of this series. 

Also am keeping eye on new CQ API adaptations like other ULPs doing and
will try to adapt RDS for the same most likely in 4.7 timeframe. 

Entire patchset is available below git tree:
	git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.6/net-next/rds

Feedback/comments welcome !!

Santosh Shilimkar (12):
  RDS: Drop stale iWARP RDMA transport
  RDS: Add support for SO_TIMESTAMP for incoming messages
  MAINTAINERS: update RDS entry
  RDS: IB: Remove the RDS_IB_SEND_OP dependency
  RDS: IB: Re-organise ibmr code
  RDS: IB: create struct rds_ib_fmr
  RDS: IB: move FMR code to its own file
  RDS: IB: add connection info to ibmr
  RDS: IB: handle the RDMA CM time wait event
  RDS: IB: add mr reused stats
  RDS: IB: add Fastreg MR (FRMR) detection support
  RDS: IB: allocate extra space on queues for FRMR support

Avinash Repaka (1):
  RDS: IB: Support Fastreg MR (FRMR) memory registration mode

 Documentation/networking/rds.txt |   4 +-
 MAINTAINERS                      |   6 +-
 net/rds/Kconfig                  |   7 +-
 net/rds/Makefile                 |   4 +-
 net/rds/af_rds.c                 |  26 ++
 net/rds/ib.c                     |  51 +-
 net/rds/ib.h                     |  37 +-
 net/rds/ib_cm.c                  |  59 ++-
 net/rds/ib_fmr.c                 | 248 ++++++++++
 net/rds/ib_frmr.c                | 376 +++++++++++++++
 net/rds/ib_mr.h                  | 148 ++++++
 net/rds/ib_rdma.c                | 492 ++++++--------------
 net/rds/ib_send.c                |   6 +-
 net/rds/ib_stats.c               |   2 +
 net/rds/iw.c                     | 312 -------------
 net/rds/iw.h                     | 398 ----------------
 net/rds/iw_cm.c                  | 769 ------------------------------
 net/rds/iw_rdma.c                | 837 ---------------------------------
 net/rds/iw_recv.c                | 904 ------------------------------------
 net/rds/iw_ring.c                | 169 -------
 net/rds/iw_send.c                | 981 ---------------------------------------
 net/rds/iw_stats.c               |  95 ----
 net/rds/iw_sysctl.c              | 123 -----
 net/rds/rdma_transport.c         |  21 +-
 net/rds/rdma_transport.h         |   5 -
 net/rds/rds.h                    |   1 +
 net/rds/recv.c                   |  20 +-
 27 files changed, 1068 insertions(+), 5033 deletions(-)
 create mode 100644 net/rds/ib_fmr.c
 create mode 100644 net/rds/ib_frmr.c
 create mode 100644 net/rds/ib_mr.h
 delete mode 100644 net/rds/iw.c
 delete mode 100644 net/rds/iw.h
 delete mode 100644 net/rds/iw_cm.c
 delete mode 100644 net/rds/iw_rdma.c
 delete mode 100644 net/rds/iw_recv.c
 delete mode 100644 net/rds/iw_ring.c
 delete mode 100644 net/rds/iw_send.c
 delete mode 100644 net/rds/iw_stats.c
 delete mode 100644 net/rds/iw_sysctl.c


Regards,
Santosh

[1] http://www.spinics.net/lists/linux-rdma/msg30769.html

-- 
1.9.1
