From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nft_reject_inet: fix unintended fall-through in switch-statatement
Date: Wed, 19 Feb 2014 12:41:37 +0100
Message-ID: <1392810102-13877-2-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44978 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbaBSLly (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:54 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

For IPv4 packets, we call both IPv4 and IPv6 reject.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_reject_inet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 8a310f2..b718a52 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -21,9 +21,9 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 {
 	switch (pkt->ops->pf) {
 	case NFPROTO_IPV4:
-		nft_reject_ipv4_eval(expr, data, pkt);
+		return nft_reject_ipv4_eval(expr, data, pkt);
 	case NFPROTO_IPV6:
-		nft_reject_ipv6_eval(expr, data, pkt);
+		return nft_reject_ipv6_eval(expr, data, pkt);
 	}
 }
 
-- 
1.7.10.4
