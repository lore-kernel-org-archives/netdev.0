From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 03/18] RDS: IB: include faddr in connection log
Date: Tue,  6 Dec 2016 20:01:41 -0800
Message-ID: <1481083316-11648-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also use pr_* for it.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_cm.c   | 19 +++++++++----------
 net/rds/ib_recv.c |  4 ++--
 net/rds/ib_send.c |  4 ++--
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 5b2ab95..b9da1e5 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -113,19 +113,18 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	}
 
 	if (conn->c_version < RDS_PROTOCOL(3, 1)) {
-		printk(KERN_NOTICE "RDS/IB: Connection to %pI4 version %u.%u failed,"
-		       " no longer supported\n",
-		       &conn->c_faddr,
-		       RDS_PROTOCOL_MAJOR(conn->c_version),
-		       RDS_PROTOCOL_MINOR(conn->c_version));
+		pr_notice("RDS/IB: Connection <%pI4,%pI4> version %u.%u no longer supported\n",
+			  &conn->c_laddr, &conn->c_faddr,
+			  RDS_PROTOCOL_MAJOR(conn->c_version),
+			  RDS_PROTOCOL_MINOR(conn->c_version));
 		rds_conn_destroy(conn);
 		return;
 	} else {
-		printk(KERN_NOTICE "RDS/IB: connected to %pI4 version %u.%u%s\n",
-		       &conn->c_faddr,
-		       RDS_PROTOCOL_MAJOR(conn->c_version),
-		       RDS_PROTOCOL_MINOR(conn->c_version),
-		       ic->i_flowctl ? ", flow control" : "");
+		pr_notice("RDS/IB: connected <%pI4,%pI4> version %u.%u%s\n",
+			  &conn->c_laddr, &conn->c_faddr,
+			  RDS_PROTOCOL_MAJOR(conn->c_version),
+			  RDS_PROTOCOL_MINOR(conn->c_version),
+			  ic->i_flowctl ? ", flow control" : "");
 	}
 
 	/*
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 606a11f..6803b75 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -980,8 +980,8 @@ void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic,
 	} else {
 		/* We expect errors as the qp is drained during shutdown */
 		if (rds_conn_up(conn) || rds_conn_connecting(conn))
-			rds_ib_conn_error(conn, "recv completion on %pI4 had status %u (%s), disconnecting and reconnecting\n",
-					  &conn->c_faddr,
+			rds_ib_conn_error(conn, "recv completion on <%pI4,%pI4> had status %u (%s), disconnecting and reconnecting\n",
+					  &conn->c_laddr, &conn->c_faddr,
 					  wc->status,
 					  ib_wc_status_msg(wc->status));
 	}
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 84d90c9..19eca5c 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -300,8 +300,8 @@ void rds_ib_send_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc)
 
 	/* We expect errors as the qp is drained during shutdown */
 	if (wc->status != IB_WC_SUCCESS && rds_conn_up(conn)) {
-		rds_ib_conn_error(conn, "send completion on %pI4 had status %u (%s), disconnecting and reconnecting\n",
-				  &conn->c_faddr, wc->status,
+		rds_ib_conn_error(conn, "send completion on <%pI4,%pI4> had status %u (%s), disconnecting and reconnecting\n",
+				  &conn->c_laddr, &conn->c_faddr, wc->status,
 				  ib_wc_status_msg(wc->status));
 	}
 }
-- 
1.9.1
