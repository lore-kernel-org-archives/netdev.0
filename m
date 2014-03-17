From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/38] netfilter: Convert uses of __constant_<foo> to <foo>
Date: Mon, 17 Mar 2014 13:42:55 +0100
Message-ID: <1395060178-11833-36-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59527 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933180AbaCQMnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:49 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/pfxlen.c |    4 ++--
 net/netfilter/xt_AUDIT.c     |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipset/pfxlen.c b/net/netfilter/ipset/pfxlen.c
index 4f29fa9..04d15fd 100644
--- a/net/netfilter/ipset/pfxlen.c
+++ b/net/netfilter/ipset/pfxlen.c
@@ -7,8 +7,8 @@
 
 #define E(a, b, c, d) \
 	{.ip6 = { \
-		__constant_htonl(a), __constant_htonl(b), \
-		__constant_htonl(c), __constant_htonl(d), \
+		htonl(a), htonl(b), \
+		htonl(c), htonl(d), \
 	} }
 
 /*
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 3228d7f..4973cbd 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -146,11 +146,11 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 		if (par->family == NFPROTO_BRIDGE) {
 			switch (eth_hdr(skb)->h_proto) {
-			case __constant_htons(ETH_P_IP):
+			case htons(ETH_P_IP):
 				audit_ip4(ab, skb);
 				break;
 
-			case __constant_htons(ETH_P_IPV6):
+			case htons(ETH_P_IPV6):
 				audit_ip6(ab, skb);
 				break;
 			}
-- 
1.7.10.4
