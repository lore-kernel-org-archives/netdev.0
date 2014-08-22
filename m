From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 15/17] tipc: remove include file
	port.h
Date: Fri, 22 Aug 2014 18:09:18 -0400
Message-ID: <1408745360-23560-16-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We move the inline functions in the file port.h to socket.c, and modify
their names accordingly.

We move struct tipc_port and some macros to socket.h.

Finally, we remove the file port.h.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c      |    1 -
 net/tipc/core.c       |    2 +-
 net/tipc/link.c       |    1 -
 net/tipc/name_table.c |    1 -
 net/tipc/net.c        |    1 -
 net/tipc/port.h       |  145 -------------------------------------------------
 net/tipc/socket.c     |  123 +++++++++++++++++++++++++++--------------
 net/tipc/socket.h     |   39 ++++++++++++-
 net/tipc/subscr.c     |    1 -
 9 files changed, 121 insertions(+), 193 deletions(-)
 delete mode 100644 net/tipc/port.h

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 9510fb2..b2bbe69 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -37,7 +37,6 @@
 
 #include "core.h"
 #include "link.h"
-#include "port.h"
 #include "socket.h"
 #include "msg.h"
 #include "bcast.h"
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 676d180..b3b03ef 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -39,7 +39,7 @@
 #include "name_table.h"
 #include "subscr.h"
 #include "config.h"
-#include "port.h"
+#include "socket.h"
 
 #include <linux/module.h>
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6c775a1..65410e1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -36,7 +36,6 @@
 
 #include "core.h"
 #include "link.h"
-#include "port.h"
 #include "socket.h"
 #include "name_distr.h"
 #include "discover.h"
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 9d7d37d..c058e30 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -39,7 +39,6 @@
 #include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
-#include "port.h"
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 421dd89..93b9944 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -38,7 +38,6 @@
 #include "net.h"
 #include "name_distr.h"
 #include "subscr.h"
-#include "port.h"
 #include "socket.h"
 #include "node.h"
 #include "config.h"
diff --git a/net/tipc/port.h b/net/tipc/port.h
deleted file mode 100644
index 38bf8cb..0000000
--- a/net/tipc/port.h
+++ /dev/null
@@ -1,145 +0,0 @@
-/*
- * net/tipc/port.h: Include file for TIPC port code
- *
- * Copyright (c) 1994-2007, 2014, Ericsson AB
- * Copyright (c) 2004-2007, 2010-2013, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _TIPC_PORT_H
-#define _TIPC_PORT_H
-
-#include "net.h"
-#include "msg.h"
-#include "node_subscr.h"
-
-#define TIPC_CONNACK_INTV         256
-#define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
-#define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
-				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
-
-/**
- * struct tipc_port - TIPC port structure
- * @lock: pointer to spinlock for controlling access to port
- * @connected: non-zero if port is currently connected to a peer port
- * @conn_type: TIPC type used when connection was established
- * @conn_instance: TIPC instance used when connection was established
- * @published: non-zero if port has one or more associated names
- * @max_pkt: maximum packet size "hint" used when building messages sent by port
- * @ref: unique reference to port in TIPC object registry
- * @phdr: preformatted message header used when sending messages
- * @port_list: adjacent ports in TIPC's global list of ports
- * @publications: list of publications for port
- * @pub_count: total # of publications port has made during its lifetime
- * @probing_state:
- * @probing_interval:
- * @timer_ref:
- */
-struct tipc_port {
-	int connected;
-	u32 conn_type;
-	u32 conn_instance;
-	int published;
-	u32 max_pkt;
-	u32 ref;
-	struct tipc_msg phdr;
-	struct list_head publications;
-	u32 pub_count;
-	u32 probing_state;
-	u32 probing_interval;
-	struct timer_list timer;
-};
-
-/*
- * TIPC port manipulation routines
- */
-u32 tipc_port_init(struct tipc_port *p_ptr,
-		   const unsigned int importance);
-
-void tipc_port_destroy(struct tipc_port *p_ptr);
-
-int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
-		 struct tipc_name_seq const *name_seq);
-
-int tipc_withdraw(struct tipc_port *p_ptr, unsigned int scope,
-		  struct tipc_name_seq const *name_seq);
-
-int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
-
-void tipc_port_reinit(void);
-
-static inline u32 tipc_port_peernode(struct tipc_port *p_ptr)
-{
-	return msg_destnode(&p_ptr->phdr);
-}
-
-static inline u32 tipc_port_peerport(struct tipc_port *p_ptr)
-{
-	return msg_destport(&p_ptr->phdr);
-}
-
-static inline  bool tipc_port_unreliable(struct tipc_port *port)
-{
-	return msg_src_droppable(&port->phdr) != 0;
-}
-
-static inline void tipc_port_set_unreliable(struct tipc_port *port,
-					    bool unreliable)
-{
-	msg_set_src_droppable(&port->phdr, unreliable ? 1 : 0);
-}
-
-static inline bool tipc_port_unreturnable(struct tipc_port *port)
-{
-	return msg_dest_droppable(&port->phdr) != 0;
-}
-
-static inline void tipc_port_set_unreturnable(struct tipc_port *port,
-					     bool unreturnable)
-{
-	msg_set_dest_droppable(&port->phdr, unreturnable ? 1 : 0);
-}
-
-
-static inline int tipc_port_importance(struct tipc_port *port)
-{
-	return msg_importance(&port->phdr);
-}
-
-static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
-{
-	if (imp > TIPC_CRITICAL_IMPORTANCE)
-		return -EINVAL;
-	msg_set_importance(&port->phdr, (u32)imp);
-	return 0;
-}
-
-#endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ea33eab..70eacea 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -36,12 +36,12 @@
 
 #include "core.h"
 #include "ref.h"
-#include "port.h"
 #include "name_table.h"
 #include "node.h"
 #include "link.h"
 #include <linux/export.h>
 #include "config.h"
+#include "socket.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
@@ -114,24 +114,65 @@ static struct proto tipc_proto_kern;
  *   - port reference
  */
 
-#include "socket.h"
+static u32 tsk_peer_node(struct tipc_port *p_ptr)
+{
+	return msg_destnode(&p_ptr->phdr);
+}
+
+static u32 tsk_peer_port(struct tipc_port *p_ptr)
+{
+	return msg_destport(&p_ptr->phdr);
+}
+
+static  bool tsk_unreliable(struct tipc_port *port)
+{
+	return msg_src_droppable(&port->phdr) != 0;
+}
+
+static void tsk_set_unreliable(struct tipc_port *port, bool unreliable)
+{
+	msg_set_src_droppable(&port->phdr, unreliable ? 1 : 0);
+}
+
+static bool tsk_unreturnable(struct tipc_port *port)
+{
+	return msg_dest_droppable(&port->phdr) != 0;
+}
+
+static void tsk_set_unreturnable(struct tipc_port *port, bool unreturnable)
+{
+	msg_set_dest_droppable(&port->phdr, unreturnable ? 1 : 0);
+}
+
+static int tsk_importance(struct tipc_port *port)
+{
+	return msg_importance(&port->phdr);
+}
+
+static int tsk_set_importance(struct tipc_port *port, int imp)
+{
+	if (imp > TIPC_CRITICAL_IMPORTANCE)
+		return -EINVAL;
+	msg_set_importance(&port->phdr, (u32)imp);
+	return 0;
+}
 
 /**
- * advance_rx_queue - discard first buffer in socket receive queue
+ * tsk_advance_rx_queue - discard first buffer in socket receive queue
  *
  * Caller must hold socket lock
  */
-static void advance_rx_queue(struct sock *sk)
+static void tsk_advance_rx_queue(struct sock *sk)
 {
 	kfree_skb(__skb_dequeue(&sk->sk_receive_queue));
 }
 
 /**
- * reject_rx_queue - reject all buffers in socket receive queue
+ * tsk_rej_rx_queue - reject all buffers in socket receive queue
  *
  * Caller must hold socket lock
  */
-static void reject_rx_queue(struct sock *sk)
+static void tsk_rej_rx_queue(struct sock *sk)
 {
 	struct sk_buff *buf;
 	u32 dnode;
@@ -142,14 +183,14 @@ static void reject_rx_queue(struct sock *sk)
 	}
 }
 
-/* tipc_sk_peer_msg - verify if message was sent by connected port's peer
+/* tsk_peer_msg - verify if message was sent by connected port's peer
  *
  * Handles cases where the node's network address has changed from
  * the default of <0.0.0> to its configured setting.
  */
-static bool tipc_sk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
+static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 {
-	u32 peer_port = tipc_port_peerport(&tsk->port);
+	u32 peer_port = tsk_peer_port(&tsk->port);
 	u32 orig_node;
 	u32 peer_node;
 
@@ -160,7 +201,7 @@ static bool tipc_sk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 		return false;
 
 	orig_node = msg_orignode(msg);
-	peer_node = tipc_port_peernode(&tsk->port);
+	peer_node = tsk_peer_node(&tsk->port);
 
 	if (likely(orig_node == peer_node))
 		return true;
@@ -258,9 +299,9 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	atomic_set(&tsk->dupl_rcvcnt, 0);
 
 	if (sock->state == SS_READY) {
-		tipc_port_set_unreturnable(port, true);
+		tsk_set_unreturnable(port, true);
 		if (sock->type == SOCK_DGRAM)
-			tipc_port_set_unreliable(port, true);
+			tsk_set_unreliable(port, true);
 	}
 	return 0;
 }
@@ -373,7 +414,7 @@ static int tipc_release(struct socket *sock)
 	 * Reject all unreceived messages, except on an active connection
 	 * (which disconnects locally & sends a 'FIN+' to peer)
 	 */
-	dnode = tipc_port_peernode(port);
+	dnode = tsk_peer_node(port);
 	while (sock->state != SS_DISCONNECTING) {
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf == NULL)
@@ -398,7 +439,7 @@ static int tipc_release(struct socket *sock)
 	if (port->connected) {
 		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, dnode, tipc_own_addr,
-				      tipc_port_peerport(port),
+				      tsk_peer_port(port),
 				      port->ref, TIPC_ERR_NO_PORT);
 		if (buf)
 			tipc_link_xmit(buf, dnode, port->ref);
@@ -502,8 +543,8 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 		if ((sock->state != SS_CONNECTED) &&
 			((peer != 2) || (sock->state != SS_DISCONNECTING)))
 			return -ENOTCONN;
-		addr->addr.id.ref = tipc_port_peerport(&tsk->port);
-		addr->addr.id.node = tipc_port_peernode(&tsk->port);
+		addr->addr.id.ref = tsk_peer_port(&tsk->port);
+		addr->addr.id.node = tsk_peer_node(&tsk->port);
 	} else {
 		addr->addr.id.ref = tsk->port.ref;
 		addr->addr.id.node = tipc_own_addr;
@@ -699,7 +740,7 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 	int conn_cong;
 
 	/* Ignore if connection cannot be validated: */
-	if (!tipc_sk_peer_msg(tsk, msg))
+	if (!tsk_peer_msg(tsk, msg))
 		goto exit;
 
 	port->probing_state = TIPC_CONN_OK;
@@ -986,7 +1027,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	}
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
-	dnode = tipc_port_peernode(port);
+	dnode = tsk_peer_node(port);
 
 next:
 	mtu = port->max_pkt;
@@ -1161,8 +1202,8 @@ static void tipc_sk_send_ack(struct tipc_port *port, uint ack)
 {
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg;
-	u32 peer_port = tipc_port_peerport(port);
-	u32 dnode = tipc_port_peernode(port);
+	u32 peer_port = tsk_peer_port(port);
+	u32 dnode = tsk_peer_node(port);
 
 	if (!port->connected)
 		return;
@@ -1260,7 +1301,7 @@ restart:
 
 	/* Discard an empty non-errored message & try again */
 	if ((!sz) && (!err)) {
-		advance_rx_queue(sk);
+		tsk_advance_rx_queue(sk);
 		goto restart;
 	}
 
@@ -1298,7 +1339,7 @@ restart:
 			tipc_sk_send_ack(port, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
-		advance_rx_queue(sk);
+		tsk_advance_rx_queue(sk);
 	}
 exit:
 	release_sock(sk);
@@ -1360,7 +1401,7 @@ restart:
 
 	/* Discard an empty non-errored message & try again */
 	if ((!sz) && (!err)) {
-		advance_rx_queue(sk);
+		tsk_advance_rx_queue(sk);
 		goto restart;
 	}
 
@@ -1409,7 +1450,7 @@ restart:
 			tipc_sk_send_ack(port, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
-		advance_rx_queue(sk);
+		tsk_advance_rx_queue(sk);
 	}
 
 	/* Loop around if more data is required */
@@ -1480,12 +1521,12 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 	switch ((int)sock->state) {
 	case SS_CONNECTED:
 		/* Accept only connection-based messages sent by peer */
-		if (tipc_sk_peer_msg(tsk, msg)) {
+		if (tsk_peer_msg(tsk, msg)) {
 			if (unlikely(msg_errcode(msg))) {
 				sock->state = SS_DISCONNECTING;
 				port->connected = 0;
 				/* let timer expire on it's own */
-				tipc_node_remove_conn(tipc_port_peernode(port),
+				tipc_node_remove_conn(tsk_peer_node(port),
 						      port->ref);
 			}
 			retval = TIPC_OK;
@@ -1919,13 +1960,13 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	 * Reject any stray messages received by new socket
 	 * before the socket lock was taken (very, very unlikely)
 	 */
-	reject_rx_queue(new_sk);
+	tsk_rej_rx_queue(new_sk);
 
 	/* Connect new socket to it's peer */
 	tipc_sk_finish_conn(new_port, msg_origport(msg), msg_orignode(msg));
 	new_sock->state = SS_CONNECTED;
 
-	tipc_port_set_importance(new_port, msg_importance(msg));
+	tsk_set_importance(new_port, msg_importance(msg));
 	if (msg_named(msg)) {
 		new_port->conn_type = msg_nametype(msg);
 		new_port->conn_instance = msg_nameinst(msg);
@@ -1938,7 +1979,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	if (!msg_data_sz(msg)) {
 		struct msghdr m = {NULL,};
 
-		advance_rx_queue(sk);
+		tsk_advance_rx_queue(sk);
 		tipc_send_packet(NULL, new_sock, &m, 0);
 	} else {
 		__skb_dequeue(&sk->sk_receive_queue);
@@ -1990,11 +2031,11 @@ restart:
 				tipc_link_xmit(buf, dnode, port->ref);
 			tipc_node_remove_conn(dnode, port->ref);
 		} else {
-			dnode = tipc_port_peernode(port);
+			dnode = tsk_peer_node(port);
 			buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 					      TIPC_CONN_MSG, SHORT_H_SIZE,
 					      0, dnode, tipc_own_addr,
-					      tipc_port_peerport(port),
+					      tsk_peer_port(port),
 					      port->ref, TIPC_CONN_SHUTDOWN);
 			tipc_link_xmit(buf, dnode, port->ref);
 		}
@@ -2040,8 +2081,8 @@ static void tipc_sk_timeout(unsigned long ref)
 		bh_unlock_sock(sk);
 		goto exit;
 	}
-	peer_port = tipc_port_peerport(port);
-	peer_node = tipc_port_peernode(port);
+	peer_port = tsk_peer_port(port);
+	peer_node = tsk_peer_node(port);
 
 	if (port->probing_state == TIPC_CONN_PROBING) {
 		/* Previous probe not answered -> self abort */
@@ -2132,8 +2173,8 @@ static int tipc_sk_show(struct tipc_port *port, char *buf,
 		ret = tipc_snprintf(buf, len, "%-10u:", port->ref);
 
 	if (port->connected) {
-		u32 dport = tipc_port_peerport(port);
-		u32 destnode = tipc_port_peernode(port);
+		u32 dport = tsk_peer_port(port);
+		u32 destnode = tsk_peer_node(port);
 
 		ret += tipc_snprintf(buf + ret, len - ret,
 				     " connected to <%u.%u.%u:%u>",
@@ -2248,16 +2289,16 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		res = tipc_port_set_importance(port, value);
+		res = tsk_set_importance(port, value);
 		break;
 	case TIPC_SRC_DROPPABLE:
 		if (sock->type != SOCK_STREAM)
-			tipc_port_set_unreliable(port, value);
+			tsk_set_unreliable(port, value);
 		else
 			res = -ENOPROTOOPT;
 		break;
 	case TIPC_DEST_DROPPABLE:
-		tipc_port_set_unreturnable(port, value);
+		tsk_set_unreturnable(port, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
 		tipc_sk(sk)->conn_timeout = value;
@@ -2307,13 +2348,13 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		value = tipc_port_importance(port);
+		value = tsk_importance(port);
 		break;
 	case TIPC_SRC_DROPPABLE:
-		value = tipc_port_unreliable(port);
+		value = tsk_unreliable(port);
 		break;
 	case TIPC_DEST_DROPPABLE:
-		value = tipc_port_unreturnable(port);
+		value = tsk_unreturnable(port);
 		break;
 	case TIPC_CONN_TIMEOUT:
 		value = tipc_sk(sk)->conn_timeout;
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 5d515be..b98725e 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -35,11 +35,48 @@
 #ifndef _TIPC_SOCK_H
 #define _TIPC_SOCK_H
 
-#include "port.h"
 #include <net/sock.h>
+#include "msg.h"
 
 #define TIPC_CONN_OK      0
 #define TIPC_CONN_PROBING 1
+#define TIPC_CONNACK_INTV         256
+#define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
+#define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
+				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
+
+/**
+ * struct tipc_port - TIPC port structure
+ * @lock: pointer to spinlock for controlling access to port
+ * @connected: non-zero if port is currently connected to a peer port
+ * @conn_type: TIPC type used when connection was established
+ * @conn_instance: TIPC instance used when connection was established
+ * @published: non-zero if port has one or more associated names
+ * @max_pkt: maximum packet size "hint" used when building messages sent by port
+ * @ref: unique reference to port in TIPC object registry
+ * @phdr: preformatted message header used when sending messages
+ * @port_list: adjacent ports in TIPC's global list of ports
+ * @publications: list of publications for port
+ * @pub_count: total # of publications port has made during its lifetime
+ * @probing_state:
+ * @probing_interval:
+ * @timer_ref:
+ */
+struct tipc_port {
+	int connected;
+	u32 conn_type;
+	u32 conn_instance;
+	int published;
+	u32 max_pkt;
+	u32 ref;
+	struct tipc_msg phdr;
+	struct list_head port_list;
+	struct list_head publications;
+	u32 pub_count;
+	u32 probing_state;
+	u32 probing_interval;
+	struct timer_list timer;
+};
 
 /**
  * struct tipc_sock - TIPC socket structure
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 6424372..31b5cb2 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -36,7 +36,6 @@
 
 #include "core.h"
 #include "name_table.h"
-#include "port.h"
 #include "subscr.h"
 
 /**
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
