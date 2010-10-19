From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] socket: localize functions
Date: Mon, 18 Oct 2010 17:27:29 -0700
Message-ID: <20101018172729.68755c69@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49981 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656Ab0JSA1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of functions in socket.c are only used there and
should be localized.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/socket.h	2010-10-18 17:06:18.455644277 -0700
+++ b/include/linux/socket.h	2010-10-18 17:06:26.763083909 -0700
@@ -326,7 +326,6 @@ extern long verify_iovec(struct msghdr *
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
 extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
 			     int offset, int len);
-extern int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uaddr, int __user *ulen);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
--- a/net/socket.c	2010-10-18 17:06:18.475642930 -0700
+++ b/net/socket.c	2010-10-18 17:12:53.001522923 -0700
@@ -209,8 +209,8 @@ int move_addr_to_kernel(void __user *uad
  *	specified. Zero is returned for a success.
  */
 
-int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uaddr,
-		      int __user *ulen)
+static int move_addr_to_user(struct sockaddr *kaddr, int klen,
+			     void __user *uaddr, int __user *ulen)
 {
 	int err;
 	int len;
@@ -661,7 +661,8 @@ void __sock_recv_timestamp(struct msghdr
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-inline void sock_recv_drops(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
+static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
+				   struct sk_buff *skb)
 {
 	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
 		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
