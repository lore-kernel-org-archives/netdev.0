From: pablo@netfilter.org
Subject: [PATCH 10/16] netfilter: ipset: Include supported revisions in module description
Date: Mon, 24 Sep 2012 21:19:22 +0200
Message-ID: <1348514369-3272-11-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    6 ++++++
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    9 ++++++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    9 ++++++---
 net/netfilter/ipset/ip_set_bitmap_port.c    |    9 ++++++---
 net/netfilter/ipset/ip_set_hash_ip.c        |    9 ++++++---
 net/netfilter/ipset/ip_set_hash_ipport.c    |    9 ++++++---
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    9 ++++++---
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   13 ++++++++-----
 net/netfilter/ipset/ip_set_hash_net.c       |   11 +++++++----
 net/netfilter/ipset/ip_set_hash_netiface.c  |   11 +++++++----
 net/netfilter/ipset/ip_set_hash_netport.c   |   13 ++++++++-----
 net/netfilter/ipset/ip_set_list_set.c       |    9 ++++++---
 12 files changed, 78 insertions(+), 39 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 2edc64c..1d954c6 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -206,9 +206,15 @@ enum ip_set_kopt {
 #include <linux/netlink.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter/x_tables.h>
+#include <linux/stringify.h>
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 
+#define _IP_SET_MODULE_DESC(a, b, c)		\
+	MODULE_DESCRIPTION(a " type of IP sets, revisions " b "-" c)
+#define IP_SET_MODULE_DESC(a, b, c)		\
+	_IP_SET_MODULE_DESC(a, __stringify(b), __stringify(c))
+
 /* Set features */
 enum ip_set_feature {
 	IPSET_TYPE_IP_FLAG = 0,
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 02184b5..4a92fd4 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -27,9 +27,12 @@
 #define IP_SET_BITMAP_TIMEOUT
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	0
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("bitmap:ip type of IP sets");
+IP_SET_MODULE_DESC("bitmap:ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip");
 
 /* Type structure */
@@ -556,8 +559,8 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_IPV4,
-	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= bitmap_ip_create,
 	.create_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 6819d3c..645c9d1 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -26,9 +26,12 @@
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	0
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("bitmap:ip,mac type of IP sets");
+IP_SET_MODULE_DESC("bitmap:ip,mac", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip,mac");
 
 enum {
@@ -630,8 +633,8 @@ static struct ip_set_type bitmap_ipmac_type = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_MAC,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_IPV4,
-	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= bitmap_ipmac_create,
 	.create_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index b9f1fce..e6b2db7 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -22,9 +22,12 @@
 #define IP_SET_BITMAP_TIMEOUT
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	0
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("bitmap:port type of IP sets");
+IP_SET_MODULE_DESC("bitmap:port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:port");
 
 /* Type structure */
@@ -487,8 +490,8 @@ static struct ip_set_type bitmap_port_type = {
 	.features	= IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= bitmap_port_create,
 	.create_policy	= {
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index bc8f76e..ec3dba5 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -24,9 +24,12 @@
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	0
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:ip type of IP sets");
+IP_SET_MODULE_DESC("hash:ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip");
 
 /* Type specific function prefix */
@@ -452,8 +455,8 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_ip_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 6760fd4..0171f75 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -25,9 +25,12 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	1 /* SCTP and UDPLITE support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:ip,port type of IP sets");
+IP_SET_MODULE_DESC("hash:ip,port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port");
 
 /* Type specific function prefix */
@@ -523,8 +526,8 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	.revision_max	= 1,	/* SCTP and UDPLITE support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_ipport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index ac09bec..6344ef5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -25,9 +25,12 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	1 /* SCTP and UDPLITE support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:ip,port,ip type of IP sets");
+IP_SET_MODULE_DESC("hash:ip,port,ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port,ip");
 
 /* Type specific function prefix */
@@ -541,8 +544,8 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	.revision_max	= 1,	/* SCTP and UDPLITE support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_ipportip_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 242814e..8ee9168 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -25,9 +25,14 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+/*			1    SCTP and UDPLITE support added */
+/*			2    Range as input support for IPv4 added */
+#define REVISION_MAX	3 /* nomatch flag support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:ip,port,net type of IP sets");
+IP_SET_MODULE_DESC("hash:ip,port,net", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port,net");
 
 /* Type specific function prefix */
@@ -695,10 +700,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	/*		  1	   SCTP and UDPLITE support added */
-	/*		  2	   Range as input support for IPv4 added */
-	.revision_max	= 3,	/* nomatch flag support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_ipportnet_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index d676093..014ff72 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -23,9 +23,13 @@
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+/*			1    Range as input support for IPv4 added */
+#define REVISION_MAX	2 /* nomatch flag support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:net type of IP sets");
+IP_SET_MODULE_DESC("hash:net", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:net");
 
 /* Type specific function prefix */
@@ -535,9 +539,8 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	/*		= 1 	   Range as input support for IPv4 added */
-	.revision_max	= 2,	/* nomatch flag support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_net_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index e7c671d..a5c8491 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -24,9 +24,13 @@
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+/*			1    nomatch flag support added */
+#define REVISION_MAX	2 /* /0 support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:net,iface type of IP sets");
+IP_SET_MODULE_DESC("hash:net,iface", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:net,iface");
 
 /* Interface name rbtree */
@@ -773,9 +777,8 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_IFACE,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	/*		= 1,	   nomatch flag support added */
-	.revision_max	= 2,	/* /0 support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_netiface_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 3ec27fc..7ca357a 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -24,9 +24,14 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
+#define REVISION_MIN	0
+/*			1    SCTP and UDPLITE support added */
+/*			2    Range as input support for IPv4 added */
+#define REVISION_MAX	3 /* nomatch flag support added */
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("hash:net,port type of IP sets");
+IP_SET_MODULE_DESC("hash:net,port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:net,port");
 
 /* Type specific function prefix */
@@ -648,10 +653,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	/*		  1	   SCTP and UDPLITE support added */
-	/*		  2,	   Range as input support for IPv4 added */
-	.revision_max	= 3,	/* nomatch flag support added */
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= hash_netport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 6cb1225..8371c2b 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -16,9 +16,12 @@
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_list.h>
 
+#define REVISION_MIN	0
+#define REVISION_MAX	0
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-MODULE_DESCRIPTION("list:set type of IP sets");
+IP_SET_MODULE_DESC("list:set", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_list:set");
 
 /* Member elements without and with timeout */
@@ -579,8 +582,8 @@ static struct ip_set_type list_set_type __read_mostly = {
 	.features	= IPSET_TYPE_NAME | IPSET_DUMP_LAST,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
-	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_min	= REVISION_MIN,
+	.revision_max	= REVISION_MAX,
 	.create		= list_set_create,
 	.create_policy	= {
 		[IPSET_ATTR_SIZE]	= { .type = NLA_U32 },
-- 
1.7.10.4

