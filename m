From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/30] ipvs: Read hooknum from state rather than ops->hooknum
Date: Tue, 22 Sep 2015 11:14:17 +0200
Message-ID: <1442913260-3925-28-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35223 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757772AbbIVJIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:08:06 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This should be more cache efficient as state is more likely to be in
core, and the netfilter core will stop passing in ops soon.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 453972c..40e3c85 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1314,7 +1314,7 @@ static unsigned int
 ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1325,7 +1325,7 @@ static unsigned int
 ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1339,7 +1339,7 @@ static unsigned int
 ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1350,7 +1350,7 @@ static unsigned int
 ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 #endif
@@ -1850,7 +1850,7 @@ static unsigned int
 ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1861,7 +1861,7 @@ static unsigned int
 ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1874,7 +1874,7 @@ static unsigned int
 ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1885,7 +1885,7 @@ static unsigned int
 ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 #endif
-- 
1.7.10.4
