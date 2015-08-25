From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 6/6] RDS: remove superfluous from rds_ib_alloc_fmr()
Date: Tue, 25 Aug 2015 12:02:03 -0700
Message-ID: <1440529323-4171-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Memory allocated for 'ibmr' uses kzalloc_node() which already
initialises the memory to zero. There is no need to do
memset() 0 on that memory.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index e596dfb..251d1ce 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -360,8 +360,6 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 		goto out_no_cigar;
 	}
 
-	memset(ibmr, 0, sizeof(*ibmr));
-
 	ibmr->fmr = ib_alloc_fmr(rds_ibdev->pd,
 			(IB_ACCESS_LOCAL_WRITE |
 			 IB_ACCESS_REMOTE_READ |
-- 
1.9.1
