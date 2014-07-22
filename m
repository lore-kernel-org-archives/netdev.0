From: Sorin Dumitru <sorin@returnze.ro>
Subject: [PATCH net-next] sock: remove skb argument from sk_rcvqueues_full
Date: Tue, 22 Jul 2014 16:36:12 +0300
Message-ID: <1406036172-16573-1-git-send-email-sorin@returnze.ro>
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	Sorin Dumitru <sorin@returnze.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:63125 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaGVNgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 09:36:20 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so6028121wib.3
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 06:36:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It hasn't been used since commit 0fd7bac.

Signed-off-by: Sorin Dumitru <sorin@returnze.ro>
---
 include/net/sock.h | 5 ++---
 net/core/sock.c    | 2 +-
 net/ipv4/udp.c     | 2 +-
 net/ipv6/udp.c     | 2 +-
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 28f7346..7207733 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -810,8 +810,7 @@ static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
  * Do not take into account this skb truesize,
  * to allow even a single big packet to come.
  */
-static inline bool sk_rcvqueues_full(const struct sock *sk, const struct sk_buff *skb,
-				     unsigned int limit)
+static inline bool sk_rcvqueues_full(const struct sock *sk, unsigned int limit)
 {
 	unsigned int qsize = sk->sk_backlog.len + atomic_read(&sk->sk_rmem_alloc);
 
@@ -822,7 +821,7 @@ static inline bool sk_rcvqueues_full(const struct sock *sk, const struct sk_buff
 static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *skb,
 					      unsigned int limit)
 {
-	if (sk_rcvqueues_full(sk, skb, limit))
+	if (sk_rcvqueues_full(sk, limit))
 		return -ENOBUFS;
 
 	__sk_add_backlog(sk, skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 026e01f..ca9b651 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -491,7 +491,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 
 	skb->dev = NULL;
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		atomic_inc(&sk->sk_drops);
 		goto discard_and_relse;
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f31053b..f57c0e4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1567,7 +1567,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		goto csum_error;
 
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 				 is_udplite);
 		goto drop;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f9d8800..5b6091d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -673,7 +673,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 			goto csum_error;
 	}
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		UDP6_INC_STATS_BH(sock_net(sk),
 				  UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
-- 
2.0.2
