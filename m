From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 00/14] RDS: Assorted bug fixes
Date: Sat, 22 Aug 2015 15:45:21 -0700
Message-ID: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We would like to improve RDS upstream support and in that context, I
started playing with it.  But run into number of issues including as
basic is RDS IB RDMA doesn't work. As part of the debug, I ended up
creating the $subject series which has bunch of assorted fixes. At
least with this series I can run RDS IB RDMA and other tests
successfully.

Some of these fixes have been done by Chris Meson, Andy Grover and
Zach Brown while at Oracle. There are still more kinks with FMR and
error handling and I plan to address them in a follow up series.

Series generated against Linus's master(v4.2-rc-7) but also applies
against next-next cleanly. Its tested on Oracle hardware with IB
fabric for both bcopy as well as RDMA mode. I don't have access
to iWARP hardware so any testing help on iWARP hardware appreciated.

Mukesh Kacker (1):
  RDS: return EMSGSIZE for oversize requests before processing/queueing

Santosh Shilimkar (13):
  RDS: restore return value in rds_cmsg_rdma_args()
  RDS: always free recv frag as we free its ring entry
  RDS: destroy the ib state earlier during shutdown
  RDS: don't update ip address tables if the address hasn't changed
  RDS: make sure we post recv buffers
  RDS: check for congestion updates during rds_send_xmit
  RDS: add a sock_destruct callback debug aid
  RDS: Mark message mapped before transmit
  RDS: Make sure we do a signaled send for large-send
  RDS: Fix assertion level from fatal to warning
  RDS: Don't destroy the rdma id until after we're done using it
  RDS: make sure rds_send_drop_to properly takes the m_rs_lock
  RDS: check for valid cm_id before initiating connection

 net/rds/af_rds.c         |  9 ++++++
 net/rds/connection.c     |  2 ++
 net/rds/ib.h             |  2 +-
 net/rds/ib_cm.c          | 17 +++++++-----
 net/rds/ib_rdma.c        | 11 ++++++--
 net/rds/ib_recv.c        | 71 ++++++++++++++++++++++++++++++++++++++++++------
 net/rds/ib_send.c        |  5 ++++
 net/rds/rdma.c           |  4 ++-
 net/rds/rdma_transport.c | 15 ++++++++--
 net/rds/rds.h            |  1 +
 net/rds/send.c           | 54 ++++++++++++++++++++++++++----------
 11 files changed, 153 insertions(+), 38 deletions(-)


Regards,
Santosh
-- 
1.9.1
