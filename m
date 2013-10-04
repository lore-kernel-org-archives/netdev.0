From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/33] netfilter: ipset: Fix "may be used uninitialized" warnings
Date: Fri,  4 Oct 2013 10:32:53 +0200
Message-ID: <1380875598-5250-9-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Reported-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    4 ++--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    4 ++--
 net/netfilter/ipset/ip_set_hash_ip.c        |    2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 ++--
 net/netfilter/ipset/ip_set_hash_net.c       |    2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_netport.c   |    2 +-
 9 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index c2f89b1..ce99d26 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -131,7 +131,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	u32 ip, ip_to;
+	u32 ip = 0, ip_to = 0;
 	struct bitmap_ip_adt_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
 	int ret = 0;
@@ -264,7 +264,7 @@ static int
 bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_ip *map;
-	u32 first_ip, last_ip, hosts, cadt_flags = 0;
+	u32 first_ip = 0, last_ip = 0, hosts, cadt_flags = 0;
 	u64 elements;
 	u8 netmask = 32;
 	int ret;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 1d6551c..6d5bad9 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -246,7 +246,7 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_ipmac_adt_elem e = {};
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
-	u32 ip;
+	u32 ip = 0;
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -355,7 +355,7 @@ static int
 bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		    u32 flags)
 {
-	u32 first_ip, last_ip, cadt_flags = 0;
+	u32 first_ip = 0, last_ip = 0, cadt_flags = 0;
 	u64 elements;
 	struct bitmap_ipmac *map;
 	int ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index de44fca..260c9a8 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -119,7 +119,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip4_elem e = {};
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip, ip_to, hosts;
+	u32 ip = 0, ip_to = 0, hosts;
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index b514ff4..64caad3 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -137,7 +137,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip, ip_to, p = 0, port, port_to;
+	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
 	int ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index d05070d..2873bbc 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -142,7 +142,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip, ip_to, p = 0, port, port_to;
+	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
 	int ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 7d1dede..f111558 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -196,8 +196,8 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem e = { .cidr = HOST_MASK - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip, ip_to, p = 0, port, port_to;
-	u32 ip2_from, ip2_to, ip2_last, ip2;
+	u32 ip = 0, ip_to = 0, p = 0, port, port_to;
+	u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 9cb9ef4..0a64dad 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -166,7 +166,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem e = { .cidr = HOST_MASK };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip = 0, ip_to, last;
+	u32 ip = 0, ip_to = 0, last;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 2310fc2..846371b 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -320,7 +320,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem e = { .cidr = HOST_MASK, .elem = 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 ip = 0, ip_to, last;
+	u32 ip = 0, ip_to = 0, last;
 	char iface[IFNAMSIZ];
 	int ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 1601d48..d98a685 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -187,7 +187,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem e = { .cidr = HOST_MASK - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
-	u32 port, port_to, p = 0, ip = 0, ip_to, last;
+	u32 port, port_to, p = 0, ip = 0, ip_to = 0, last;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
-- 
1.7.10.4

