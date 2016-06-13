From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] rxrpc: Update the comments in ar-internal.h to
 reflect renames
Date: Mon, 13 Jun 2016 15:08:04 +0100
Message-ID: <146582688456.9344.1950880382456875058.stgit@warthog.procyon.org.uk>
References: <146582687035.9344.8429200604453755089.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423255AbcFMOIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 10:08:07 -0400
In-Reply-To: <146582687035.9344.8429200604453755089.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the section comments in ar-internal.h that indicate the locations of
the referenced items to reflect the renames done to the .c files in
net/rxrpc/.

This also involves some rearrangement to reflect keep the sections in order
of filename.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |  138 ++++++++++++++++++++++++-----------------------
 1 file changed, 69 insertions(+), 69 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f715cca767cd..03919b9a8a31 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -482,21 +482,21 @@ extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *,
 						       int, int, gfp_t);
 
 /*
- * ar-accept.c
+ * call_accept.c
  */
 void rxrpc_accept_incoming_calls(struct work_struct *);
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
 int rxrpc_reject_call(struct rxrpc_sock *);
 
 /*
- * ar-ack.c
+ * call_event.c
  */
 void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_process_call(struct work_struct *);
 
 /*
- * ar-call.c
+ * call_object.c
  */
 extern unsigned int rxrpc_max_call_lifetime;
 extern unsigned int rxrpc_dead_call_expiry;
@@ -520,7 +520,14 @@ void __rxrpc_put_call(struct rxrpc_call *);
 void __exit rxrpc_destroy_all_calls(void);
 
 /*
- * ar-connection.c
+ * conn_event.c
+ */
+void rxrpc_process_connection(struct work_struct *);
+void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
+void rxrpc_reject_packets(struct work_struct *);
+
+/*
+ * conn_object.c
  */
 extern unsigned int rxrpc_connection_expiry;
 extern struct list_head rxrpc_connections;
@@ -540,27 +547,30 @@ extern struct rxrpc_connection *
 rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *);
 
 /*
- * ar-connevent.c
+ * input.c
  */
-void rxrpc_process_connection(struct work_struct *);
-void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
-void rxrpc_reject_packets(struct work_struct *);
+void rxrpc_data_ready(struct sock *);
+int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
+void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
 
 /*
- * ar-error.c
+ * insecure.c
  */
-void rxrpc_UDP_error_report(struct sock *);
-void rxrpc_UDP_error_handler(struct work_struct *);
+extern const struct rxrpc_security rxrpc_no_security;
 
 /*
- * ar-input.c
+ * key.c
  */
-void rxrpc_data_ready(struct sock *);
-int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
-void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
+extern struct key_type key_type_rxrpc;
+extern struct key_type key_type_rxrpc_s;
+
+int rxrpc_request_key(struct rxrpc_sock *, char __user *, int);
+int rxrpc_server_keyring(struct rxrpc_sock *, char __user *, int);
+int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
+			      u32);
 
 /*
- * ar-local.c
+ * local_object.c
  */
 extern rwlock_t rxrpc_local_lock;
 
@@ -569,18 +579,23 @@ void rxrpc_put_local(struct rxrpc_local *);
 void __exit rxrpc_destroy_all_locals(void);
 
 /*
- * ar-key.c
+ * misc.c
  */
-extern struct key_type key_type_rxrpc;
-extern struct key_type key_type_rxrpc_s;
+extern unsigned int rxrpc_max_backlog __read_mostly;
+extern unsigned int rxrpc_requested_ack_delay;
+extern unsigned int rxrpc_soft_ack_delay;
+extern unsigned int rxrpc_idle_ack_delay;
+extern unsigned int rxrpc_rx_window_size;
+extern unsigned int rxrpc_rx_mtu;
+extern unsigned int rxrpc_rx_jumbo_max;
 
-int rxrpc_request_key(struct rxrpc_sock *, char __user *, int);
-int rxrpc_server_keyring(struct rxrpc_sock *, char __user *, int);
-int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
-			      u32);
+extern const char *const rxrpc_pkts[];
+extern const s8 rxrpc_ack_priority[];
+
+extern const char *rxrpc_acks(u8 reason);
 
 /*
- * ar-output.c
+ * output.c
  */
 extern unsigned int rxrpc_resend_timeout;
 
@@ -588,7 +603,13 @@ int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
 int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
- * ar-peer.c
+ * peer_error.c
+ */
+void rxrpc_UDP_error_report(struct sock *);
+void rxrpc_UDP_error_handler(struct work_struct *);
+
+/*
+ * peer_object.c
  */
 struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
 void rxrpc_put_peer(struct rxrpc_peer *);
@@ -596,20 +617,27 @@ struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *, __be32, __be16);
 void __exit rxrpc_destroy_all_peers(void);
 
 /*
- * ar-proc.c
+ * proc.c
  */
 extern const char *const rxrpc_call_states[];
 extern const struct file_operations rxrpc_call_seq_fops;
 extern const struct file_operations rxrpc_connection_seq_fops;
 
 /*
- * ar-recvmsg.c
+ * recvmsg.c
  */
 void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
 int rxrpc_recvmsg(struct socket *, struct msghdr *, size_t, int);
 
 /*
- * ar-security.c
+ * rxkad.c
+ */
+#ifdef CONFIG_RXKAD
+extern const struct rxrpc_security rxkad;
+#endif
+
+/*
+ * security.c
  */
 int __init rxrpc_init_security(void);
 void rxrpc_exit_security(void);
@@ -617,51 +645,11 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *);
 int rxrpc_init_server_conn_security(struct rxrpc_connection *);
 
 /*
- * ar-skbuff.c
+ * skbuff.c
  */
 void rxrpc_packet_destructor(struct sk_buff *);
 
 /*
- * ar-transport.c
- */
-extern unsigned int rxrpc_transport_expiry;
-
-struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
-					    struct rxrpc_peer *, gfp_t);
-void rxrpc_put_transport(struct rxrpc_transport *);
-void __exit rxrpc_destroy_all_transports(void);
-struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
-					     struct rxrpc_peer *);
-
-/*
- * insecure.c
- */
-extern const struct rxrpc_security rxrpc_no_security;
-
-/*
- * misc.c
- */
-extern unsigned int rxrpc_max_backlog __read_mostly;
-extern unsigned int rxrpc_requested_ack_delay;
-extern unsigned int rxrpc_soft_ack_delay;
-extern unsigned int rxrpc_idle_ack_delay;
-extern unsigned int rxrpc_rx_window_size;
-extern unsigned int rxrpc_rx_mtu;
-extern unsigned int rxrpc_rx_jumbo_max;
-
-extern const char *const rxrpc_pkts[];
-extern const s8 rxrpc_ack_priority[];
-
-extern const char *rxrpc_acks(u8 reason);
-
-/*
- * rxkad.c
- */
-#ifdef CONFIG_RXKAD
-extern const struct rxrpc_security rxkad;
-#endif
-
-/*
  * sysctl.c
  */
 #ifdef CONFIG_SYSCTL
@@ -673,6 +661,18 @@ static inline void rxrpc_sysctl_exit(void) {}
 #endif
 
 /*
+ * transport.c
+ */
+extern unsigned int rxrpc_transport_expiry;
+
+struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
+					    struct rxrpc_peer *, gfp_t);
+void rxrpc_put_transport(struct rxrpc_transport *);
+void __exit rxrpc_destroy_all_transports(void);
+struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
+					     struct rxrpc_peer *);
+
+/*
  * debug tracing
  */
 extern unsigned int rxrpc_debug;
