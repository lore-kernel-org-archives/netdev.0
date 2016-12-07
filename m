From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 00/18] net: RDS updates
Date: Tue,  6 Dec 2016 20:01:38 -0800
Message-ID: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1->v2:
Re-aligned indentation in patch 'RDS: mark few internal functions

Series consist of:
 - RDMA transport fixes for map failure, listen sequence, handler panic and
   composite message notification.
 - Couple of sparse fixes.
 - Message logging improvements for bind failure, use once mr semantics
   and connection remote address, active end point.
 - Performance improvement for RDMA transport by reducing the post send
   pressure on the queue and spreading the CQ vectors.
 - Useful statistics for socket send/recv usage and receive cache usage.
   rds-tools already equipped to parse this info.
 - Additional RDS CMSG used by application to track the RDS message
   stages for certain type of traffic to find out latency spots.
   Can be enabled/disabled per socket.
    
Series generated against 'net-next'. Full patchset is also available on
below git tree.

The following changes since commit adc176c5472214971d77c1a61c83db9b01e9cdc7:

  ipv6 addrconf: Implemented enhanced DAD (RFC7527) (2016-12-03 23:21:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.10/net-next/rds_v2

for you to fetch changes up to ccb54a64f5e73a7c3ea9f74effdac0bdd1f27ac4:

  RDS: IB: add missing connection cache usage info (2016-12-05 17:20:27 -0800)

----------------------------------------------------------------
Avinash Repaka (1):
  RDS: make message size limit compliant with spec

Qing Huang (1):
  RDS: RDMA: start rdma listening after init

Santosh Shilimkar (15):
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
  RDS: IB: add missing connection cache usage info

Venkat Venkatsubra (1):
  RDS: add stat for socket recv memory usage

 include/uapi/linux/rds.h | 34 ++++++++++++++++++
 net/rds/af_rds.c         | 28 +++++++++++++++
 net/rds/bind.c           |  4 +--
 net/rds/connection.c     | 10 +++---
 net/rds/ib.c             | 12 +++++++
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
 18 files changed, 337 insertions(+), 65 deletions(-)

-- 
1.9.1
