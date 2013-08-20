From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/19] ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL
Date: Tue, 20 Aug 2013 12:54:46 +0200
Message-ID: <1376996091-3964-15-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60118 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261Ab3HTKzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:15 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

skb_header_pointer could return NULL, so check for it as we do it
everywhere else in ipvs code. This fixes a coverity warning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index f16c027..3588fae 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -269,14 +269,20 @@ ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
 		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (unlikely(th == NULL))
+			return 0;
 		port = th->source;
 		break;
 	case IPPROTO_UDP:
 		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		if (unlikely(uh == NULL))
+			return 0;
 		port = uh->source;
 		break;
 	case IPPROTO_SCTP:
 		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		if (unlikely(sh == NULL))
+			return 0;
 		port = sh->source;
 		break;
 	default:
-- 
1.7.10.4
