From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 08/22] mpls: export mpls functions for use by mpls iptunnels
Date: Fri, 17 Jul 2015 14:55:27 +0200
Message-ID: <f246c34c65e1f66d6fcab7571f1b83e93764c64b.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49471 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757963AbbGQMz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:55:56 -0400
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  | 11 ++++++++---
 net/mpls/internal.h |  9 +++++++--
 2 files changed, 15 insertions(+), 5 deletions(-)

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
index 8cabeb5..2681a4b 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -50,7 +50,12 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 	return result;
 }
 
-int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
-int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
+int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
+		   const u32 label[]);
+int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels,
+		   u32 label[]);
+bool mpls_output_possible(const struct net_device *dev);
+unsigned int mpls_dev_mtu(const struct net_device *dev);
+bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
 
 #endif /* MPLS_INTERNAL_H */
-- 
2.4.3
