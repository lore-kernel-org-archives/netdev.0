From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/21] netfilter: ipset: Use HOST_MASK literal to represent host address CIDR len
Date: Mon, 18 May 2015 18:25:12 +0200
Message-ID: <1431966324-4494-10-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    7 ++++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    3 ++-
 net/netfilter/ipset/ip_set_hash_ip.c        |    2 +-
 net/netfilter/ipset/ip_set_hash_ipmark.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    2 +-
 7 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 306a1bf..01b88ba 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -36,6 +36,7 @@ IP_SET_MODULE_DESC("bitmap:ip", IPSET_TYPE_REV_MIN, IPSET_TYPE_REV_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip");
 
 #define MTYPE		bitmap_ip
+#define HOST_MASK	32
 
 /* Type structure */
 struct bitmap_ip {
@@ -177,7 +178,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	} else
@@ -280,7 +281,7 @@ bitmap_ip_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr >= 32)
+		if (cidr >= HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(first_ip, last_ip, cidr);
 	} else
@@ -289,7 +290,7 @@ bitmap_ip_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_NETMASK]) {
 		netmask = nla_get_u8(tb[IPSET_ATTR_NETMASK]);
 
-		if (netmask > 32)
+		if (netmask > HOST_MASK)
 			return -IPSET_ERR_INVALID_NETMASK;
 
 		first_ip &= ip_set_hostmask(netmask);
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index c5f6a06..46868b3 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -36,6 +36,7 @@ IP_SET_MODULE_DESC("bitmap:ip,mac", IPSET_TYPE_REV_MIN, IPSET_TYPE_REV_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip,mac");
 
 #define MTYPE		bitmap_ipmac
+#define HOST_MASK	32
 #define IP_SET_BITMAP_STORED_TIMEOUT
 
 enum {
@@ -346,7 +347,7 @@ bitmap_ipmac_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (cidr >= 32)
+		if (cidr >= HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(first_ip, last_ip, cidr);
 	} else
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 1c469df..1a9ef0c 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -147,7 +147,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 82ef5b3..4499373 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -149,7 +149,7 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 299fab6..4ae423c 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -170,7 +170,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index cb79466..fb921a5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -176,7 +176,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2c39cae..4ae9804 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -248,7 +248,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else if (tb[IPSET_ATTR_CIDR]) {
 		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-		if (!cidr || cidr > 32)
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
-- 
1.7.10.4

