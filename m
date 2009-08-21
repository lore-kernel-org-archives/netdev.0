From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 2/5] RDS: Export symbols from core RDS
Date: Fri, 21 Aug 2009 15:28:32 -0700
Message-ID: <1250893715-21939-3-git-send-email-andy.grover@oracle.com>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:38400 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbZHUW2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:48 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMT4T5024750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:29:06 GMT
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that rdma and tcp transports will be modularized,
we need to export a number of functions so they can call them.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/cong.c       |    1 +
 net/rds/connection.c |    5 +++++
 net/rds/info.c       |    3 +++
 net/rds/message.c    |    6 ++++++
 net/rds/page.c       |    1 +
 net/rds/recv.c       |    4 ++++
 net/rds/send.c       |    3 +++
 net/rds/stats.c      |    2 ++
 net/rds/threads.c    |    2 ++
 net/rds/transport.c  |    2 ++
 10 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index 710e459..dd2711d 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -254,6 +254,7 @@ void rds_cong_map_updated(struct rds_cong_map *map, uint64_t portmask)
 		read_unlock_irqrestore(&rds_cong_monitor_lock, flags);
 	}
 }
+EXPORT_SYMBOL_GPL(rds_cong_map_updated);
 
 int rds_cong_updated_since(unsigned long *recent)
 {
diff --git a/net/rds/connection.c b/net/rds/connection.c
index b420a20..cc8b568 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -255,12 +255,14 @@ struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
 {
 	return __rds_conn_create(laddr, faddr, trans, gfp, 0);
 }
+EXPORT_SYMBOL_GPL(rds_conn_create);
 
 struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp)
 {
 	return __rds_conn_create(laddr, faddr, trans, gfp, 1);
 }
+EXPORT_SYMBOL_GPL(rds_conn_create_outgoing);
 
 void rds_conn_destroy(struct rds_connection *conn)
 {
@@ -303,6 +305,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 
 	rds_conn_count--;
 }
+EXPORT_SYMBOL_GPL(rds_conn_destroy);
 
 static void rds_conn_message_info(struct socket *sock, unsigned int len,
 				  struct rds_info_iterator *iter,
@@ -406,6 +409,7 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 
 	spin_unlock_irqrestore(&rds_conn_lock, flags);
 }
+EXPORT_SYMBOL_GPL(rds_for_each_conn_info);
 
 static int rds_conn_info_visitor(struct rds_connection *conn,
 				  void *buffer)
@@ -481,6 +485,7 @@ void rds_conn_drop(struct rds_connection *conn)
 	atomic_set(&conn->c_state, RDS_CONN_ERROR);
 	queue_work(rds_wq, &conn->c_down_w);
 }
+EXPORT_SYMBOL_GPL(rds_conn_drop);
 
 /*
  * An error occurred on the connection
diff --git a/net/rds/info.c b/net/rds/info.c
index 62aeef3..814a91a 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -79,6 +79,7 @@ void rds_info_register_func(int optname, rds_info_func func)
 	rds_info_funcs[offset] = func;
 	spin_unlock(&rds_info_lock);
 }
+EXPORT_SYMBOL_GPL(rds_info_register_func);
 
 void rds_info_deregister_func(int optname, rds_info_func func)
 {
@@ -91,6 +92,7 @@ void rds_info_deregister_func(int optname, rds_info_func func)
 	rds_info_funcs[offset] = NULL;
 	spin_unlock(&rds_info_lock);
 }
+EXPORT_SYMBOL_GPL(rds_info_deregister_func);
 
 /*
  * Typically we hold an atomic kmap across multiple rds_info_copy() calls
@@ -137,6 +139,7 @@ void rds_info_copy(struct rds_info_iterator *iter, void *data,
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(rds_info_copy);
 
 /*
  * @optval points to the userspace buffer that the information snapshot
diff --git a/net/rds/message.c b/net/rds/message.c
index 5a15dc8..ca50a8e 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -50,6 +50,7 @@ void rds_message_addref(struct rds_message *rm)
 	rdsdebug("addref rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
 	atomic_inc(&rm->m_refcount);
 }
+EXPORT_SYMBOL_GPL(rds_message_addref);
 
 /*
  * This relies on dma_map_sg() not touching sg[].page during merging.
@@ -92,6 +93,7 @@ void rds_message_put(struct rds_message *rm)
 		kfree(rm);
 	}
 }
+EXPORT_SYMBOL_GPL(rds_message_put);
 
 void rds_message_inc_free(struct rds_incoming *inc)
 {
@@ -108,6 +110,7 @@ void rds_message_populate_header(struct rds_header *hdr, __be16 sport,
 	hdr->h_sequence = cpu_to_be64(seq);
 	hdr->h_exthdr[0] = RDS_EXTHDR_NONE;
 }
+EXPORT_SYMBOL_GPL(rds_message_populate_header);
 
 int rds_message_add_extension(struct rds_header *hdr,
 		unsigned int type, const void *data, unsigned int len)
@@ -133,6 +136,7 @@ int rds_message_add_extension(struct rds_header *hdr,
 	dst[len] = RDS_EXTHDR_NONE;
 	return 1;
 }
+EXPORT_SYMBOL_GPL(rds_message_add_extension);
 
 /*
  * If a message has extension headers, retrieve them here.
@@ -208,6 +212,7 @@ int rds_message_add_rdma_dest_extension(struct rds_header *hdr, u32 r_key, u32 o
 	ext_hdr.h_rdma_offset = cpu_to_be32(offset);
 	return rds_message_add_extension(hdr, RDS_EXTHDR_RDMA_DEST, &ext_hdr, sizeof(ext_hdr));
 }
+EXPORT_SYMBOL_GPL(rds_message_add_rdma_dest_extension);
 
 struct rds_message *rds_message_alloc(unsigned int nents, gfp_t gfp)
 {
@@ -399,4 +404,5 @@ void rds_message_unmapped(struct rds_message *rm)
 	if (waitqueue_active(&rds_message_flush_waitq))
 		wake_up(&rds_message_flush_waitq);
 }
+EXPORT_SYMBOL_GPL(rds_message_unmapped);
 
diff --git a/net/rds/page.c b/net/rds/page.c
index c460743..55c21ef 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -81,6 +81,7 @@ int rds_page_copy_user(struct page *page, unsigned long offset,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(rds_page_copy_user);
 
 /*
  * Message allocation uses this to build up regions of a message.
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 86bc1a0..fdff33c 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -46,12 +46,14 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 	inc->i_saddr = saddr;
 	inc->i_rdma_cookie = 0;
 }
+EXPORT_SYMBOL_GPL(rds_inc_init);
 
 void rds_inc_addref(struct rds_incoming *inc)
 {
 	rdsdebug("addref inc %p ref %d\n", inc, atomic_read(&inc->i_refcount));
 	atomic_inc(&inc->i_refcount);
 }
+EXPORT_SYMBOL_GPL(rds_inc_addref);
 
 void rds_inc_put(struct rds_incoming *inc)
 {
@@ -62,6 +64,7 @@ void rds_inc_put(struct rds_incoming *inc)
 		inc->i_conn->c_trans->inc_free(inc);
 	}
 }
+EXPORT_SYMBOL_GPL(rds_inc_put);
 
 static void rds_recv_rcvbuf_delta(struct rds_sock *rs, struct sock *sk,
 				  struct rds_cong_map *map,
@@ -237,6 +240,7 @@ out:
 	if (rs)
 		rds_sock_put(rs);
 }
+EXPORT_SYMBOL_GPL(rds_recv_incoming);
 
 /*
  * be very careful here.  This is being called as the condition in
diff --git a/net/rds/send.c b/net/rds/send.c
index a4a7f42..28c88ff 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -439,6 +439,7 @@ void rds_rdma_send_complete(struct rds_message *rm, int status)
 		sock_put(rds_rs_to_sk(rs));
 	}
 }
+EXPORT_SYMBOL_GPL(rds_rdma_send_complete);
 
 /*
  * This is the same as rds_rdma_send_complete except we
@@ -494,6 +495,7 @@ out:
 
 	return found;
 }
+EXPORT_SYMBOL_GPL(rds_send_get_message);
 
 /*
  * This removes messages from the socket's list if they're on it.  The list
@@ -610,6 +612,7 @@ void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 	/* now remove the messages from the sock list as needed */
 	rds_send_remove_from_sock(&list, RDS_RDMA_SUCCESS);
 }
+EXPORT_SYMBOL_GPL(rds_send_drop_acked);
 
 void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 {
diff --git a/net/rds/stats.c b/net/rds/stats.c
index 91d8c58..7598eb0 100644
--- a/net/rds/stats.c
+++ b/net/rds/stats.c
@@ -37,6 +37,7 @@
 #include "rds.h"
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_statistics, rds_stats);
+EXPORT_PER_CPU_SYMBOL_GPL(rds_stats);
 
 /* :.,$s/unsigned long\>.*\<s_\(.*\);/"\1",/g */
 
@@ -90,6 +91,7 @@ void rds_stats_info_copy(struct rds_info_iterator *iter,
 		rds_info_copy(iter, &ctr, sizeof(ctr));
 	}
 }
+EXPORT_SYMBOL_GPL(rds_stats_info_copy);
 
 /*
  * This gives global counters across all the transports.  The strings
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 828a1bf..dd7e0ca 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -68,6 +68,7 @@
  *	(TCP, IB/RDMA) to provide the necessary synchronisation.
  */
 struct workqueue_struct *rds_wq;
+EXPORT_SYMBOL_GPL(rds_wq);
 
 void rds_connect_complete(struct rds_connection *conn)
 {
@@ -89,6 +90,7 @@ void rds_connect_complete(struct rds_connection *conn)
 	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 	queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 }
+EXPORT_SYMBOL_GPL(rds_connect_complete);
 
 /*
  * This random exponential backoff is relied on to eventually resolve racing
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 767da61..56a5309 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -53,6 +53,7 @@ int rds_trans_register(struct rds_transport *trans)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(rds_trans_register);
 
 void rds_trans_unregister(struct rds_transport *trans)
 {
@@ -63,6 +64,7 @@ void rds_trans_unregister(struct rds_transport *trans)
 
 	up_write(&rds_trans_sem);
 }
+EXPORT_SYMBOL_GPL(rds_trans_unregister);
 
 struct rds_transport *rds_trans_get_preferred(__be32 addr)
 {
-- 
1.6.0.4

