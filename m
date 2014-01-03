From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2] socket: cleanups
Date: Fri, 3 Jan 2014 09:17:14 -0800
Message-ID: <20140103091714.47b1867c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:41210 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaACRRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 12:17:31 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so15894982pbb.4
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 09:17:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Namespace related cleaning

 * make cred_to_ucred static
 * remove unused sock_rmalloc function

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 - fix indentation

 include/linux/socket.h |    2 --
 include/net/sock.h     |    2 --
 net/core/sock.c        |   19 +------------------
 3 files changed, 1 insertion(+), 22 deletions(-)

--- a/include/linux/socket.h	2013-12-31 17:32:13.457244238 -0800
+++ b/include/linux/socket.h	2014-01-01 22:25:21.900223830 -0800
@@ -305,8 +305,6 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
-extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
-
 extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			       int offset, int len);
 extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
--- a/net/core/sock.c	2013-12-31 17:45:31.505949853 -0800
+++ b/net/core/sock.c	2014-01-01 22:25:37.736024666 -0800
@@ -925,8 +925,8 @@ set_rcvbuf:
 EXPORT_SYMBOL(sock_setsockopt);
 
 
-void cred_to_ucred(struct pid *pid, const struct cred *cred,
-		   struct ucred *ucred)
+static void cred_to_ucred(struct pid *pid, const struct cred *cred,
+			  struct ucred *ucred)
 {
 	ucred->pid = pid_vnr(pid);
 	ucred->uid = ucred->gid = -1;
@@ -937,7 +937,6 @@ void cred_to_ucred(struct pid *pid, cons
 		ucred->gid = from_kgid_munged(current_ns, cred->egid);
 	}
 }
-EXPORT_SYMBOL_GPL(cred_to_ucred);
 
 int sock_getsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int __user *optlen)
@@ -1666,22 +1665,6 @@ struct sk_buff *sock_wmalloc(struct sock
 EXPORT_SYMBOL(sock_wmalloc);
 
 /*
- * Allocate a skb from the socket's receive buffer.
- */
-struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
-			     gfp_t priority)
-{
-	if (force || atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf) {
-		struct sk_buff *skb = alloc_skb(size, priority);
-		if (skb) {
-			skb_set_owner_r(skb, sk);
-			return skb;
-		}
-	}
-	return NULL;
-}
-
-/*
  * Allocate a memory block from the socket's option memory buffer.
  */
 void *sock_kmalloc(struct sock *sk, int size, gfp_t priority)
--- a/include/net/sock.h	2013-12-31 17:32:18.981166890 -0800
+++ b/include/net/sock.h	2014-01-01 22:25:21.900223830 -0800
@@ -1549,8 +1549,6 @@ struct sock *sk_clone_lock(const struct
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
-struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
-			     gfp_t priority);
 void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
