From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: nf_ct_ipv4: handle invalid IPv4 and IPv6 packets consistently
Date: Tue, 10 Apr 2012 14:48:59 +0200
Message-ID: <1334062141-3962-4-git-send-email-pablo@netfilter.org>
References: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

IPv6 conntrack marked invalid packets as INVALID and let the user
drop those by an explicit rule, while IPv4 conntrack dropped such
packets itself.

IPv4 conntrack is changed so that it marks INVALID packets and let
the user to drop them.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index de9da21..750b06a 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -74,12 +74,12 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 
 	iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
 	if (iph == NULL)
-		return -NF_DROP;
+		return -NF_ACCEPT;
 
 	/* Conntrack defragments packets, we might still see fragments
 	 * inside ICMP packets though. */
 	if (iph->frag_off & htons(IP_OFFSET))
-		return -NF_DROP;
+		return -NF_ACCEPT;
 
 	*dataoff = nhoff + (iph->ihl << 2);
 	*protonum = iph->protocol;
-- 
1.7.2.5

