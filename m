From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 6/7] tipc: rename temporarily named functions
Date: Mon, 14 Jul 2014 23:54:25 -0400
Message-ID: <1405396466-4594-7-git-send-email-jon.maloy@ericsson.com>
References: <1405396466-4594-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.gq1.yahoo.com ([98.137.12.181]:29893 "HELO
	smtp106.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756004AbaGODy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 23:54:56 -0400
In-Reply-To: <1405396466-4594-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous commit, we can now give the functions with temporary
names, such as tipc_link_xmit2(), tipc_msg_build2() etc., their proper
names.

There are no functional changes in this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c      |    6 +++---
 net/tipc/bcast.h      |    2 +-
 net/tipc/link.c       |   18 +++++++++---------
 net/tipc/link.h       |    4 ++--
 net/tipc/msg.c        |    6 +++---
 net/tipc/msg.h        |    4 ++--
 net/tipc/name_distr.c |    4 ++--
 net/tipc/port.c       |   10 +++++-----
 net/tipc/socket.c     |   20 ++++++++++----------
 9 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 4081251..446295d 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -389,13 +389,13 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 	tipc_node_unlock(n_ptr);
 }
 
-/* tipc_bclink_xmit2 - broadcast buffer chain to all nodes in cluster
- *                     and to identified node local sockets
+/* tipc_bclink_xmit - broadcast buffer chain to all nodes in cluster
+ *                    and to identified node local sockets
  * @buf: chain of buffers containing message
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_bclink_xmit2(struct sk_buff *buf)
+int tipc_bclink_xmit(struct sk_buff *buf)
 {
 	int rc = 0;
 	struct sk_buff *clbuf;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index af6b657..4875d95 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -98,6 +98,6 @@ int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
-int tipc_bclink_xmit2(struct sk_buff *buf);
+int tipc_bclink_xmit(struct sk_buff *buf);
 
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 28730dd..fb1485d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -706,7 +706,7 @@ static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
 }
 
 /**
- * __tipc_link_xmit2(): same as tipc_link_xmit2, but destlink is known & locked
+ * __tipc_link_xmit(): same as tipc_link_xmit, but destlink is known & locked
  * @link: link to use
  * @buf: chain of buffers containing message
  * Consumes the buffer chain, except when returning -ELINKCONG
@@ -715,7 +715,7 @@ static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
  * Only the socket functions tipc_send_stream() and tipc_send_packet() need
  * to act on the return value, since they may need to do more send attempts.
  */
-int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf)
+int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	uint psz = msg_size(msg);
@@ -783,7 +783,7 @@ int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf)
 }
 
 /**
- * tipc_link_xmit2() is the general link level function for message sending
+ * tipc_link_xmit() is the general link level function for message sending
  * @buf: chain of buffers containing message
  * @dsz: amount of user data to be sent
  * @dnode: address of destination node
@@ -791,7 +791,7 @@ int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf)
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_link_xmit2(struct sk_buff *buf, u32 dnode, u32 selector)
+int tipc_link_xmit(struct sk_buff *buf, u32 dnode, u32 selector)
 {
 	struct tipc_link *link = NULL;
 	struct tipc_node *node;
@@ -802,7 +802,7 @@ int tipc_link_xmit2(struct sk_buff *buf, u32 dnode, u32 selector)
 		tipc_node_lock(node);
 		link = node->active_links[selector & 1];
 		if (link)
-			rc = __tipc_link_xmit2(link, buf);
+			rc = __tipc_link_xmit(link, buf);
 		tipc_node_unlock(node);
 	}
 
@@ -836,7 +836,7 @@ static void tipc_link_sync_xmit(struct tipc_link *link)
 	msg = buf_msg(buf);
 	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, link->addr);
 	msg_set_last_bcast(msg, link->owner->bclink.acked);
-	__tipc_link_xmit2(link, buf);
+	__tipc_link_xmit(link, buf);
 }
 
 /*
@@ -1683,7 +1683,7 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
 	}
 	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, msg, length);
-	__tipc_link_xmit2(tunnel, buf);
+	__tipc_link_xmit(tunnel, buf);
 }
 
 
@@ -1716,7 +1716,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 		if (buf) {
 			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
-			__tipc_link_xmit2(tunnel, buf);
+			__tipc_link_xmit(tunnel, buf);
 		} else {
 			pr_warn("%sunable to send changeover msg\n",
 				link_co_err);
@@ -1789,7 +1789,7 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
 		skb_copy_to_linear_data_offset(outbuf, INT_H_SIZE, iter->data,
 					       length);
-		__tipc_link_xmit2(tunnel, outbuf);
+		__tipc_link_xmit(tunnel, outbuf);
 		if (!tipc_link_is_up(l_ptr))
 			return;
 		iter = iter->next;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index f0ebeb6..782983c 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -226,8 +226,8 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
-int tipc_link_xmit2(struct sk_buff *buf, u32 dest, u32 selector);
-int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf);
+int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
+int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 04e5cad..21b803a 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -115,7 +115,7 @@ out_free:
 
 
 /**
- * tipc_msg_build2 - create buffer chain containing specified header and data
+ * tipc_msg_build - create buffer chain containing specified header and data
  * @mhdr: Message header, to be prepended to data
  * @iov: User data
  * @offset: Posision in iov to start copying from
@@ -124,8 +124,8 @@ out_free:
  * @chain: Buffer or chain of buffers to be returned to caller
  * Returns message data size or errno: -ENOMEM, -EFAULT
  */
-int tipc_msg_build2(struct tipc_msg *mhdr, struct iovec const *iov,
-		    int offset, int dsz, int pktmax , struct sk_buff **chain)
+int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
+		   int offset, int dsz, int pktmax , struct sk_buff **chain)
 {
 	int mhsz = msg_hdr_sz(mhdr);
 	int msz = mhsz + dsz;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 868fe22..462fa19 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -738,8 +738,8 @@ bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
 
 bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
 
-int tipc_msg_build2(struct tipc_msg *mhdr, struct iovec const *iov,
-		    int offset, int dsz, int mtu , struct sk_buff **chain);
+int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
+		   int offset, int dsz, int mtu , struct sk_buff **chain);
 
 struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain);
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index d16f947..dcc15bc 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -116,7 +116,7 @@ void named_cluster_distribute(struct sk_buff *buf)
 		if (!obuf)
 			break;
 		msg_set_destnode(buf_msg(obuf), dnode);
-		tipc_link_xmit2(obuf, dnode, dnode);
+		tipc_link_xmit(obuf, dnode, dnode);
 	}
 	rcu_read_unlock();
 
@@ -232,7 +232,7 @@ void tipc_named_node_up(u32 dnode)
 	/* Convert circular list to linear list and send: */
 	buf_chain = (struct sk_buff *)msg_list.next;
 	((struct sk_buff *)msg_list.prev)->next = NULL;
-	tipc_link_xmit2(buf_chain, dnode, dnode);
+	tipc_link_xmit(buf_chain, dnode, dnode);
 }
 
 /**
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 835dca1..7e096a5 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -130,7 +130,7 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 		tipc_nodesub_unsubscribe(&p_ptr->subscription);
 		msg = buf_msg(buf);
 		peer = msg_destnode(msg);
-		tipc_link_xmit2(buf, peer, msg_link_selector(msg));
+		tipc_link_xmit(buf, peer, msg_link_selector(msg));
 	}
 	spin_lock_bh(&tipc_port_list_lock);
 	list_del(&p_ptr->port_list);
@@ -187,7 +187,7 @@ static void port_timeout(unsigned long ref)
 	}
 	tipc_port_unlock(p_ptr);
 	msg = buf_msg(buf);
-	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
+	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 
@@ -202,7 +202,7 @@ static void port_handle_node_down(unsigned long ref)
 	buf = port_build_self_abort_msg(p_ptr, TIPC_ERR_NO_NODE);
 	tipc_port_unlock(p_ptr);
 	msg = buf_msg(buf);
-	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
+	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 
@@ -347,7 +347,7 @@ void tipc_acknowledge(u32 ref, u32 ack)
 	if (!buf)
 		return;
 	msg = buf_msg(buf);
-	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
+	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
@@ -509,6 +509,6 @@ int tipc_port_shutdown(u32 ref)
 	buf = port_build_peer_abort_msg(p_ptr, TIPC_CONN_SHUTDOWN);
 	tipc_port_unlock(p_ptr);
 	msg = buf_msg(buf);
-	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
+	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 	return tipc_port_disconnect(ref);
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ae3d716..495bcf4 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -131,7 +131,7 @@ static void reject_rx_queue(struct sock *sk)
 
 	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
 		if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
-			tipc_link_xmit2(buf, dnode, 0);
+			tipc_link_xmit(buf, dnode, 0);
 	}
 }
 
@@ -341,7 +341,7 @@ static int tipc_release(struct socket *sock)
 				tipc_port_disconnect(port->ref);
 			}
 			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
-				tipc_link_xmit2(buf, dnode, 0);
+				tipc_link_xmit(buf, dnode, 0);
 		}
 	}
 
@@ -566,7 +566,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	rc = tipc_msg_build2(mhdr, iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -821,12 +821,12 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 new_mtu:
 	mtu = tipc_node_get_mtu(dnode, tsk->port.ref);
-	rc = tipc_msg_build2(mhdr, iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
 	if (rc < 0)
 		goto exit;
 
 	do {
-		rc = tipc_link_xmit2(buf, dnode, tsk->port.ref);
+		rc = tipc_link_xmit(buf, dnode, tsk->port.ref);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
@@ -934,12 +934,12 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 next:
 	mtu = port->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
-	rc = tipc_msg_build2(mhdr, m->msg_iov, sent, send, mtu, &buf);
+	rc = tipc_msg_build(mhdr, m->msg_iov, sent, send, mtu, &buf);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
 		if (likely(!tipc_sk_conn_cong(tsk))) {
-			rc = tipc_link_xmit2(buf, dnode, ref);
+			rc = tipc_link_xmit(buf, dnode, ref);
 			if (likely(!rc)) {
 				tsk->sent_unacked++;
 				sent += send;
@@ -1571,7 +1571,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 	if ((rc < 0) && !tipc_msg_reverse(buf, &onode, -rc))
 		return 0;
 
-	tipc_link_xmit2(buf, onode, 0);
+	tipc_link_xmit(buf, onode, 0);
 
 	return 0;
 }
@@ -1623,7 +1623,7 @@ exit:
 	if ((rc < 0) && !tipc_msg_reverse(buf, &dnode, -rc))
 		return -EHOSTUNREACH;
 
-	tipc_link_xmit2(buf, dnode, 0);
+	tipc_link_xmit(buf, dnode, 0);
 	return (rc < 0) ? -EHOSTUNREACH : 0;
 }
 
@@ -1910,7 +1910,7 @@ restart:
 			}
 			tipc_port_disconnect(port->ref);
 			if (tipc_msg_reverse(buf, &peer, TIPC_CONN_SHUTDOWN))
-				tipc_link_xmit2(buf, peer, 0);
+				tipc_link_xmit(buf, peer, 0);
 		} else {
 			tipc_port_shutdown(port->ref);
 		}
-- 
1.7.9.5
