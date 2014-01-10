From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/23] netfilter: nf_tables: rename nft_do_chain_pktinfo() to nft_do_chain()
Date: Fri, 10 Jan 2014 01:35:41 +0100
Message-ID: <1389314142-17969-23-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

We don't encode argument types into function names and since besides
nft_do_chain() there are only AF-specific versions, there is no risk
of confusion.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h         |    4 ++--
 net/bridge/netfilter/nf_tables_bridge.c   |    2 +-
 net/ipv4/netfilter/nf_tables_arp.c        |    2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c       |    2 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |    2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |    2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c       |    2 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |    2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |    2 +-
 net/netfilter/nf_tables_core.c            |    4 ++--
 10 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 3422365..57c8ff7 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -447,8 +447,8 @@ static inline struct nft_base_chain *nft_base_chain(const struct nft_chain *chai
 	return container_of(chain, struct nft_base_chain, chain);
 }
 
-unsigned int nft_do_chain_pktinfo(struct nft_pktinfo *pkt,
-				  const struct nf_hook_ops *ops);
+unsigned int nft_do_chain(struct nft_pktinfo *pkt,
+			  const struct nf_hook_ops *ops);
 
 /**
  *	struct nft_table - nf_tables table
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index c83fab5..5bcc0d8 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -25,7 +25,7 @@ nft_do_chain_bridge(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo(&pkt, ops, skb, in, out);
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain(&pkt, ops);
 }
 
 static struct nft_af_info nft_af_bridge __read_mostly = {
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index b90d16c..19412a4 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -25,7 +25,7 @@ nft_do_chain_arp(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo(&pkt, ops, skb, in, out);
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain(&pkt, ops);
 }
 
 static struct nft_af_info nft_af_arp __read_mostly = {
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 66679fd..fec163a 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -28,7 +28,7 @@ static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain(&pkt, ops);
 }
 
 static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index 208d60a..b5b256d 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -75,7 +75,7 @@ static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
 
 		nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
 
-		ret = nft_do_chain_pktinfo(&pkt, ops);
+		ret = nft_do_chain(&pkt, ops);
 		if (ret != NF_ACCEPT)
 			return ret;
 		if (!nf_nat_initialized(ct, maniptype)) {
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 67db1bb..125b667 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -47,7 +47,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = nft_do_chain_pktinfo(&pkt, ops);
+	ret = nft_do_chain(&pkt, ops);
 	if (ret != NF_DROP && ret != NF_QUEUE) {
 		iph = ip_hdr(skb);
 
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 859fca0..59a43b4 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -28,7 +28,7 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
 		return NF_DROP;
 
-	return nft_do_chain_pktinfo(&pkt, ops);
+	return nft_do_chain(&pkt, ops);
 }
 
 static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index 9ed60ab..9c3297a 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -79,7 +79,7 @@ static unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
 
 		nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out);
 
-		ret = nft_do_chain_pktinfo(&pkt, ops);
+		ret = nft_do_chain(&pkt, ops);
 		if (ret != NF_ACCEPT)
 			return ret;
 		if (!nf_nat_initialized(ct, maniptype)) {
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index b2b7eff..4203129 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -47,7 +47,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u32 *)ipv6_hdr(skb));
 
-	ret = nft_do_chain_pktinfo(&pkt, ops);
+	ret = nft_do_chain(&pkt, ops);
 	if (ret != NF_DROP && ret != NF_QUEUE &&
 	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
 	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 5aae317..0d879fc 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -116,7 +116,7 @@ static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
 }
 
 unsigned int
-nft_do_chain_pktinfo(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
+nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv;
 	const struct nft_rule *rule;
@@ -216,7 +216,7 @@ next_rule:
 
 	return nft_base_chain(chain)->policy;
 }
-EXPORT_SYMBOL_GPL(nft_do_chain_pktinfo);
+EXPORT_SYMBOL_GPL(nft_do_chain);
 
 int __init nf_tables_core_module_init(void)
 {
-- 
1.7.10.4

