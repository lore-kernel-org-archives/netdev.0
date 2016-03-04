From: David Howells <dhowells@redhat.com>
Subject: [PATCH 08/13] rxrpc: Adjust some whitespace and comments
Date: Fri, 04 Mar 2016 16:38:01 +0000
Message-ID: <20160304163801.31057.38114.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove some excess whitespace, insert some missing spaces and adjust a
couple of comments.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    9 +++------
 net/rxrpc/ar-accept.c   |    4 +---
 net/rxrpc/ar-error.c    |    1 -
 net/rxrpc/ar-internal.h |   22 +++++++++++-----------
 net/rxrpc/ar-security.c |    2 +-
 net/rxrpc/ar-skbuff.c   |    1 -
 net/rxrpc/rxkad.c       |   12 ++++++------
 7 files changed, 22 insertions(+), 29 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 5e810b83269f..b46f7742d336 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -121,7 +121,7 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
  */
 static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 {
-	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) saddr;
+	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *)saddr;
 	struct sock *sk = sock->sk;
 	struct rxrpc_local *local;
 	struct rxrpc_sock *rx = rxrpc_sk(sk), *prx;
@@ -142,7 +142,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	memcpy(&rx->srx, srx, sizeof(rx->srx));
 
-	/* find a local transport endpoint if we don't have one already */
+	/* Find or create a local transport endpoint to use */
 	local = rxrpc_lookup_local(&rx->srx);
 	if (IS_ERR(local)) {
 		ret = PTR_ERR(local);
@@ -297,7 +297,6 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 
 	if (!srx)
 		srx = &rx->srx;
-
 	if (!key)
 		key = rx->key;
 	if (key && !key->payload.data[0])
@@ -319,7 +318,6 @@ out_notrans:
 	_leave(" = %p", call);
 	return call;
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_begin_call);
 
 /**
@@ -335,7 +333,6 @@ void rxrpc_kernel_end_call(struct rxrpc_call *call)
 	rxrpc_remove_user_ID(call->socket, call);
 	rxrpc_put_call(call);
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
 /**
@@ -616,7 +613,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
-	/* we support transport protocol UDP only */
+	/* we support transport protocol UDP/UDP6 only */
 	if (protocol != PF_INET)
 		return -EPROTONOSUPPORT;
 
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 73c905416271..277731a5e67a 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -415,7 +415,7 @@ out:
 }
 
 /*
- * handle rejectance of a call by userspace
+ * Handle rejection of a call by userspace
  * - reject the call at the front of the queue
  */
 int rxrpc_reject_call(struct rxrpc_sock *rx)
@@ -495,7 +495,6 @@ struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *sock,
 	_leave(" = %p", call);
 	return call;
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_accept_call);
 
 /**
@@ -514,5 +513,4 @@ int rxrpc_kernel_reject_call(struct socket *sock)
 	_leave(" = %d", ret);
 	return ret;
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_reject_call);
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 3c47441c472b..5948191bf4eb 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -115,7 +115,6 @@ void rxrpc_UDP_error_report(struct sock *sk)
 	/* pass the transport ref to error_handler to release */
 	skb_queue_tail(&trans->error_queue, skb);
 	rxrpc_queue_work(&trans->error_handler);
-
 	_leave("");
 }
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 06bf5abd920d..8b495aed517d 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -16,7 +16,7 @@
 	BUG_ON(atomic_read((X)) >> (sizeof(atomic_t) - 2) == \
 	       (POISON_FREE << 8 | POISON_FREE))
 #else
-#define CHECK_SLAB_OKAY(X) do {} while(0)
+#define CHECK_SLAB_OKAY(X) do {} while (0)
 #endif
 
 #define FCRYPT_BSIZE 8
@@ -726,7 +726,7 @@ do {								\
 		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
 		BUG();						\
 	}							\
-} while(0)
+} while (0)
 
 #define ASSERTCMP(X, OP, Y)						\
 do {									\
@@ -739,7 +739,7 @@ do {									\
 		       (unsigned long)(X), (unsigned long)(Y));		\
 		BUG();							\
 	}								\
-} while(0)
+} while (0)
 
 #define ASSERTIF(C, X)						\
 do {								\
@@ -748,7 +748,7 @@ do {								\
 		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
 		BUG();						\
 	}							\
-} while(0)
+} while (0)
 
 #define ASSERTIFCMP(C, X, OP, Y)					\
 do {									\
@@ -761,25 +761,25 @@ do {									\
 		       (unsigned long)(X), (unsigned long)(Y));		\
 		BUG();							\
 	}								\
-} while(0)
+} while (0)
 
 #else
 
 #define ASSERT(X)				\
 do {						\
-} while(0)
+} while (0)
 
 #define ASSERTCMP(X, OP, Y)			\
 do {						\
-} while(0)
+} while (0)
 
 #define ASSERTIF(C, X)				\
 do {						\
-} while(0)
+} while (0)
 
 #define ASSERTIFCMP(C, X, OP, Y)		\
 do {						\
-} while(0)
+} while (0)
 
 #endif /* __KDEBUGALL */
 
@@ -836,9 +836,9 @@ do {							\
 	CHECK_SLAB_OKAY(&(CALL)->usage);		\
 	if (atomic_inc_return(&(CALL)->usage) == 1)	\
 		BUG();					\
-} while(0)
+} while (0)
 
 #define rxrpc_put_call(CALL)				\
 do {							\
 	__rxrpc_put_call(CALL);				\
-} while(0)
+} while (0)
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index e2f4c49a9246..ceff6394a65f 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -167,7 +167,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	struct rxrpc_sock *rx;
 	struct key *key;
 	key_ref_t kref;
-	char kdesc[5+1+3+1];
+	char kdesc[5 + 1 + 3 + 1];
 
 	_enter("");
 
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index ae9f93f94ed2..62a267472fce 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -133,5 +133,4 @@ void rxrpc_kernel_free_skb(struct sk_buff *skb)
 {
 	rxrpc_free_skb(skb);
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_free_skb);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 160480221224..0f27524536bd 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -195,9 +195,9 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
  * wholly encrypt a packet (level 2 security)
  */
 static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
-					struct sk_buff *skb,
-					u32 data_size,
-					void *sechdr)
+				       struct sk_buff *skb,
+				       u32 data_size,
+				       void *sechdr)
 {
 	const struct rxrpc_key_token *token;
 	struct rxkad_level2_hdr rxkhdr
@@ -251,9 +251,9 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
  * checksum an RxRPC packet header
  */
 static int rxkad_secure_packet(const struct rxrpc_call *call,
-				struct sk_buff *skb,
-				size_t data_size,
-				void *sechdr)
+			       struct sk_buff *skb,
+			       size_t data_size,
+			       void *sechdr)
 {
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
