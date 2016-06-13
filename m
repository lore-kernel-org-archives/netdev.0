From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 02/17] RDS: add t_mp_capable bit to be set by MP capable transports
Date: Mon, 13 Jun 2016 09:44:27 -0700
Message-ID: <ecf63bfb72c2fca1e8ce89aca7d639480252c797.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25855 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161195AbcFMQpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:13 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The t_mp_capable bit will be used in the core rds module
to support multipathing logic when the transport supports it.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index ca31a07..28f001c 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -446,7 +446,8 @@ struct rds_transport {
 	char			t_name[TRANSNAMSIZ];
 	struct list_head	t_item;
 	struct module		*t_owner;
-	unsigned int		t_prefer_loopback:1;
+	unsigned int		t_prefer_loopback:1,
+				t_mp_capable:1;
 	unsigned int		t_type;
 
 	int (*laddr_check)(struct net *net, __be32 addr);
@@ -673,6 +674,7 @@ rds_conn_path_transition(struct rds_conn_path *cp, int old, int new)
 static inline int
 rds_conn_transition(struct rds_connection *conn, int old, int new)
 {
+	WARN_ON(conn->c_trans->t_mp_capable);
 	return rds_conn_path_transition(&conn->c_path[0], old, new);
 }
 
@@ -685,6 +687,7 @@ rds_conn_path_state(struct rds_conn_path *cp)
 static inline int
 rds_conn_state(struct rds_connection *conn)
 {
+	WARN_ON(conn->c_trans->t_mp_capable);
 	return rds_conn_path_state(&conn->c_path[0]);
 }
 
@@ -697,6 +700,7 @@ rds_conn_path_up(struct rds_conn_path *cp)
 static inline int
 rds_conn_up(struct rds_connection *conn)
 {
+	WARN_ON(conn->c_trans->t_mp_capable);
 	return rds_conn_path_up(&conn->c_path[0]);
 }
 
@@ -709,6 +713,7 @@ rds_conn_path_connecting(struct rds_conn_path *cp)
 static inline int
 rds_conn_connecting(struct rds_connection *conn)
 {
+	WARN_ON(conn->c_trans->t_mp_capable);
 	return rds_conn_path_connecting(&conn->c_path[0]);
 }
 
-- 
1.7.1
