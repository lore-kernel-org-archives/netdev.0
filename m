From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] rds: Remove unused rds_conn_error
Date: Sat, 15 Oct 2016 11:53:21 -0700
Message-ID: <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
References: <cover.1476557523.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0056.hostedemail.com ([216.40.44.56]:49738 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751392AbcJOSxa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 14:53:30 -0400
In-Reply-To: <cover.1476557523.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro's last use was removed in commit d769ef81d5b59
("RDS: Update rds_conn_shutdown to work with rds_conn_path")
so make the macro and the __rds_conn_error function definition
and declaration disappear.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rds/connection.c | 15 ---------------
 net/rds/rds.h        |  4 ----
 2 files changed, 19 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index f5058559bb08..13f459dad4ef 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -689,21 +689,6 @@ void rds_conn_connect_if_down(struct rds_connection *conn)
 }
 EXPORT_SYMBOL_GPL(rds_conn_connect_if_down);
 
-/*
- * An error occurred on the connection
- */
-void
-__rds_conn_error(struct rds_connection *conn, const char *fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	vprintk(fmt, ap);
-	va_end(ap);
-
-	rds_conn_drop(conn);
-}
-
 void
 __rds_conn_path_error(struct rds_conn_path *cp, const char *fmt, ...)
 {
diff --git a/net/rds/rds.h b/net/rds/rds.h
index fd0bccb2f9f9..25532a46602f 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -683,10 +683,6 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 			  struct rds_info_lengths *lens,
 			  int (*visitor)(struct rds_connection *, void *),
 			  size_t item_len);
-__printf(2, 3)
-void __rds_conn_error(struct rds_connection *conn, const char *, ...);
-#define rds_conn_error(conn, fmt...) \
-	__rds_conn_error(conn, KERN_WARNING "RDS: " fmt)
 
 __printf(2, 3)
 void __rds_conn_path_error(struct rds_conn_path *cp, const char *, ...);
-- 
2.10.0.rc2.1.g053435c
