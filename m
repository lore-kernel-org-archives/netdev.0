From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 73/84] ipvs: Simplify ipvs and net access in ip_vs_leave
Date: Sun, 20 Sep 2015 01:23:29 -0500
Message-ID: <1442730220-32458-73-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stop using the hack skb_net(skb) to compute the network namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7e9ee1dece19..15661691bf7d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -568,21 +568,17 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
 	__be16 _ports[2], *pptr, dport;
-	struct net *net;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = svc->ipvs;
+	struct net *net = ipvs->net;
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (!pptr)
 		return NF_DROP;
 	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
 
-	net = skb_net(skb);
-
