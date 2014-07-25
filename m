From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] net/netfilter/ipset: Resolve missing-field-initializer warnings
Date: Fri, 25 Jul 2014 02:18:31 -0700
Message-ID: <1406279911-6448-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36121 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbaGYJSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 05:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Resolve missing-field-initializer warnings by providing a
directed initializer.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c     | 4 ++--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c  | 4 ++--
 net/netfilter/ipset/ip_set_bitmap_port.c   | 4 ++--
 net/netfilter/ipset/ip_set_hash_ip.c       | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipport.c   | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipportip.c | 8 ++++----
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 6f1f9f4..dafdb39 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -112,7 +112,7 @@ bitmap_ip_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct bitmap_ip_adt_elem e = { };
+	struct bitmap_ip_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	u32 ip;
 
@@ -132,7 +132,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	u32 ip = 0, ip_to = 0;
-	struct bitmap_ip_adt_elem e = { };
+	struct bitmap_ip_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret = 0;
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 740eabe..dbad505 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -203,7 +203,7 @@ bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct bitmap_ipmac_adt_elem e = {};
+	struct bitmap_ipmac_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	u32 ip;
 
@@ -232,7 +232,7 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct bitmap_ipmac_adt_elem e = {};
+	struct bitmap_ipmac_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0;
 	int ret = 0;
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index cf99676..a4b65ae 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -104,7 +104,7 @@ bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct bitmap_port_adt_elem e = {};
+	struct bitmap_port_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	__be16 __port;
 	u16 port = 0;
@@ -129,7 +129,7 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct bitmap_port_adt_elem e = {};
+	struct bitmap_port_adt_elem e = { .id = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port;	/* wraparound */
 	u16 port_to;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index dd40607..e527399 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -84,7 +84,7 @@ hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ip4_elem e = {};
+	struct hash_ip4_elem e = { 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	__be32 ip;
 
@@ -103,7 +103,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ip4_elem e = {};
+	struct hash_ip4_elem e = { 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, hosts;
 	int ret = 0;
@@ -222,7 +222,7 @@ hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ip6_elem e = {};
+	struct hash_ip6_elem e = { { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
@@ -239,7 +239,7 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ip6_elem e = {};
+	struct hash_ip6_elem e = { { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 7597b82..f37a5ae 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -94,7 +94,7 @@ hash_ipport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport4_elem e = { };
+	struct hash_ipport4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
@@ -111,7 +111,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport4_elem e = { };
+	struct hash_ipport4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
@@ -258,7 +258,7 @@ hash_ipport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport6_elem e = { };
+	struct hash_ipport6_elem e = { .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
@@ -275,7 +275,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport6_elem e = { };
+	struct hash_ipport6_elem e = { .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 672655f..41ef00e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -95,7 +95,7 @@ hash_ipportip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip4_elem e = { };
+	struct hash_ipportip4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
@@ -113,7 +113,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip4_elem e = { };
+	struct hash_ipportip4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
@@ -265,7 +265,7 @@ hash_ipportip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip6_elem e = { };
+	struct hash_ipportip6_elem e = { .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
@@ -283,7 +283,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip6_elem e = { };
+	struct hash_ipportip6_elem e = {  .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
-- 
1.9.3
