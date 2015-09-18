From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 07/15] nftables: Pass struct net in nft_pktinfo
Date: Fri, 18 Sep 2015 14:33:00 -0500
Message-ID: <1442604788-19718-7-git-send-email-ebiederm@xmission.com>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33893 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbbIRTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:40:45 -0400
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nft_pktinfo is passed on the stack so this does not bloat any in core
data structures.

By centrally computing this information this makes maintence of the code
simpler, and understading of the code easier.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/nf_tables.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c0516529e8a0..42e239e55aa3 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -14,6 +14,7 @@
 
 struct nft_pktinfo {
 	struct sk_buff			*skb;
+	struct net			*net;
 	const struct net_device		*in;
 	const struct net_device		*out;
 	u8				pf;
@@ -30,7 +31,7 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
-	pkt->xt.net = state->net;
+	pkt->net = pkt->xt.net = state->net;
 	pkt->in = pkt->xt.in = state->in;
 	pkt->out = pkt->xt.out = state->out;
 	pkt->hook = pkt->xt.hooknum = state->hook;
-- 
2.2.1
