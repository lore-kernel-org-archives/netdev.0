From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 01/14] RDS: restore return value in rds_cmsg_rdma_args()
Date: Sat, 22 Aug 2015 15:45:22 -0700
Message-ID: <1440283535-4800-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In rds_cmsg_rdma_args() 'ret' is used by rds_pin_pages() which returns
number of pinned pages on success. And the same value is returned to the
caller of rds_cmsg_rdma_args() on success which is not intended.

Commit f4a3fc03c1d7 ("RDS: Clean up error handling in rds_cmsg_rdma_args")
removed the 'ret = 0' line which broke RDS RDMA mode.

Fix it by restoring the return value on rds_pin_pages() success
keeping the clean-up in place.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 40084d8..6401b50 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -658,6 +658,8 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 		ret = rds_pin_pages(iov->addr, nr, pages, !op->op_write);
 		if (ret < 0)
 			goto out;
+		else
+			ret = 0;
 
 		rdsdebug("RDS: nr_bytes %u nr %u iov->bytes %llu iov->addr %llx\n",
 			 nr_bytes, nr, iov->bytes, iov->addr);
-- 
1.9.1
