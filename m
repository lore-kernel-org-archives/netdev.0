From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 11/43] nftables: Pass struct net in nft_pktinfo
Date: Wed, 17 Jun 2015 10:28:20 -0500
Message-ID: <1434554932-4552-11-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45934 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbbFQPid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:33 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
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
index f54bd2dcca1a..a028f0280cfd 100644
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
