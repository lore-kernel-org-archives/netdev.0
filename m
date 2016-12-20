From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] RDS: use rb_entry()
Date: Tue, 20 Dec 2016 22:02:18 +0800
Message-ID: <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/rds/rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 4c93bad..ea96114 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -135,7 +135,7 @@ void rds_rdma_drop_keys(struct rds_sock *rs)
 	/* Release any MRs associated with this socket */
 	spin_lock_irqsave(&rs->rs_rdma_lock, flags);
 	while ((node = rb_first(&rs->rs_rdma_keys))) {
-		mr = container_of(node, struct rds_mr, r_rb_node);
+		mr = rb_entry(node, struct rds_mr, r_rb_node);
 		if (mr->r_trans == rs->rs_transport)
 			mr->r_invalidate = 0;
 		rb_erase(&mr->r_rb_node, &rs->rs_rdma_keys);
-- 
2.9.3
