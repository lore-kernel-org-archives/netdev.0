From: Joshua Houghton <josh-JsTGS6celw1BDLzU/O5InQ@public.gmane.org>
Subject: [PATCH] net: rds: fix coding style issues
Date: Sat, 18 Jun 2016 15:46:31 +0000
Message-ID: <1550219.0fqfakIZNR@arch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix coding style issues in the following files:

ib_cm.c:      add space
loop.c:       convert spaces to tabs
sysctl.c:     add space
tcp.h:        convert spaces to tabs
tcp_connect.c:remove extra indentation in switch statement
tcp_recv.c:   convert spaces to tabs
tcp_send.c:   convert spaces to tabs
transport.c:  move brace up one line on for statement

Signed-off-by: Joshua Houghton <josh-JsTGS6celw1BDLzU/O5InQ@public.gmane.org>
---
 net/rds/ib_cm.c       |  2 +-
 net/rds/loop.c        |  5 +++--
 net/rds/sysctl.c      |  3 ++-
 net/rds/tcp.h         |  2 +-
 net/rds/tcp_connect.c | 26 +++++++++++++-------------
 net/rds/tcp_recv.c    |  2 +-
 net/rds/tcp_send.c    | 14 +++++++-------
 net/rds/transport.c   |  3 +--
 8 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 310cabc..7c2a65a 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -111,7 +111,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 		}
 	}
 
-	if (conn->c_version < RDS_PROTOCOL(3,1)) {
+	if (conn->c_version < RDS_PROTOCOL(3, 1)) {
 		printk(KERN_NOTICE "RDS/IB: Connection to %pI4 version %u.%u failed,"
 		       " no longer supported\n",
 		       &conn->c_faddr,
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 6b12b68..814173b 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -95,8 +95,9 @@ out:
  */
 static void rds_loop_inc_free(struct rds_incoming *inc)
 {
-        struct rds_message *rm = container_of(inc, struct rds_message, m_inc);
-        rds_message_put(rm);
+	struct rds_message *rm = container_of(inc, struct rds_message, m_inc);
+
+	rds_message_put(rm);
 }
 
 /* we need to at least give the thread something to succeed */
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index c173f69..e381bbc 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -102,7 +102,8 @@ int rds_sysctl_init(void)
 	rds_sysctl_reconnect_min = msecs_to_jiffies(1);
 	rds_sysctl_reconnect_min_jiffies = rds_sysctl_reconnect_min;
 
-	rds_sysctl_reg_table = register_net_sysctl(&init_net,"net/rds", rds_sysctl_rds_table);
+	rds_sysctl_reg_table =
+		register_net_sysctl(&init_net, "net/rds", rds_sysctl_rds_table);
 	if (!rds_sysctl_reg_table)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index ec0602b..7940bab 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -83,7 +83,7 @@ int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 void rds_tcp_xmit_prepare(struct rds_connection *conn);
 void rds_tcp_xmit_complete(struct rds_connection *conn);
 int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
-	         unsigned int hdr_off, unsigned int sg, unsigned int off);
+		 unsigned int hdr_off, unsigned int sg, unsigned int off);
 void rds_tcp_write_space(struct sock *sk);
 
 /* tcp_stats.c */
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index fba13d0..f6e95d6 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -54,19 +54,19 @@ void rds_tcp_state_change(struct sock *sk)
 
 	rdsdebug("sock %p state_change to %d\n", tc->t_sock, sk->sk_state);
 
-	switch(sk->sk_state) {
-		/* ignore connecting sockets as they make progress */
-		case TCP_SYN_SENT:
-		case TCP_SYN_RECV:
-			break;
-		case TCP_ESTABLISHED:
-			rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
-			break;
-		case TCP_CLOSE_WAIT:
-		case TCP_CLOSE:
-			rds_conn_drop(conn);
-		default:
-			break;
+	switch (sk->sk_state) {
+	/* ignore connecting sockets as they make progress */
+	case TCP_SYN_SENT:
+	case TCP_SYN_RECV:
+		break;
+	case TCP_ESTABLISHED:
+		rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
+		break;
+	case TCP_CLOSE_WAIT:
+	case TCP_CLOSE:
+		rds_conn_drop(conn);
+	default:
+		break;
 	}
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index c3196f9..6e6a711 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -171,7 +171,7 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 	while (left) {
 		if (!tinc) {
 			tinc = kmem_cache_alloc(rds_tcp_incoming_slab,
-					        arg->gfp);
+						arg->gfp);
 			if (!tinc) {
 				desc->error = -ENOMEM;
 				goto out;
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 22d0f20..618be69 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -66,19 +66,19 @@ void rds_tcp_xmit_complete(struct rds_connection *conn)
 static int rds_tcp_sendmsg(struct socket *sock, void *data, unsigned int len)
 {
 	struct kvec vec = {
-                .iov_base = data,
-                .iov_len = len,
+		.iov_base = data,
+		.iov_len = len,
+	};
+	struct msghdr msg = {
+		.msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL,
 	};
-        struct msghdr msg = {
-                .msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL,
-        };
 
 	return kernel_sendmsg(sock, &msg, &vec, 1, vec.iov_len);
 }
 
 /* the core send_sem serializes this with other xmit and shutdown */
 int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
-	         unsigned int hdr_off, unsigned int sg, unsigned int off)
+		 unsigned int hdr_off, unsigned int sg, unsigned int off)
 {
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 	int done = 0;
@@ -196,7 +196,7 @@ void rds_tcp_write_space(struct sock *sk)
 	tc->t_last_seen_una = rds_tcp_snd_una(tc);
 	rds_send_drop_acked(conn, rds_tcp_snd_una(tc), rds_tcp_is_acked);
 
-        if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
+	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
 		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 out:
diff --git a/net/rds/transport.c b/net/rds/transport.c
index f3afd1d..2ffd3e30 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -140,8 +140,7 @@ unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 	rds_info_iter_unmap(iter);
 	down_read(&rds_trans_sem);
 
-	for (i = 0; i < RDS_TRANS_COUNT; i++)
-	{
+	for (i = 0; i < RDS_TRANS_COUNT; i++) {
 		trans = transports[i];
 		if (!trans || !trans->stats_info_copy)
 			continue;
-- 
2.8.3


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
