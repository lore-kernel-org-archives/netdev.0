From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 00/17] net: RDS updates
Date: Mon,  2 Jan 2017 14:45:35 -0800
Message-ID: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50535 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756907AbdABWqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:46:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3:
- Re-based against latest net-next head.
- Dropped a user visible change after discussing with David Miller.
  It needs some more work to fully support old/new tools matrix.
- Addressed Dave's comment about bool usage in patch
  "RDS: IB: track and log active side..." 

v1->v2:
Re-aligned indentation in patch 'RDS: mark few internal functions..."

Series consist of:
 - RDMA transport fixes for map failure, listen sequence, handler panic and
   composite message notification.
 - Couple of sparse fixes.
 - Message logging improvements for bind failure, use once mr semantics
   and connection remote address, active end point.
 - Performance improvement for RDMA transport by reducing the post send
   pressure on the queue and spreading the CQ vectors.
 - Useful statistics for socket send/recv usage and receive cache usage.
 - Additional RDS CMSG used by application to track the RDS message
   stages for certain type of traffic to find out latency spots.
   Can be enabled/disabled per socket.
    
Series generated against 'net-next'. Full patchset is also available on
below git tree.


The following changes since commit 525dfa2cdce4f5ab76251b5e57ebabf4f2dfc40c:

  Merge branch 'mlx5-odp' (2017-01-02 15:51:21 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.11/net-next/rds_v3

for you to fetch changes up to 3289025aedc018f8fd9d0e37fb9efa0c6d531ffa:

  RDS: add receive message trace used by application (2017-01-02 14:02:59 -0800)

----------------------------------------------------------------
Avinash Repaka (1):
  RDS: make message size limit compliant with spec

Qing Huang (1):
  RDS: RDMA: start rdma listening after init

Santosh Shilimkar (14):
  RDS: log the address on bind failure
  RDS: mark few internal functions static to make sparse build happy
  RDS: IB: include faddr in connection log
  RDS: IB: make the transport retry count smallest
  RDS: RDMA: fix the ib_map_mr_sg_zbva() argument
  RDS: RDMA: return appropriate error on rdma map failures
  RDS: IB: split the mr registration and invalidation path
  RDS: RDMA: silence the use_once mr log flood
  RDS: IB: track and log active side endpoint in connection
  RDS: IB: add few useful cache stasts
  RDS: IB: Add vector spreading for cqs
  RDS: RDMA: Fix the composite message user notification
  RDS: IB: fix panic due to handlers running post teardown
  RDS: add receive message trace used by application

Venkat Venkatsubra (1):
  RDS: add stat for socket recv memory usage

 include/uapi/linux/rds.h | 33 ++++++++++++++++++
 net/rds/af_rds.c         | 28 +++++++++++++++
 net/rds/bind.c           |  4 +--
 net/rds/connection.c     | 10 +++---
 net/rds/ib.c             | 11 ++++++
 net/rds/ib.h             | 22 ++++++++++--
 net/rds/ib_cm.c          | 89 ++++++++++++++++++++++++++++++++++++++----------
 net/rds/ib_frmr.c        | 16 +++++----
 net/rds/ib_recv.c        | 14 ++++++--
 net/rds/ib_send.c        | 29 +++++++++-------
 net/rds/ib_stats.c       |  2 ++
 net/rds/rdma.c           | 22 ++++++++++--
 net/rds/rdma_transport.c | 11 ++----
 net/rds/rds.h            | 17 +++++++++
 net/rds/recv.c           | 36 ++++++++++++++++++--
 net/rds/send.c           | 50 ++++++++++++++++++++++++---
 net/rds/tcp_listen.c     |  1 +
 net/rds/tcp_recv.c       |  5 +++
 18 files changed, 335 insertions(+), 65 deletions(-)

-- 
1.9.1
