From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Remove needless check of return value
Date: Thu, 29 Aug 2013 18:19:18 -0700
Message-ID: <1377825558-8800-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52177 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab3H3BWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 21:22:19 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so1170732pdj.18
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 18:22:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 0c24604b (tcp: implement RFC 5961 4.2), tcp_rcv_established() only
returns 0 since we no longer send RSTs in response to SYNs. We can remove the
check on the return value.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    5 +----
 net/ipv6/tcp_ipv6.c |    3 +--
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 09d45d7..b14266b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1799,10 +1799,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
-			rsk = sk;
-			goto reset;
-		}
+		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
 		return 0;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5bcfadf..9acdced 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1360,8 +1360,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 			}
 		}
 
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
-			goto reset;
+		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
 		if (opt_skb)
 			goto ipv6_pktoptions;
 		return 0;
-- 
1.7.9.5
