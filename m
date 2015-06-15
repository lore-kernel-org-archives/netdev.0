From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/32] netfilter: bridge: refactor clearing BRNF_NF_BRIDGE_PREROUTING
Date: Mon, 15 Jun 2015 23:25:59 +0200
Message-ID: <1434403589-24796-3-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

use binary AND on complement of BRNF_NF_BRIDGE_PREROUTING to unset
bit in nf_bridge->mask.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 46660a2..2651876 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -290,7 +290,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
 
 	rt = bridge_parent_rtable(nf_bridge->physindev);
 	if (!rt) {
@@ -415,7 +415,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
 	if (daddr_was_changed(skb, nf_bridge)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
-- 
1.7.10.4

