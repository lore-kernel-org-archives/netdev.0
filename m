From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/21] netfilter: ipset: Preprocessor directices cleanup
Date: Mon, 18 May 2015 18:25:09 +0200
Message-ID: <1431966324-4494-7-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

 * Undefine mtype_data_reset_elem before defining.

 * Remove duplicated mtype_gc_init undefine, move
   mtype_gc_init define closer to mtype_gc define.

 * Use htype instead of HTYPE in IPSET_TOKEN(HTYPE, _create)().

 * Remove PF definition from sets: no more used.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h        |    7 ++++---
 net/netfilter/ipset/ip_set_hash_ip.c         |    3 ---
 net/netfilter/ipset/ip_set_hash_ipmark.c     |    3 ---
 net/netfilter/ipset/ip_set_hash_ipport.c     |    3 ---
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    3 ---
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    3 ---
 net/netfilter/ipset/ip_set_hash_mac.c        |    1 -
 net/netfilter/ipset/ip_set_hash_net.c        |    3 ---
 net/netfilter/ipset/ip_set_hash_netiface.c   |    3 ---
 net/netfilter/ipset/ip_set_hash_netnet.c     |    3 ---
 net/netfilter/ipset/ip_set_hash_netport.c    |    3 ---
 net/netfilter/ipset/ip_set_hash_netportnet.c |    3 ---
 12 files changed, 4 insertions(+), 34 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 974ff38..a043065 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -180,6 +180,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #undef mtype_data_equal
 #undef mtype_do_data_match
 #undef mtype_data_set_flags
+#undef mtype_data_reset_elem
 #undef mtype_data_reset_flags
 #undef mtype_data_netmask
 #undef mtype_data_list
@@ -193,7 +194,6 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #undef mtype_ahash_memsize
 #undef mtype_flush
 #undef mtype_destroy
-#undef mtype_gc_init
 #undef mtype_same_set
 #undef mtype_kadt
 #undef mtype_uadt
@@ -227,6 +227,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_data_list		IPSET_TOKEN(MTYPE, _data_list)
 #define mtype_data_next		IPSET_TOKEN(MTYPE, _data_next)
 #define mtype_elem		IPSET_TOKEN(MTYPE, _elem)
+
 #define mtype_ahash_destroy	IPSET_TOKEN(MTYPE, _ahash_destroy)
 #define mtype_ext_cleanup	IPSET_TOKEN(MTYPE, _ext_cleanup)
 #define mtype_add_cidr		IPSET_TOKEN(MTYPE, _add_cidr)
@@ -234,7 +235,6 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_ahash_memsize	IPSET_TOKEN(MTYPE, _ahash_memsize)
 #define mtype_flush		IPSET_TOKEN(MTYPE, _flush)
 #define mtype_destroy		IPSET_TOKEN(MTYPE, _destroy)
-#define mtype_gc_init		IPSET_TOKEN(MTYPE, _gc_init)
 #define mtype_same_set		IPSET_TOKEN(MTYPE, _same_set)
 #define mtype_kadt		IPSET_TOKEN(MTYPE, _kadt)
 #define mtype_uadt		IPSET_TOKEN(MTYPE, _uadt)
@@ -249,6 +249,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_head		IPSET_TOKEN(MTYPE, _head)
 #define mtype_list		IPSET_TOKEN(MTYPE, _list)
 #define mtype_gc		IPSET_TOKEN(MTYPE, _gc)
+#define mtype_gc_init		IPSET_TOKEN(MTYPE, _gc_init)
 #define mtype_variant		IPSET_TOKEN(MTYPE, _variant)
 #define mtype_data_match	IPSET_TOKEN(MTYPE, _data_match)
 
@@ -1045,7 +1046,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	u8 netmask;
 #endif
 	size_t hsize;
-	struct HTYPE *h;
+	struct htype *h;
 	struct htable *t;
 
 #ifndef IP_SET_PROTO_UNDEF
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 76959d7..d21d1e6 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -74,7 +74,6 @@ hash_ip4_data_next(struct hash_ip4_elem *next, const struct hash_ip4_elem *e)
 }
 
 #define MTYPE		hash_ip4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -208,12 +207,10 @@ hash_ip6_data_next(struct hash_ip4_elem *next, const struct hash_ip6_elem *e)
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 #undef HKEY_DATALEN
 
 #define MTYPE		hash_ip6
-#define PF		6
 #define HOST_MASK	128
 
 #define IP_SET_EMIT_CREATE
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 2ec4ac5..e408bcf 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -77,7 +77,6 @@ hash_ipmark4_data_next(struct hash_ipmark4_elem *next,
 }
 
 #define MTYPE           hash_ipmark4
-#define PF              4
 #define HOST_MASK       32
 #define HKEY_DATALEN	sizeof(struct hash_ipmark4_elem)
 #include "ip_set_hash_gen.h"
@@ -204,12 +203,10 @@ hash_ipmark6_data_next(struct hash_ipmark4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 #undef HKEY_DATALEN
 
 #define MTYPE		hash_ipmark6
-#define PF		6
 #define HOST_MASK	128
 #define HKEY_DATALEN	sizeof(struct hash_ipmark6_elem)
 #define	IP_SET_EMIT_CREATE
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index dcbcceb..c4383ad 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -84,7 +84,6 @@ hash_ipport4_data_next(struct hash_ipport4_elem *next,
 }
 
 #define MTYPE           hash_ipport4
-#define PF              4
 #define HOST_MASK       32
 #define HKEY_DATALEN	sizeof(struct hash_ipport4_elem)
 #include "ip_set_hash_gen.h"
@@ -245,12 +244,10 @@ hash_ipport6_data_next(struct hash_ipport4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 #undef HKEY_DATALEN
 
 #define MTYPE		hash_ipport6
-#define PF		6
 #define HOST_MASK	128
 #define HKEY_DATALEN	sizeof(struct hash_ipport6_elem)
 #define	IP_SET_EMIT_CREATE
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 7ef93fc..c48ff45 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -86,7 +86,6 @@ hash_ipportip4_data_next(struct hash_ipportip4_elem *next,
 
 /* Common functions */
 #define MTYPE		hash_ipportip4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -254,11 +253,9 @@ hash_ipportip6_data_next(struct hash_ipportip4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_ipportip6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index b6012ad..adc3f76 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -130,7 +130,6 @@ hash_ipportnet4_data_next(struct hash_ipportnet4_elem *next,
 }
 
 #define MTYPE		hash_ipportnet4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -381,11 +380,9 @@ hash_ipportnet6_data_next(struct hash_ipportnet4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_ipportnet6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index 65690b5..2b96234 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -62,7 +62,6 @@ hash_mac4_data_next(struct hash_mac4_elem *next,
 }
 
 #define MTYPE		hash_mac4
-#define PF		4
 #define HOST_MASK	32
 #define IP_SET_EMIT_CREATE
 #define IP_SET_PROTO_UNDEF
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 6b3ac10..1abfe74 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -109,7 +109,6 @@ hash_net4_data_next(struct hash_net4_elem *next,
 }
 
 #define MTYPE		hash_net4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -277,11 +276,9 @@ hash_net6_data_next(struct hash_net4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_net6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 380ef51..0ba6c58 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -207,7 +207,6 @@ hash_netiface4_data_next(struct hash_netiface4_elem *next,
 }
 
 #define MTYPE		hash_netiface4
-#define PF		4
 #define HOST_MASK	32
 #define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
 #include "ip_set_hash_gen.h"
@@ -457,12 +456,10 @@ hash_netiface6_data_next(struct hash_netiface4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 #undef HKEY_DATALEN
 
 #define MTYPE		hash_netiface6
-#define PF		6
 #define HOST_MASK	128
 #define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
 #define IP_SET_EMIT_CREATE
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index ea8772a..9c6da0c 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -128,7 +128,6 @@ hash_netnet4_data_next(struct hash_netnet4_elem *next,
 }
 
 #define MTYPE		hash_netnet4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -354,11 +353,9 @@ hash_netnet6_data_next(struct hash_netnet4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_netnet6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index c0ddb58..f77afd4 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -125,7 +125,6 @@ hash_netport4_data_next(struct hash_netport4_elem *next,
 }
 
 #define MTYPE		hash_netport4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -340,11 +339,9 @@ hash_netport6_data_next(struct hash_netport4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_netport6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 7cfd2df..69e544f 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -139,7 +139,6 @@ hash_netportnet4_data_next(struct hash_netportnet4_elem *next,
 }
 
 #define MTYPE		hash_netportnet4
-#define PF		4
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
@@ -411,11 +410,9 @@ hash_netportnet6_data_next(struct hash_netportnet4_elem *next,
 }
 
 #undef MTYPE
-#undef PF
 #undef HOST_MASK
 
 #define MTYPE		hash_netportnet6
-#define PF		6
 #define HOST_MASK	128
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
-- 
1.7.10.4

