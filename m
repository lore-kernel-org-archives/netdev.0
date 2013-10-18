From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: rename tcp_tso_segment()
Date: Fri, 18 Oct 2013 10:36:17 -0700
Message-ID: <1382117777.3284.26.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:49883 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253Ab3JRRgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:36:21 -0400
Received: by mail-pd0-f180.google.com with SMTP id p10so2599497pdj.25
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 10:36:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Rename tcp_tso_segment() to tcp_gso_segment(), to better reflect
what is going on, and ease grep games.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        |    2 +-
 net/ipv4/tcp_offload.c   |    6 +++---
 net/ipv6/tcpv6_offload.c |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1db3a01..372dccc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1548,7 +1548,7 @@ extern struct request_sock_ops tcp6_request_sock_ops;
 
 void tcp_v4_destroy_sock(struct sock *sk);
 
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features);
 struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb);
 int tcp_gro_complete(struct sk_buff *skb);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 3a7525e..8e3113f 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -14,7 +14,7 @@
 #include <net/tcp.h>
 #include <net/protocol.h>
 
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
@@ -139,7 +139,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 out:
 	return segs;
 }
-EXPORT_SYMBOL(tcp_tso_segment);
+EXPORT_SYMBOL(tcp_gso_segment);
 
 struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
@@ -320,7 +320,7 @@ static int tcp4_gro_complete(struct sk_buff *skb)
 static const struct net_offload tcpv4_offload = {
 	.callbacks = {
 		.gso_send_check	=	tcp_v4_gso_send_check,
-		.gso_segment	=	tcp_tso_segment,
+		.gso_segment	=	tcp_gso_segment,
 		.gro_receive	=	tcp4_gro_receive,
 		.gro_complete	=	tcp4_gro_complete,
 	},
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 2ec6bf6..c1097c7 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -83,7 +83,7 @@ static int tcp6_gro_complete(struct sk_buff *skb)
 static const struct net_offload tcpv6_offload = {
 	.callbacks = {
 		.gso_send_check	=	tcp_v6_gso_send_check,
-		.gso_segment	=	tcp_tso_segment,
+		.gso_segment	=	tcp_gso_segment,
 		.gro_receive	=	tcp6_gro_receive,
 		.gro_complete	=	tcp6_gro_complete,
 	},
