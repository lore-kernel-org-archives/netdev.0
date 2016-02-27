From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 09/13] RDS: IB: handle the RDMA CM time wait event
Date: Fri, 26 Feb 2016 21:43:54 -0800
Message-ID: <1456551838-9080-10-git-send-email-santosh.shilimkar@oracle.com>
References: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop the RDS connection on RDMA_CM_EVENT_TIMEWAIT_EXIT so that
it can reconnect and resume.

While testing fastreg, this error happened in couple of tests but
was getting un-noticed.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma_transport.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 4f4b3d8..7220beb 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -117,6 +117,14 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 		rds_conn_drop(conn);
 		break;
 
+	case RDMA_CM_EVENT_TIMEWAIT_EXIT:
+		if (conn) {
+			pr_info("RDS: RDMA_CM_EVENT_TIMEWAIT_EXIT event: dropping connection %pI4->%pI4\n",
+				&conn->c_laddr, &conn->c_faddr);
+			rds_conn_drop(conn);
+		}
+		break;
+
 	default:
 		/* things like device disconnect? */
 		printk(KERN_ERR "RDS: unknown event %u (%s)!\n",
-- 
1.9.1
