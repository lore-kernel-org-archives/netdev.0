From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 04/17] RDS: rds_inc_path_init() helper function for MP capable transports
Date: Mon, 13 Jun 2016 09:44:29 -0700
Message-ID: <a498ec72b2287dc2618b4aaa2f5772a320ba20a0.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40947 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965107AbcFMQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:15 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

t_mp_capable transports can use rds_inc_path_init to initialize
all fields in struct rds_incoming, including the i_conn_path.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h  |    2 ++
 net/rds/recv.c |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index 7c85b2d..c3b14cc 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -764,6 +764,8 @@ void rds_page_exit(void);
 /* recv.c */
 void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 		  __be32 saddr);
+void rds_inc_path_init(struct rds_incoming *inc, struct rds_conn_path *conn,
+		       __be32 saddr);
 void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		       struct rds_incoming *inc, gfp_t gfp);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index e36652c..6d7bd63 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -53,6 +53,20 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 }
 EXPORT_SYMBOL_GPL(rds_inc_init);
 
+void rds_inc_path_init(struct rds_incoming *inc, struct rds_conn_path *cp,
+		       __be32 saddr)
+{
+	atomic_set(&inc->i_refcount, 1);
+	INIT_LIST_HEAD(&inc->i_item);
+	inc->i_conn = cp->cp_conn;
+	inc->i_conn_path = cp;
+	inc->i_saddr = saddr;
+	inc->i_rdma_cookie = 0;
+	inc->i_rx_tstamp.tv_sec = 0;
+	inc->i_rx_tstamp.tv_usec = 0;
+}
+EXPORT_SYMBOL_GPL(rds_inc_path_init);
+
 static void rds_inc_addref(struct rds_incoming *inc)
 {
 	rdsdebug("addref inc %p ref %d\n", inc, atomic_read(&inc->i_refcount));
-- 
1.7.1
