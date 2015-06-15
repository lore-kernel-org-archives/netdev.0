From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/32] netfilter: bridge: rename br_parse_ip_options
Date: Mon, 15 Jun 2015 23:26:03 +0200
Message-ID: <1434403589-24796-7-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

br_parse_ip_options() does not parse any IP options, it validates IP
packets as a whole and the function name is misleading.

Rename br_parse_ip_options() to br_validate_ipv4() and remove unneeded
commments.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1f30b28..962d5f8 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -216,7 +216,7 @@ static inline void nf_bridge_pull_encap_header_rcsum(struct sk_buff *skb)
  * expected format
  */
 
-static int br_parse_ip_options(struct sk_buff *skb)
+static int br_validate_ipv4(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
@@ -692,7 +692,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 
 	nf_bridge_pull_encap_header_rcsum(skb);
 
-	if (br_parse_ip_options(skb))
+	if (br_validate_ipv4(skb))
 		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
@@ -802,7 +802,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	}
 
 	if (pf == NFPROTO_IPV4) {
-		if (br_parse_ip_options(skb))
+		if (br_validate_ipv4(skb))
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
 	}
@@ -913,8 +913,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 	if (skb->len + mtu_reserved > skb->dev->mtu) {
 		struct brnf_frag_data *data;
 
-		if (br_parse_ip_options(skb))
-			/* Drop invalid packet */
+		if (br_validate_ipv4(skb))
 			return NF_DROP;
 
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
-- 
1.7.10.4

