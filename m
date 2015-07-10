From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 08/22] mpls: export mpls functions for use by mpls iptunnels
Date: Fri, 10 Jul 2015 16:19:10 +0200
Message-ID: <266c145ee8234600a60e8c3398c23916a87cc2b9.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40568 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676AbbGJOTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:39 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  | 11 ++++++++---
 net/mpls/internal.h |  3 +++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1f93a59..6e66911 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -58,10 +58,11 @@ static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
 	return rcu_dereference_rtnl(dev->mpls_ptr);
 }
 
-static bool mpls_output_possible(const struct net_device *dev)
+bool mpls_output_possible(const struct net_device *dev)
 {
 	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
 }
+EXPORT_SYMBOL_GPL(mpls_output_possible);
 
 static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
 {
@@ -69,13 +70,14 @@ static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
 	return rt->rt_labels * sizeof(struct mpls_shim_hdr);
 }
 
-static unsigned int mpls_dev_mtu(const struct net_device *dev)
+unsigned int mpls_dev_mtu(const struct net_device *dev)
 {
 	/* The amount of data the layer 2 frame can hold */
 	return dev->mtu;
 }
+EXPORT_SYMBOL_GPL(mpls_dev_mtu);
 
-static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
+bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 {
 	if (skb->len <= mtu)
 		return false;
@@ -85,6 +87,7 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 
 	return true;
 }
+EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 			struct mpls_entry_decoded dec)
@@ -626,6 +629,7 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nla_put_labels);
 
 int nla_get_labels(const struct nlattr *nla,
 		   u32 max_labels, u32 *labels, u32 label[])
@@ -671,6 +675,7 @@ int nla_get_labels(const struct nlattr *nla,
 	*labels = nla_labels;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nla_get_labels);
 
 static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			       struct mpls_route_config *cfg)
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 8cabeb5..8e3af1e 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -52,5 +52,8 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
+bool mpls_output_possible(const struct net_device *dev);
+unsigned int mpls_dev_mtu(const struct net_device *dev);
+bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
 
 #endif /* MPLS_INTERNAL_H */
-- 
2.4.3
