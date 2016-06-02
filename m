From: Joe Perches <joe@perches.com>
Subject: [PATCH] rxrpc: Use pr_<level> and pr_fmt, reduce object size a few KB
Date: Thu,  2 Jun 2016 12:08:52 -0700
Message-ID: <c7437f437c30addd6dafa35b87d7c57061dc752b.1464894331.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com
To: David Howells <dhowells@redhat.com>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common kernel logging style and reduce object size.

The logging message prefix changes from a mixture of
"RxRPC:" and "RXRPC:" to "af_rxrpc: ".

$ size net/rxrpc/built-in.o*
   text	   data	    bss	    dec	    hex	filename
  64172	   1972	   8304	  74448	  122d0	net/rxrpc/built-in.o.new
  67512	   1972	   8304	  77788	  12fdc	net/rxrpc/built-in.o.old

Miscellanea:

o Consolidate the ASSERT macros to use a single pr_err call with
  decimal and hexadecimal output and a stringified #OP argument

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rxrpc/af_rxrpc.c      | 18 ++++++++++--------
 net/rxrpc/ar-accept.c     |  2 ++
 net/rxrpc/ar-ack.c        |  2 ++
 net/rxrpc/ar-call.c       | 12 ++++++------
 net/rxrpc/ar-connection.c |  2 ++
 net/rxrpc/ar-connevent.c  |  2 ++
 net/rxrpc/ar-input.c      |  2 ++
 net/rxrpc/ar-internal.h   | 30 ++++++++++++------------------
 net/rxrpc/ar-key.c        |  4 +++-
 net/rxrpc/ar-local.c      |  2 ++
 net/rxrpc/ar-output.c     |  2 ++
 net/rxrpc/ar-peer.c       |  2 ++
 net/rxrpc/ar-recvmsg.c    |  4 +++-
 net/rxrpc/ar-skbuff.c     |  2 ++
 net/rxrpc/ar-transport.c  |  2 ++
 net/rxrpc/rxkad.c         |  2 ++
 16 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index e45e94c..7840b8e 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
@@ -796,49 +798,49 @@ static int __init af_rxrpc_init(void)
 		"rxrpc_call_jar", sizeof(struct rxrpc_call), 0,
 		SLAB_HWCACHE_ALIGN, NULL);
 	if (!rxrpc_call_jar) {
-		printk(KERN_NOTICE "RxRPC: Failed to allocate call jar\n");
+		pr_notice("Failed to allocate call jar\n");
 		goto error_call_jar;
 	}
 
 	rxrpc_workqueue = alloc_workqueue("krxrpcd", 0, 1);
 	if (!rxrpc_workqueue) {
-		printk(KERN_NOTICE "RxRPC: Failed to allocate work queue\n");
+		pr_notice("Failed to allocate work queue\n");
 		goto error_work_queue;
 	}
 
 	ret = rxrpc_init_security();
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot initialise security\n");
+		pr_crit("Cannot initialise security\n");
 		goto error_security;
 	}
 
 	ret = proto_register(&rxrpc_proto, 1);
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
+		pr_crit("Cannot register protocol\n");
 		goto error_proto;
 	}
 
 	ret = sock_register(&rxrpc_family_ops);
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot register socket family\n");
+		pr_crit("Cannot register socket family\n");
 		goto error_sock;
 	}
 
 	ret = register_key_type(&key_type_rxrpc);
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot register client key type\n");
+		pr_crit("Cannot register client key type\n");
 		goto error_key_type;
 	}
 
 	ret = register_key_type(&key_type_rxrpc_s);
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot register server key type\n");
+		pr_crit("Cannot register server key type\n");
 		goto error_key_type_s;
 	}
 
 	ret = rxrpc_sysctl_init();
 	if (ret < 0) {
-		printk(KERN_CRIT "RxRPC: Cannot register sysctls\n");
+		pr_crit("Cannot register sysctls\n");
 		goto error_sysctls;
 	}
 
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index e7a7f05..eea5f4a 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 374478e..1838178 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/circ_buf.h>
 #include <linux/net.h>
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 571a41f..1fbaae1 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/circ_buf.h>
@@ -669,8 +671,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 			       conn->channels[3] == NULL);
 			break;
 		default:
-			printk(KERN_ERR "RxRPC: conn->avail_calls=%d\n",
-			       conn->avail_calls);
+			pr_err("conn->avail_calls=%d\n", conn->avail_calls);
 			BUG();
 		}
 	}
@@ -935,16 +936,15 @@ void __exit rxrpc_destroy_all_calls(void)
 			if (call->state != RXRPC_CALL_DEAD)
 				break;
 		default:
-			printk(KERN_ERR "RXRPC:"
-			       " Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
+			pr_err("Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
 			       call, atomic_read(&call->usage),
 			       atomic_read(&call->ackr_not_idle),
 			       rxrpc_call_states[call->state],
 			       call->flags, call->events);
 			if (!skb_queue_empty(&call->rx_queue))
-				printk(KERN_ERR"RXRPC: Rx queue occupied\n");
+				pr_err("Rx queue occupied\n");
 			if (!skb_queue_empty(&call->rx_oos_queue))
-				printk(KERN_ERR"RXRPC: OOS queue occupied\n");
+				pr_err("OOS queue occupied\n");
 			break;
 		}
 
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 97f4fae..d67b1f1 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/net.h>
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 5f95639..8bdd692 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 6ff9741..d7c2a0b 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f0b807a..18ab5c5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -744,21 +744,18 @@ do {							\
 #define ASSERT(X)						\
 do {								\
 	if (unlikely(!(X))) {					\
-		printk(KERN_ERR "\n");				\
-		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
+		pr_err("Assertion failed\n");			\
 		BUG();						\
 	}							\
 } while (0)
 
 #define ASSERTCMP(X, OP, Y)						\
 do {									\
-	if (unlikely(!((X) OP (Y)))) {					\
-		printk(KERN_ERR "\n");					\
-		printk(KERN_ERR "RxRPC: Assertion failed\n");		\
-		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
-		       (unsigned long)(X), (unsigned long)(Y));		\
-		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
-		       (unsigned long)(X), (unsigned long)(Y));		\
+	unsigned long _x = (unsigned long)(X);				\
+	unsigned long _y = (unsigned long)(Y);				\
+	if (unlikely(!(_x OP _y))) {					\
+		pr_err("Assertion failed - %lu(0x%lx) %s %lu(0x%lx) is false\n",			\
+		       _x, _x, #OP, _y, _y);				\
 		BUG();							\
 	}								\
 } while (0)
@@ -766,21 +763,18 @@ do {									\
 #define ASSERTIF(C, X)						\
 do {								\
 	if (unlikely((C) && !(X))) {				\
-		printk(KERN_ERR "\n");				\
-		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
+		pr_err("Assertion failed\n");			\
 		BUG();						\
 	}							\
 } while (0)
 
 #define ASSERTIFCMP(C, X, OP, Y)					\
 do {									\
-	if (unlikely((C) && !((X) OP (Y)))) {				\
-		printk(KERN_ERR "\n");					\
-		printk(KERN_ERR "RxRPC: Assertion failed\n");		\
-		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
-		       (unsigned long)(X), (unsigned long)(Y));		\
-		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
-		       (unsigned long)(X), (unsigned long)(Y));		\
+	unsigned long _x = (unsigned long)(X);				\
+	unsigned long _y = (unsigned long)(Y);				\
+	if (unlikely((C) && !(_x OP _y))) {				\
+		pr_err("Assertion failed - %lu(0x%lx) %s %lu(0x%lx) is false\n", \
+		       _x, _x, #OP, _y, _y);				\
 		BUG();							\
 	}								\
 } while (0)
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 1021b4c..4ad56fa 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -12,6 +12,8 @@
  *	"afs@CAMBRIDGE.REDHAT.COM>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/net.h>
@@ -800,7 +802,7 @@ static void rxrpc_free_token_list(struct rxrpc_key_token *token)
 				rxrpc_rxk5_free(token->k5);
 			break;
 		default:
-			printk(KERN_ERR "Unknown token type %x on rxrpc key\n",
+			pr_err("Unknown token type %x on rxrpc key\n",
 			       token->security_index);
 			BUG();
 		}
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index 4e1e6db..701c42b 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 51cb100..ea61953 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/net.h>
 #include <linux/gfp.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index dc089b1..0b54cda 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 160f092..59706b9 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
@@ -307,7 +309,7 @@ receive_non_data_message:
 			       &abort_code);
 		break;
 	default:
-		pr_err("RxRPC: Unknown packet mark %u\n", skb->mark);
+		pr_err("Unknown packet mark %u\n", skb->mark);
 		BUG();
 		break;
 	}
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index 62a2674..eee0cfd9 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 66a1a56..a1b6518 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 6b726a0..d4da538 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -9,6 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/net.h>
-- 
2.8.0.rc4.16.g56331f8
