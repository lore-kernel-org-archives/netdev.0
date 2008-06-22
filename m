From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 11/25] netns ct: get netns from device for ICMP/ICMP6
Date: Sun, 22 Jun 2008 05:10:13 +0400
Message-ID: <20080622011013.GL5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grab it either from skb->dev in input, or skb->dst->dev in output.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 +++++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -127,6 +127,7 @@ icmp_error_message(struct sk_buff *skb,
 		 enum ip_conntrack_info *ctinfo,
 		 unsigned int hooknum)
 {
+	struct net_device *dev;
 	struct nf_conntrack_tuple innertuple, origtuple;
 	const struct nf_conntrack_l4proto *innerproto;
 	const struct nf_conntrack_tuple_hash *h;
@@ -155,7 +156,10 @@ icmp_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &innertuple);
+	dev = skb->dev;
+	if (!dev)
+		dev = skb->dst->dev;
+	h = nf_conntrack_find_get(dev_net(dev), &innertuple);
 	if (!h) {
 		pr_debug("icmp_error_message: no match\n");
 		return -NF_ACCEPT;
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -127,6 +127,7 @@ icmpv6_error_message(struct sk_buff *skb,
 		     enum ip_conntrack_info *ctinfo,
 		     unsigned int hooknum)
 {
+	struct net_device *dev;
 	struct nf_conntrack_tuple intuple, origtuple;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_l4proto *inproto;
@@ -156,7 +157,10 @@ icmpv6_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &intuple);
+	dev = skb->dev;
+	if (!dev)
+		dev = skb->dst->dev;
+	h = nf_conntrack_find_get(dev_net(dev), &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
-- 
1.5.4.5


