From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/20] tipc: remove extraneous braces from single statements
Date: Fri, 31 Dec 2010 23:59:35 -0500
Message-ID: <1293857975-30267-21-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53353 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab1AAFAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:17 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Cleans up TIPC's source code to eliminate the presence of unnecessary
use of {} around single statements.

These changes are purely cosmetic and do not alter the operation of TIPC
in any way.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |    6 ++----
 net/tipc/bearer.c     |    3 +--
 net/tipc/link.c       |   25 +++++++++----------------
 net/tipc/msg.c        |   15 ++++++---------
 net/tipc/name_table.c |    6 ++----
 net/tipc/port.c       |    6 ++----
 net/tipc/socket.c     |   14 +++++---------
 7 files changed, 27 insertions(+), 48 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 99a1469..70ab5ef 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -196,9 +196,8 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
 	struct sk_buff *buf;
 
 	buf = bcl->first_out;
-	while (buf && less_eq(buf_seqno(buf), after)) {
+	while (buf && less_eq(buf_seqno(buf), after))
 		buf = buf->next;
-	}
 	tipc_link_retransmit(bcl, buf, mod(to - after));
 }
 
@@ -224,9 +223,8 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	/* Skip over packets that node has previously acknowledged */
 
 	crs = bcl->first_out;
-	while (crs && less_eq(buf_seqno(crs), n_ptr->bclink.acked)) {
+	while (crs && less_eq(buf_seqno(crs), n_ptr->bclink.acked))
 		crs = crs->next;
-	}
 
 	/* Update packets that node is now acknowledging */
 
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 68e7290..837b7a4 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -194,9 +194,8 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 		unchar *addr = (unchar *)&a->dev_addr;
 
 		tipc_printf(pb, "UNKNOWN(%u)", media_type);
-		for (i = 0; i < (sizeof(*a) - sizeof(a->type)); i++) {
+		for (i = 0; i < (sizeof(*a) - sizeof(a->type)); i++)
 			tipc_printf(pb, "-%02x", addr[i]);
-		}
 	}
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index de9d491..18702f5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -615,9 +615,8 @@ static void link_state_event(struct link *l_ptr, unsigned event)
 		return;		/* Not yet. */
 
 	if (link_blocked(l_ptr)) {
-		if (event == TIMEOUT_EVT) {
+		if (event == TIMEOUT_EVT)
 			link_set_timer(l_ptr, cont_intv);
-		}
 		return;	  /* Changeover going on */
 	}
 
@@ -940,11 +939,10 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector & 1];
-		if (l_ptr) {
+		if (l_ptr)
 			res = tipc_link_send_buf(l_ptr, buf);
-		} else {
+		else
 			buf_discard(buf);
-		}
 		tipc_node_unlock(n_ptr);
 	} else {
 		buf_discard(buf);
@@ -1626,9 +1624,8 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 
 		/* Ensure message data is a single contiguous unit */
 
-		if (unlikely(buf_linearize(buf))) {
+		if (unlikely(buf_linearize(buf)))
 			goto cont;
-		}
 
 		/* Handle arrival of a non-unicast link message */
 
@@ -1843,9 +1840,8 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 				*head = buf;
 			return 1;
 		}
-		if (seq_no == msg_seqno(msg)) {
+		if (seq_no == msg_seqno(msg))
 			break;
-		}
 		prev = crs;
 		crs = crs->next;
 	} while (crs);
@@ -1959,11 +1955,10 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
 	}
 
-	if (tipc_node_has_redundant_links(l_ptr->owner)) {
+	if (tipc_node_has_redundant_links(l_ptr->owner))
 		msg_set_redundant_link(msg);
-	} else {
+	else
 		msg_clear_redundant_link(msg);
-	}
 	msg_set_linkprio(msg, l_ptr->priority);
 
 	/* Ensure sequence number will not fit : */
@@ -2071,9 +2066,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 		l_ptr->peer_bearer_id = msg_bearer_id(msg);
 
 		/* Synchronize broadcast sequence numbers */
-		if (!tipc_node_has_redundant_links(l_ptr->owner)) {
+		if (!tipc_node_has_redundant_links(l_ptr->owner))
 			l_ptr->owner->bclink.last_in = mod(msg_last_bcast(msg));
-		}
 		break;
 	case STATE_MSG:
 
@@ -2108,9 +2102,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 		max_pkt_ack = 0;
 		if (msg_probe(msg)) {
 			l_ptr->stats.recv_probes++;
-			if (msg_size(msg) > sizeof(l_ptr->proto_msg)) {
+			if (msg_size(msg) > sizeof(l_ptr->proto_msg))
 				max_pkt_ack = msg_size(msg);
-			}
 		}
 
 		/* Protocol message before retransmits, reduce loss risk */
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index e81d43a..bb6180c 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -348,7 +348,8 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "UNKNOWN ERROR(%x):",
 				    msg_errcode(msg));
 		}
-	default:{}
+	default:
+		break;
 	}
 
 	tipc_printf(buf, "HZ(%u):", msg_hdr_sz(msg));
@@ -357,9 +358,8 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 
 	if (msg_non_seq(msg))
 		tipc_printf(buf, "NOSEQ:");
-	else {
+	else
 		tipc_printf(buf, "ACK(%u):", msg_ack(msg));
-	}
 	tipc_printf(buf, "BACK(%u):", msg_bcast_ack(msg));
 	tipc_printf(buf, "PRND(%x)", msg_prevnode(msg));
 
@@ -387,9 +387,8 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 	if (msg_user(msg) == NAME_DISTRIBUTOR) {
 		tipc_printf(buf, ":ONOD(%x):", msg_orignode(msg));
 		tipc_printf(buf, ":DNOD(%x):", msg_destnode(msg));
-		if (msg_routed(msg)) {
+		if (msg_routed(msg))
 			tipc_printf(buf, ":CSEQN(%u)", msg_transp_seqno(msg));
-		}
 	}
 
 	if (msg_user(msg) ==  LINK_CONFIG) {
@@ -405,12 +404,10 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 		tipc_printf(buf, "TO(%u):", msg_bcgap_to(msg));
 	}
 	tipc_printf(buf, "\n");
-	if ((usr == CHANGEOVER_PROTOCOL) && (msg_msgcnt(msg))) {
+	if ((usr == CHANGEOVER_PROTOCOL) && (msg_msgcnt(msg)))
 		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
-	}
-	if ((usr == MSG_FRAGMENTER) && (msg_type(msg) == FIRST_FRAGMENT)) {
+	if ((usr == MSG_FRAGMENTER) && (msg_type(msg) == FIRST_FRAGMENT))
 		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
-	}
 }
 
 #endif
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ea3e94e..205ed4a 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -751,9 +751,8 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	table.local_publ_count++;
 	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
 				   tipc_own_addr, port_ref, key);
-	if (publ && (scope != TIPC_NODE_SCOPE)) {
+	if (publ && (scope != TIPC_NODE_SCOPE))
 		tipc_named_publish(publ);
-	}
 	write_unlock_bh(&tipc_nametbl_lock);
 	return publ;
 }
@@ -795,9 +794,8 @@ void tipc_nametbl_subscribe(struct subscription *s)
 
 	write_lock_bh(&tipc_nametbl_lock);
 	seq = nametbl_find_seq(type);
-	if (!seq) {
+	if (!seq)
 		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
-	}
 	if (seq) {
 		spin_lock_bh(&seq->lock);
 		tipc_nameseq_subscribe(seq, s);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index c23f338..067bab2 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -131,9 +131,8 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 			}
 		}
 		res = tipc_bclink_send_msg(buf);
-		if ((res < 0) && (dports.count != 0)) {
+		if ((res < 0) && (dports.count != 0))
 			buf_discard(ibuf);
-		}
 	} else {
 		ibuf = buf;
 	}
@@ -190,9 +189,8 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
 				warn("Unable to deliver multicast message(s)\n");
 				goto exit;
 			}
-			if ((index == 0) && (cnt != 0)) {
+			if ((index == 0) && (cnt != 0))
 				item = item->next;
-			}
 			msg_set_destport(buf_msg(b), item->ports[index]);
 			tipc_port_recv_msg(b);
 		}
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 18aad57..2b02a3a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -590,9 +590,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 					     m->msg_iov);
 		}
 		if (likely(res != -ELINKCONG)) {
-			if (needs_conn && (res >= 0)) {
+			if (needs_conn && (res >= 0))
 				sock->state = SS_CONNECTING;
-			}
 			break;
 		}
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -651,9 +650,8 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 		}
 
 		res = tipc_send(tport->ref, m->msg_iovlen, m->msg_iov);
-		if (likely(res != -ELINKCONG)) {
+		if (likely(res != -ELINKCONG))
 			break;
-		}
 		if (m->msg_flags & MSG_DONTWAIT) {
 			res = -EWOULDBLOCK;
 			break;
@@ -1418,9 +1416,8 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	m.msg_name = dest;
 	m.msg_namelen = destlen;
 	res = send_msg(NULL, sock, &m, 0);
-	if (res < 0) {
+	if (res < 0)
 		goto exit;
-	}
 
 	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 
@@ -1442,11 +1439,10 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 					advance_rx_queue(sk);
 			}
 		} else {
-			if (sock->state == SS_CONNECTED) {
+			if (sock->state == SS_CONNECTED)
 				res = -EISCONN;
-			} else {
+			else
 				res = -ECONNREFUSED;
-			}
 		}
 	} else {
 		if (res == 0)
-- 
1.7.3.3

