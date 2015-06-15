From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/32] netfilter: ipset: Check extensions attributes before getting extensions.
Date: Mon, 15 Jun 2015 23:26:12 +0200
Message-ID: <1434403589-24796-16-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

Make all extensions attributes checks within ip_set_get_extensions()
and reduce number of duplicated code.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    8 +-------
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    8 +-------
 net/netfilter/ipset/ip_set_bitmap_port.c     |    8 +-------
 net/netfilter/ipset/ip_set_core.c            |    9 +++++++++
 net/netfilter/ipset/ip_set_hash_ip.c         |   14 +-------------
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   14 +-------------
 net/netfilter/ipset/ip_set_hash_ipport.c     |   14 +-------------
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   14 +-------------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   14 +-------------
 net/netfilter/ipset/ip_set_hash_mac.c        |    8 +-------
 net/netfilter/ipset/ip_set_hash_net.c        |   16 ++--------------
 net/netfilter/ipset/ip_set_hash_netiface.c   |   16 ++--------------
 net/netfilter/ipset/ip_set_hash_netnet.c     |   16 ++--------------
 net/netfilter/ipset/ip_set_hash_netport.c    |   16 ++--------------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   16 ++--------------
 net/netfilter/ipset/ip_set_list_set.c        |    8 +-------
 16 files changed, 29 insertions(+), 170 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 2fe6de4..212005e 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -138,13 +138,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+	if (unlikely(!tb[IPSET_ATTR_IP]))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index eb18856..0648e74 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -239,13 +239,7 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip = 0;
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+	if (unlikely(!tb[IPSET_ATTR_IP]))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 898edb6..10ed264 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -137,13 +137,7 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret = 0;
 
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 347d97a..68ae551 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -389,6 +389,15 @@ ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 		      struct ip_set_ext *ext)
 {
 	u64 fullmark;
+
+	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		return -IPSET_ERR_PROTOCOL;
+
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!SET_WITH_TIMEOUT(set))
 			return -IPSET_ERR_TIMEOUT;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 54df48b..0d955a4 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -108,13 +108,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip = 0, ip_to = 0, hosts;
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+	if (unlikely(!tb[IPSET_ATTR_IP]))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -247,12 +241,6 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index d231248..f4e14ec 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -109,13 +109,7 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -242,12 +236,6 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index a47c29f..02d9dba 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -118,13 +118,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -282,12 +276,6 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 89615f1..4e3b1c3 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -121,13 +121,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -293,12 +287,6 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 6ba7a7e..988567e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -176,13 +176,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -429,13 +423,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index 1f8668d..0d49519 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -107,13 +107,7 @@ hash_mac4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
-	if (unlikely(!tb[IPSET_ATTR_ETHER] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+	if (unlikely(!tb[IPSET_ATTR_ETHER]))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 2e63dad..5eb334d 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -147,13 +147,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -319,13 +313,7 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index fe481f6..5eef6f3 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -295,13 +295,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -531,13 +525,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 8470474..775b1b0 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -169,13 +169,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -400,13 +394,7 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 8273819..0eb73da 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -169,13 +169,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -387,13 +381,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 1451a8a..c3634ad 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -187,13 +187,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -463,13 +457,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 5bd3b1e..7d1377d 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -384,13 +384,7 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_NAME] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
-- 
1.7.10.4

