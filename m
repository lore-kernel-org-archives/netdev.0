From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 8/10] socket: make cred_to_ucred static
Date: Mon, 16 Dec 2013 10:44:34 -0800
Message-ID: <20131216104434.4f80da18@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33189 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550Ab3LPTke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:34 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so5855254pbc.5
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:33 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Only used in sock core.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/linux/socket.h	2013-12-13 11:18:42.254612024 -0800
+++ b/include/linux/socket.h	2013-12-13 11:18:46.010550445 -0800
@@ -305,8 +305,6 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
-extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
-
 extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			       int offset, int len);
 extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
--- a/net/core/sock.c	2013-12-13 11:18:42.254612024 -0800
+++ b/net/core/sock.c	2013-12-13 11:19:14.714080063 -0800
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
@@ -1668,8 +1667,8 @@ EXPORT_SYMBOL(sock_wmalloc);
 /*
  * Allocate a skb from the socket's receive buffer.
  */
-struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
-			     gfp_t priority)
+static struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size,
+				    int force, gfp_t priority)
 {
 	if (force || atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf) {
 		struct sk_buff *skb = alloc_skb(size, priority);
--- a/include/net/sock.h	2013-12-12 08:46:52.536025817 -0800
+++ b/include/net/sock.h	2013-12-13 11:21:04.472284937 -0800
@@ -1535,8 +1535,6 @@ struct sock *sk_clone_lock(const struct
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
-struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
-			     gfp_t priority);
 void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
