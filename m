From: David Howells <dhowells@redhat.com>
Subject: [PATCH] RxRPC: Use uX/sX rather than uintX_t/intX_t types
Date: Tue, 15 Sep 2009 11:16:31 +0100
Message-ID: <20090915101631.1051.70606.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbZIOKQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 06:16:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use uX rather than uintX_t types for consistency.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/keys/rxrpc-type.h |   20 ++++++++++----------
 net/rxrpc/ar-ack.c        |    6 +++---
 net/rxrpc/ar-internal.h   |   16 ++++++++--------
 net/rxrpc/ar-key.c        |    2 +-
 4 files changed, 22 insertions(+), 22 deletions(-)


diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
index 5eb2357..5cb86c3 100644
--- a/include/keys/rxrpc-type.h
+++ b/include/keys/rxrpc-type.h
@@ -53,8 +53,8 @@ struct krb5_tagged_data {
 	 * - KRB5_AUTHDATA_* for auth data
 	 * - 
 	 */
-	int32_t		tag;
-	uint32_t	data_len;
+	s32		tag;
+	u32		data_len;
 	u8		*data;
 };
 
@@ -62,17 +62,17 @@ struct krb5_tagged_data {
  * RxRPC key for Kerberos V (type-5 security)
  */
 struct rxk5_key {
-	uint64_t		authtime;	/* time at which auth token generated */
-	uint64_t		starttime;	/* time at which auth token starts */
-	uint64_t		endtime;	/* time at which auth token expired */
-	uint64_t		renew_till;	/* time to which auth token can be renewed */
-	int32_t			is_skey;	/* T if ticket is encrypted in another ticket's
+	u64			authtime;	/* time at which auth token generated */
+	u64			starttime;	/* time at which auth token starts */
+	u64			endtime;	/* time at which auth token expired */
+	u64			renew_till;	/* time to which auth token can be renewed */
+	s32			is_skey;	/* T if ticket is encrypted in another ticket's
 						 * skey */
-	int32_t			flags;		/* mask of TKT_FLG_* bits (krb5/krb5.h) */
+	s32			flags;		/* mask of TKT_FLG_* bits (krb5/krb5.h) */
 	struct krb5_principal	client;		/* client principal name */
 	struct krb5_principal	server;		/* server principal name */
-	uint16_t		ticket_len;	/* length of ticket */
-	uint16_t		ticket2_len;	/* length of second ticket */
+	u16			ticket_len;	/* length of ticket */
+	u16			ticket2_len;	/* length of second ticket */
 	u8			n_authdata;	/* number of authorisation data elements */
 	u8			n_addresses;	/* number of addresses */
 	struct krb5_tagged_data	session;	/* session data; tag is enctype */
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index c9f1f0a..b4a2209 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -40,7 +40,7 @@ static const s8 rxrpc_ack_priority[] = {
 /*
  * propose an ACK be sent
  */
-void __rxrpc_propose_ACK(struct rxrpc_call *call, uint8_t ack_reason,
+void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 			 __be32 serial, bool immediate)
 {
 	unsigned long expiry;
@@ -120,7 +120,7 @@ cancel_timer:
 /*
  * propose an ACK be sent, locking the call structure
  */
-void rxrpc_propose_ACK(struct rxrpc_call *call, uint8_t ack_reason,
+void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 		       __be32 serial, bool immediate)
 {
 	s8 prior = rxrpc_ack_priority[ack_reason];
@@ -520,7 +520,7 @@ static void rxrpc_zap_tx_window(struct rxrpc_call *call)
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	unsigned long _skb, *acks_window;
-	uint8_t winsz = call->acks_winsz;
+	u8 winsz = call->acks_winsz;
 	int tail;
 
 	acks_window = call->acks_window;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 46c6d88..7043b29 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -229,7 +229,7 @@ struct rxrpc_conn_bundle {
 	int			debug_id;	/* debug ID for printks */
 	unsigned short		num_conns;	/* number of connections in this bundle */
 	__be16			service_id;	/* service ID */
-	uint8_t			security_ix;	/* security type */
+	u8			security_ix;	/* security type */
 };
 
 /*
@@ -370,10 +370,10 @@ struct rxrpc_call {
 	u8			channel;	/* connection channel occupied by this call */
 
 	/* transmission-phase ACK management */
-	uint8_t			acks_head;	/* offset into window of first entry */
-	uint8_t			acks_tail;	/* offset into window of last entry */
-	uint8_t			acks_winsz;	/* size of un-ACK'd window */
-	uint8_t			acks_unacked;	/* lowest unacked packet in last ACK received */
+	u8			acks_head;	/* offset into window of first entry */
+	u8			acks_tail;	/* offset into window of last entry */
+	u8			acks_winsz;	/* size of un-ACK'd window */
+	u8			acks_unacked;	/* lowest unacked packet in last ACK received */
 	int			acks_latest;	/* serial number of latest ACK received */
 	rxrpc_seq_t		acks_hard;	/* highest definitively ACK'd msg seq */
 	unsigned long		*acks_window;	/* sent packet window
@@ -388,7 +388,7 @@ struct rxrpc_call {
 	rxrpc_seq_t		rx_first_oos;	/* first packet in rx_oos_queue (or 0) */
 	rxrpc_seq_t		ackr_win_top;	/* top of ACK window (rx_data_eaten is bottom) */
 	rxrpc_seq_net_t		ackr_prev_seq;	/* previous sequence number received */
-	uint8_t			ackr_reason;	/* reason to ACK */
+	u8			ackr_reason;	/* reason to ACK */
 	__be32			ackr_serial;	/* serial of packet being ACK'd */
 	atomic_t		ackr_not_idle;	/* number of packets in Rx queue */
 
@@ -434,8 +434,8 @@ extern int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * ar-ack.c
  */
-extern void __rxrpc_propose_ACK(struct rxrpc_call *, uint8_t, __be32, bool);
-extern void rxrpc_propose_ACK(struct rxrpc_call *, uint8_t, __be32, bool);
+extern void __rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
+extern void rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
 extern void rxrpc_process_call(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 44836f6..74697b2 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -360,7 +360,7 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
 /*
  * extract a krb5 ticket
  */
-static int rxrpc_krb5_decode_ticket(u8 **_ticket, uint16_t *_tktlen,
+static int rxrpc_krb5_decode_ticket(u8 **_ticket, u16 *_tktlen,
 				    const __be32 **_xdr, unsigned *_toklen)
 {
 	const __be32 *xdr = *_xdr;

