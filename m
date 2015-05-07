From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 10/11] tipc: remove sk_change_net interface
Date: Thu, 7 May 2015 16:52:49 +0800
Message-ID: <1430988770-28907-11-git-send-email-ying.xue@windriver.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <herbert@gondor.apana.org.au>,
	<xemul@openvz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40692 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbEGIzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:55:25 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now all callers of sk_change_net() don't rely on it to create
kernel sockets, so now it's an appropriate time to purge it completely.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/net/sock.h |   16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898e..586e352 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2192,22 +2192,6 @@ void sock_net_set(struct sock *sk, struct net *net)
 	write_pnet(&sk->sk_net, net);
 }
 
-/*
- * Kernel sockets, f.e. rtnl or icmp_socket, are a part of a namespace.
- * They should not hold a reference to a namespace in order to allow
- * to stop it.
- * Sockets after sk_change_net should be released using sk_release_kernel
- */
-static inline void sk_change_net(struct sock *sk, struct net *net)
-{
-	struct net *current_net = sock_net(sk);
-
-	if (!net_eq(current_net, net)) {
-		put_net(current_net);
-		sock_net_set(sk, net);
-	}
-}
-
 static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 {
 	if (skb->sk) {
-- 
1.7.9.5
