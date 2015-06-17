From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 19/43] ipvs: Read hooknum from state rather than ops->hooknum
Date: Wed, 17 Jun 2015 10:28:28 -0500
Message-ID: <1434554932-4552-19-git-send-email-ebiederm@xmission.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
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
index f8a11129b371..8cc6b285d690 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1274,7 +1274,7 @@ static unsigned int
 ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1285,7 +1285,7 @@ static unsigned int
 ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET);
+	return ip_vs_out(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1299,7 +1299,7 @@ static unsigned int
 ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1310,7 +1310,7 @@ static unsigned int
 ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(ops->hooknum, skb, AF_INET6);
+	return ip_vs_out(state->hook, skb, AF_INET6);
 }
 
 #endif
@@ -1767,7 +1767,7 @@ static unsigned int
 ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 /*
@@ -1778,7 +1778,7 @@ static unsigned int
 ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET);
+	return ip_vs_in(state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1791,7 +1791,7 @@ static unsigned int
 ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1802,7 +1802,7 @@ static unsigned int
 ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(ops->hooknum, skb, AF_INET6);
+	return ip_vs_in(state->hook, skb, AF_INET6);
 }
 
 #endif
-- 
2.2.1

