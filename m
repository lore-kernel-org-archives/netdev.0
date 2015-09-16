From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 26/30] bridge: Cache net in br_nf_pre_routing_finish
Date: Tue, 15 Sep 2015 20:04:14 -0500
Message-ID: <1442365458-16349-26-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is prep work for passing net to the netfilter hooks.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_netfilter_hooks.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index e6910b71af6e..c1127908e23a 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -346,6 +346,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
+	struct net *net = dev_net(dev);
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	int err;
@@ -371,7 +372,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			rt = ip_route_output(dev_net(dev), iph->daddr, 0,
+			rt = ip_route_output(net, iph->daddr, 0,
 					     RT_TOS(iph->tos), 0);
 			if (!IS_ERR(rt)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
-- 
2.2.1

