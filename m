From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: more #ifdef CONFIG_COMPAT
Date: Tue, 26 Aug 2008 06:47:21 +0400
Message-ID: <20080826024721.GA5056@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:56652 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577AbYHZCpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 22:45:51 -0400
Received: by mu-out-0910.google.com with SMTP id g7so414324muf.1
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 19:45:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of struct proto::compat_[gs]etsockopt and
struct inet_connection_sock_af_ops::compat_[gs]etsockopt are under
#ifdef already, so use it in structure definition too.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/inet_connection_sock.h |    2 ++
 include/net/sock.h                 |    2 ++
 2 files changed, 4 insertions(+)

--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -51,12 +51,14 @@ struct inet_connection_sock_af_ops {
 				  char __user *optval, int optlen);
 	int	    (*getsockopt)(struct sock *sk, int level, int optname, 
 				  char __user *optval, int __user *optlen);
+#ifdef CONFIG_COMPAT
 	int	    (*compat_setsockopt)(struct sock *sk,
 				int level, int optname,
 				char __user *optval, int optlen);
 	int	    (*compat_getsockopt)(struct sock *sk,
 				int level, int optname,
 				char __user *optval, int __user *optlen);
+#endif
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
 	int	    (*bind_conflict)(const struct sock *sk,
 				     const struct inet_bind_bucket *tb);
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -532,6 +532,7 @@ struct proto {
 	int			(*getsockopt)(struct sock *sk, int level, 
 					int optname, char __user *optval, 
 					int __user *option);  	 
+#ifdef CONFIG_COMPAT
 	int			(*compat_setsockopt)(struct sock *sk,
 					int level,
 					int optname, char __user *optval,
@@ -540,6 +541,7 @@ struct proto {
 					int level,
 					int optname, char __user *optval,
 					int __user *option);
+#endif
 	int			(*sendmsg)(struct kiocb *iocb, struct sock *sk,
 					   struct msghdr *msg, size_t len);
 	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,

