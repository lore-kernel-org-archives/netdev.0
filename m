From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] socket: cleanup
Date: Mon, 30 Dec 2013 10:40:12 -0800
Message-ID: <20131230104012.3ecea4d5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:46540 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab3L3Slb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:41:31 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so11893247pad.31
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:41:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found while doing namespace checks

 * make cred_to_ucred static
 * remove unused sock_rmalloc function

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/socket.h |    2 --
 include/net/sock.h     |    2 --
 net/core/sock.c        |   19 +------------------
 3 files changed, 1 insertion(+), 22 deletions(-)

--- a/include/linux/socket.h	2013-12-24 15:15:26.581743712 -0800
+++ b/include/linux/socket.h	2013-12-24 15:16:00.797283859 -0800
@@ -305,8 +305,6 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
-extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
-
 extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			       int offset, int len);
 extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
--- a/net/core/sock.c	2013-12-24 15:15:26.581743712 -0800
+++ b/net/core/sock.c	2013-12-24 15:16:00.801283806 -0800
@@ -925,7 +925,7 @@ set_rcvbuf:
 EXPORT_SYMBOL(sock_setsockopt);
 
 
-void cred_to_ucred(struct pid *pid, const struct cred *cred,
+static void cred_to_ucred(struct pid *pid, const struct cred *cred,
 		   struct ucred *ucred)
 {
 	ucred->pid = pid_vnr(pid);
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
--- a/include/net/sock.h	2013-12-24 15:15:26.581743712 -0800
+++ b/include/net/sock.h	2013-12-24 15:16:00.801283806 -0800
@@ -1535,8 +1535,6 @@ struct sock *sk_clone_lock(const struct
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
-struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
-			     gfp_t priority);
 void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
