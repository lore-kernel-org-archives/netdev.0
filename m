From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/17] tcp: call sk_mark_napi_id() on the child, not the listener
Date: Fri,  2 Oct 2015 11:43:26 -0700
Message-ID: <1443811419-4798-5-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33649 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbbJBSn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:56 -0400
Received: by pacex6 with SMTP id ex6so113532986pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:56 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a typo : We want to store the NAPI id on child socket.
Presumably nobody really uses busy polling, on short lived flows.

Fixes: 3d97379a67486 ("tcp: move sk_mark_napi_id() at the right place")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 2 +-
 net/ipv6/tcp_ipv6.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 64ece718d66c..2fb0945b9d83 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1411,7 +1411,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
-			sk_mark_napi_id(sk, skb);
+			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2ae95e1d03e1..e463583c39ee 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1265,7 +1265,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
-			sk_mark_napi_id(sk, skb);
+			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)
-- 
2.6.0.rc2.230.g3dd15c0
