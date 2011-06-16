From: kaber@trash.net
Subject: [PATCH 18/20] netfilter: ipset: use the stored first cidr value instead of '1'
Date: Thu, 16 Jun 2011 21:47:18 +0200
Message-ID: <1308253640-29942-19-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64145 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237Ab1FPTr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:47:28 -0400
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   10 ++++++----
 net/netfilter/ipset/ip_set_hash_net.c       |    8 ++++++--
 net/netfilter/ipset/ip_set_hash_netport.c   |    6 ++++--
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index dcd351b..d2d6ab8 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -156,8 +156,9 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet4_elem data =
-		{ .cidr = h->nets[0].cidr || HOST_MASK };
+	struct hash_ipportnet4_elem data = {
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
@@ -434,8 +435,9 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet6_elem data =
-		{ .cidr = h->nets[0].cidr || HOST_MASK };
+	struct hash_ipportnet6_elem data = {
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index dcbb5d4..050163f 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -139,7 +139,9 @@ hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net4_elem data = { .cidr = h->nets[0].cidr || HOST_MASK };
+	struct hash_net4_elem data = {
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
@@ -336,7 +338,9 @@ hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net6_elem data = { .cidr = h->nets[0].cidr || HOST_MASK };
+	struct hash_net6_elem data = {
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 72961ba..d7710a9 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -153,7 +153,8 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem data = {
-		.cidr = h->nets[0].cidr || HOST_MASK };
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
@@ -397,7 +398,8 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem data = {
-		.cidr = h->nets[0].cidr || HOST_MASK };
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+	};
 
 	if (data.cidr == 0)
 		return -EINVAL;
-- 
1.7.2.3

