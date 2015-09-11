From: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Subject: [PATCH] Net: core: datagram.c coding style fixes
Date: Fri, 11 Sep 2015 20:21:04 +0200
Message-ID: <1441995664-13860-1-git-send-email-cristos@vipserv.org>
Cc: viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sv1-2.x14.eu ([144.76.176.218]:39815 "EHLO sv1-2.x14.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbbIKS12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 14:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed several coding style issues reported by checkpatch.pl

Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
---
 net/core/datagram.c | 89 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 51 insertions(+), 38 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 617088a..b284a6d 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -9,7 +9,8 @@
  *	identical recvmsg() code. So we share it here. The poll was
  *	shared before but buried in udp.c so I moved it.
  *
- *	Authors:	Alan Cox <alan@lxorguk.ukuu.org.uk>. (datagram_poll() from old
+ *	Authors:
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>. (datagram_poll() from old
  *						     udp.c code)
  *
  *	Fixes:
@@ -36,7 +37,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/errno.h>
@@ -60,29 +61,24 @@
 #include <trace/events/skb.h>
 #include <net/busy_poll.h>
 
-/*
- *	Is a socket 'connection oriented' ?
- */
+/* Is a socket 'connection oriented' ? */
 static inline int connection_based(struct sock *sk)
 {
 	return sk->sk_type == SOCK_SEQPACKET || sk->sk_type == SOCK_STREAM;
 }
 
-static int receiver_wake_function(wait_queue_t *wait, unsigned int mode, int sync,
-				  void *key)
+static int receiver_wake_function(wait_queue_t *wait, unsigned int mode,
+				  int sync, void *key)
 {
 	unsigned long bits = (unsigned long)key;
 
-	/*
-	 * Avoid a wakeup if event not interesting for us
-	 */
+	 /* Avoid a wakeup if event not interesting for us */
 	if (bits && !(bits & (POLLIN | POLLERR)))
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, key);
 }
-/*
- * Wait for the last received packet to be different from skb
- */
+
+/* Wait for the last received packet to be different from skb */
 static int wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				 const struct sk_buff *skb)
 {
@@ -198,8 +194,9 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 	struct sk_buff *skb, *last;
 	unsigned long cpu_flags;
 	long timeo;
-	/*
-	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
+
+	/* Caller is allowed not to check sk->sk_err before
+	 * skb_recv_datagram()
 	 */
 	int error = sock_error(sk);
 
@@ -235,9 +232,9 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 					goto unlock_err;
 
 				atomic_inc(&skb->users);
-			} else
+			} else {
 				__skb_unlink(skb, queue);
-
+			}
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			*off = _off;
 			return skb;
@@ -367,7 +364,8 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 			copy = len;
 		if (copy_to_iter(skb->data + offset, copy, to) != copy)
 			goto short_copy;
-		if ((len -= copy) == 0)
+		len -= copy;
+		if (len == 0)
 			return 0;
 		offset += copy;
 	}
@@ -380,14 +378,16 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + skb_frag_size(frag);
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			if (copy > len)
 				copy = len;
 			if (copy_page_to_iter(skb_frag_page(frag),
 					      frag->page_offset + offset -
 					      start, copy, to) != copy)
 				goto short_copy;
-			if (!(len -= copy))
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 		}
@@ -400,13 +400,15 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			if (copy > len)
 				copy = len;
 			if (skb_copy_datagram_iter(frag_iter, offset - start,
 						   to, copy))
 				goto fault;
-			if ((len -= copy) == 0)
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 		}
@@ -441,8 +443,8 @@ EXPORT_SYMBOL(skb_copy_datagram_iter);
  *	Returns 0 or -EFAULT.
  */
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
-				 struct iov_iter *from,
-				 int len)
+				struct iov_iter *from,
+				int len)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
@@ -454,7 +456,8 @@ int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 			copy = len;
 		if (copy_from_iter(skb->data + offset, copy, from) != copy)
 			goto fault;
-		if ((len -= copy) == 0)
+		len -= copy;
+		if (len == 0)
 			return 0;
 		offset += copy;
 	}
@@ -467,18 +470,19 @@ int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + skb_frag_size(frag);
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			size_t copied;
 
 			if (copy > len)
 				copy = len;
 			copied = copy_page_from_iter(skb_frag_page(frag),
-					  frag->page_offset + offset - start,
-					  copy, from);
+					frag->page_offset + offset - start,
+					copy, from);
 			if (copied != copy)
 				goto fault;
-
-			if (!(len -= copy))
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 		}
@@ -491,14 +495,16 @@ int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			if (copy > len)
 				copy = len;
 			if (skb_copy_datagram_from_iter(frag_iter,
 							offset - start,
 							from, copy))
 				goto fault;
-			if ((len -= copy) == 0)
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 		}
@@ -556,6 +562,7 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (copied) {
 			int size = min_t(int, copied, PAGE_SIZE - start);
+
 			skb_fill_page_desc(skb, frag++, pages[n], start, size);
 			start = 0;
 			copied -= size;
@@ -583,7 +590,8 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		n = csum_and_copy_to_iter(skb->data + offset, copy, csump, to);
 		if (n != copy)
 			goto fault;
-		if ((len -= copy) == 0)
+		len -= copy;
+		if (len == 0)
 			return 0;
 		offset += copy;
 		pos = copy;
@@ -596,7 +604,8 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + skb_frag_size(frag);
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			__wsum csum2 = 0;
 			struct page *page = skb_frag_page(frag);
 			u8  *vaddr = kmap(page);
@@ -610,7 +619,8 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 			if (n != copy)
 				goto fault;
 			*csump = csum_block_add(*csump, csum2, pos);
-			if (!(len -= copy))
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 			pos += copy;
@@ -624,8 +634,10 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		WARN_ON(start > offset + len);
 
 		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
+		copy = end - offset;
+		if (copy > 0) {
 			__wsum csum2 = 0;
+
 			if (copy > len)
 				copy = len;
 			if (skb_copy_and_csum_datagram(frag_iter,
@@ -634,7 +646,8 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 						       &csum2))
 				goto fault;
 			*csump = csum_block_add(*csump, csum2, pos);
-			if ((len -= copy) == 0)
+			len -= copy;
+			if (len == 0)
 				return 0;
 			offset += copy;
 			pos += copy;
@@ -736,7 +749,7 @@ fault:
 EXPORT_SYMBOL(skb_copy_and_csum_datagram_msg);
 
 /**
- * 	datagram_poll - generic datagram poll
+ *	datagram_poll - generic datagram poll
  *	@file: file struct
  *	@sock: socket
  *	@wait: poll table
-- 
2.5.1
