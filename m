From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 11/14] ipvs: Read hooknum from state rather than ops->hooknum
Date: Fri, 18 Sep 2015 11:05:57 -0500
Message-ID: <1442592360-2575-11-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W Biederman <ebiederm@xmission.com>

This should be more cache efficient as state is more likely to be in
core, and the netfilter core will stop passing in ops soon.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 38fbc194b9cb..0be5f12cb12d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1286,7 +1286,7 @@ static unsigned int
 ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1297,7 +1297,7 @@ static unsigned int
 ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1311,7 +1311,7 @@ static unsigned int
 ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1322,7 +1322,7 @@ static unsigned int
 ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 #endif
@@ -1779,7 +1779,7 @@ static unsigned int
 ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1790,7 +1790,7 @@ static unsigned int
 ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1803,7 +1803,7 @@ static unsigned int
 ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1814,7 +1814,7 @@ static unsigned int
 ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 #endif
-- 
2.2.1

