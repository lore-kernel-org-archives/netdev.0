From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 10/14] RDS: Fix assertion level from fatal to warning
Date: Sat, 22 Aug 2015 15:45:31 -0700
Message-ID: <1440283535-4800-11-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the asserion level since its not fatal and can be hit
in normal execution paths. There is no need to take the
system down.

We keep the WARN_ON() to detect the condition if we get
here with bad pages.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 +-
 net/rds/rdma.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index e49c956..7b7aac8 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -490,7 +490,7 @@ static void __rds_ib_teardown_mr(struct rds_ib_mr *ibmr)
 
 			/* FIXME we need a way to tell a r/w MR
 			 * from a r/o MR */
-			BUG_ON(irqs_disabled());
+			WARN_ON(!page->mapping && irqs_disabled());
 			set_page_dirty(page);
 			put_page(page);
 		}
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 6401b50..c1df9b1 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -451,7 +451,7 @@ void rds_rdma_free_op(struct rm_rdma_op *ro)
 		 * is the case for a RDMA_READ which copies from remote
 		 * to local memory */
 		if (!ro->op_write) {
-			BUG_ON(irqs_disabled());
+			WARN_ON(!page->mapping && irqs_disabled());
 			set_page_dirty(page);
 		}
 		put_page(page);
-- 
1.9.1
