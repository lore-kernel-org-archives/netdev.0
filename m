From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 18/18] RDS: IB: add missing connection cache usage info
Date: Tue,  6 Dec 2016 20:01:56 -0800
Message-ID: <1481083316-11648-19-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rds-tools already support it.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 include/uapi/linux/rds.h | 1 +
 net/rds/ib.c             | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 3833113..410ae3c 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -183,6 +183,7 @@ struct rds_info_rdma_connection {
 	uint32_t	max_send_sge;
 	uint32_t	rdma_mr_max;
 	uint32_t	rdma_mr_size;
+	uint32_t	cache_allocs;
 };
 
 /* RDS message Receive Path Latency points */
diff --git a/net/rds/ib.c b/net/rds/ib.c
index 8d70884..b5e2699 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -313,6 +313,7 @@ static int rds_ib_conn_info_visitor(struct rds_connection *conn,
 		iinfo->max_send_wr = ic->i_send_ring.w_nr;
 		iinfo->max_recv_wr = ic->i_recv_ring.w_nr;
 		iinfo->max_send_sge = rds_ibdev->max_sge;
+		iinfo->cache_allocs = atomic_read(&ic->i_cache_allocs);
 		rds_ib_get_mr_info(rds_ibdev, iinfo);
 	}
 	return 1;
-- 
1.9.1
