From: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Subject: [PATCH 1/1] RDS: add __printf format attribute to error reporting functions
Date: Fri,  5 Aug 2016 22:11:12 +0200
Message-ID: <20160805201112.30892-1-nicolas.iooss_linux@m4x.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
To: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is helpful to detect at compile-time errors related to format
strings.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
---
 net/rds/ib.h  | 1 +
 net/rds/rds.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 046f7508c06b..45ac8e8e58f4 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -333,6 +333,7 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp);
 void rds_ib_state_change(struct sock *sk);
 int rds_ib_listen_init(void);
 void rds_ib_listen_stop(void);
+__printf(2, 3)
 void __rds_ib_conn_error(struct rds_connection *conn, const char *, ...);
 int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 			     struct rdma_cm_event *event);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index b2d17f0fafa8..fd0bccb2f9f9 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -688,6 +688,7 @@ void __rds_conn_error(struct rds_connection *conn, const char *, ...);
 #define rds_conn_error(conn, fmt...) \
 	__rds_conn_error(conn, KERN_WARNING "RDS: " fmt)
 
+__printf(2, 3)
 void __rds_conn_path_error(struct rds_conn_path *cp, const char *, ...);
 #define rds_conn_path_error(cp, fmt...) \
 	__rds_conn_path_error(cp, KERN_WARNING "RDS: " fmt)
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
