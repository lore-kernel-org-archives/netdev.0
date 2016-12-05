From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 09/18] RDS: RDMA: silence the use_once mr log flood
Date: Sun,  4 Dec 2016 22:57:44 -0800
Message-ID: <1480921073-9140-10-git-send-email-santosh.shilimkar@oracle.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In absence of extension headers, message log will keep
flooding the console. As such even without use_once we can
clean up the MRs so its not really an error case message
so make it debug message

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 4c93bad..8151c49 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -415,7 +415,8 @@ void rds_rdma_unuse(struct rds_sock *rs, u32 r_key, int force)
 	spin_lock_irqsave(&rs->rs_rdma_lock, flags);
 	mr = rds_mr_tree_walk(&rs->rs_rdma_keys, r_key, NULL);
 	if (!mr) {
-		printk(KERN_ERR "rds: trying to unuse MR with unknown r_key %u!\n", r_key);
+		pr_debug("rds: trying to unuse MR with unknown r_key %u!\n",
+			 r_key);
 		spin_unlock_irqrestore(&rs->rs_rdma_lock, flags);
 		return;
 	}
-- 
1.9.1
