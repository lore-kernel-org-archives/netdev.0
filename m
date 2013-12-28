From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv4: ping make local stuff static
Date: Sat, 28 Dec 2013 11:11:42 -0800
Message-ID: <20131228111142.6fcc0234@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vasiliy Kulikov <segoon@openwall.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60732 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab3L1TLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 14:11:47 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so10155270pbc.5
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 11:11:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't export ping_table or ping_v4_sendmsg. Both are only used
inside ping code.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/net/ping.h |    8 --------
 net/ipv4/ping.c    |   10 +++++++---
 2 files changed, 7 insertions(+), 11 deletions(-)

--- a/include/net/ping.h	2013-12-24 15:15:26.753741401 -0800
+++ b/include/net/ping.h	2013-12-24 15:15:59.905295851 -0800
@@ -42,11 +42,6 @@ struct pingv6_ops {
 			     const struct net_device *dev, int strict);
 };
 
-struct ping_table {
-	struct hlist_nulls_head	hash[PING_HTABLE_SIZE];
-	rwlock_t		lock;
-};
-
 struct ping_iter_state {
 	struct seq_net_private  p;
 	int			bucket;
@@ -54,7 +49,6 @@ struct ping_iter_state {
 };
 
 extern struct proto ping_prot;
-extern struct ping_table ping_table;
 #if IS_ENABLED(CONFIG_IPV6)
 extern struct pingv6_ops pingv6_ops;
 #endif
@@ -81,8 +75,6 @@ int  ping_recvmsg(struct kiocb *iocb, st
 		  size_t len, int noblock, int flags, int *addr_len);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
-int  ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		     size_t len);
 int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		     size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
--- a/net/ipv4/ping.c	2013-12-24 15:15:26.753741401 -0800
+++ b/net/ipv4/ping.c	2013-12-24 15:15:59.905295851 -0800
@@ -53,8 +53,12 @@
 #include <net/transp_v6.h>
 #endif
 
+struct ping_table {
+	struct hlist_nulls_head	hash[PING_HTABLE_SIZE];
+	rwlock_t		lock;
+};
 
-struct ping_table ping_table;
+static struct ping_table ping_table;
 struct pingv6_ops pingv6_ops;
 EXPORT_SYMBOL_GPL(pingv6_ops);
 
@@ -668,8 +672,8 @@ int ping_common_sendmsg(int family, stru
 }
 EXPORT_SYMBOL_GPL(ping_common_sendmsg);
 
-int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		    size_t len)
+static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+			   size_t len)
 {
 	struct net *net = sock_net(sk);
 	struct flowi4 fl4;
