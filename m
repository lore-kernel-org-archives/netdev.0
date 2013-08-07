From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 2/2] ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL
Date: Wed,  7 Aug 2013 17:40:29 +0900
Message-ID: <1375864829-19840-3-git-send-email-horms@verge.net.au>
References: <1375864829-19840-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48366 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186Ab3HGIke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 04:40:34 -0400
In-Reply-To: <1375864829-19840-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

skb_header_pointer could return NULL, so check for it as we do it
everywhere else in ipvs code. This fixes a coverity warning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c | 6 ++++++
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
1.8.3.2
