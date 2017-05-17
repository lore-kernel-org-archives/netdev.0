From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: make *udp*_queue_rcv_skb() functions static
Date: Wed, 17 May 2017 14:52:16 +0200
Message-ID: <8c68f6f2fb91313ab71606e42c4d3d4c561b73a9.1495024097.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751704AbdEQMwa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 08:52:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the udp memory accounting refactor, we don't need any more
to export the *udp*_queue_rcv_skb(). Make them static and fix
a couple of sparse warnings:

net/ipv4/udp.c:1615:5: warning: symbol 'udp_queue_rcv_skb' was not
declared. Should it be static?
net/ipv6/udp.c:572:5: warning: symbol 'udpv6_queue_rcv_skb' was not
declared. Should it be static?

Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
Fixes: c915fe13cbaa ("udplite: fix NULL pointer dereference")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c      | 4 ++--
 net/ipv4/udp_impl.h | 1 -
 net/ipv6/udp.c      | 4 ++--
 net/ipv6/udp_impl.h | 1 -
 4 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ea6e4cf..1d6219b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1612,7 +1612,7 @@ static void udp_v4_rehash(struct sock *sk)
 	udp_lib_rehash(sk, new_hash);
 }
 
-int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
@@ -1657,7 +1657,7 @@ EXPORT_SYMBOL(udp_encap_enable);
  * Note that in the success and error cases, the skb is assumed to
  * have either been requeued or freed.
  */
-int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index feb50a1..a8cf8c6 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -25,7 +25,6 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		int flags, int *addr_len);
 int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
-int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udp_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 04862ab..06ec39b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -526,7 +526,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return;
 }
 
-int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
@@ -569,7 +569,7 @@ void udpv6_encap_enable(void)
 }
 EXPORT_SYMBOL(udpv6_encap_enable);
 
-int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index e78bdc7..f180b3d 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -26,7 +26,6 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		  int flags, int *addr_len);
-int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
-- 
2.9.4
