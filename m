From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/21] netfilter: ipset: Improve preprocessor macros checks
Date: Mon, 18 May 2015 18:25:17 +0200
Message-ID: <1431966324-4494-15-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

Check if mandatory MTYPE, HTYPE and HOST_MASK macros
defined.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h    |   13 ++++++++++++-
 net/netfilter/ipset/ip_set_hash_ipmark.c |    6 +++---
 net/netfilter/ipset/ip_set_hash_ipport.c |    6 +++---
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 7b72209..7952869 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -253,6 +253,14 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_variant		IPSET_TOKEN(MTYPE, _variant)
 #define mtype_data_match	IPSET_TOKEN(MTYPE, _data_match)
 
+#ifndef MTYPE
+#error "MTYPE is not defined!"
+#endif
+
+#ifndef HOST_MASK
+#error "HOST_MASK is not defined!"
+#endif
+
 #ifndef HKEY_DATALEN
 #define HKEY_DATALEN		sizeof(struct mtype_elem)
 #endif
@@ -262,6 +270,9 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 	& jhash_mask(htable_bits))
 
 #ifndef htype
+#ifndef HTYPE
+#error "HTYPE is not defined!"
+#endif /* HTYPE */
 #define htype			HTYPE
 
 /* The generic hash structure */
@@ -288,7 +299,7 @@ struct htype {
 	struct net_prefixes nets[0]; /* book-keeping of prefixes */
 #endif
 };
-#endif
+#endif /* htype */
 
 #ifdef IP_SET_HASH_WITH_NETS
 /* Network cidr size book keeping when the hash stores different
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 061e7e8..d231248 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -76,8 +76,8 @@ hash_ipmark4_data_next(struct hash_ipmark4_elem *next,
 	next->ip = d->ip;
 }
 
-#define MTYPE           hash_ipmark4
-#define HOST_MASK       32
+#define MTYPE		hash_ipmark4
+#define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
 static int
@@ -209,7 +209,7 @@ hash_ipmark6_data_next(struct hash_ipmark4_elem *next,
 
 #define MTYPE		hash_ipmark6
 #define HOST_MASK	128
-#define	IP_SET_EMIT_CREATE
+#define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index e58704e..a47c29f 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -83,8 +83,8 @@ hash_ipport4_data_next(struct hash_ipport4_elem *next,
 	next->port = d->port;
 }
 
-#define MTYPE           hash_ipport4
-#define HOST_MASK       32
+#define MTYPE		hash_ipport4
+#define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
 static int
@@ -247,7 +247,7 @@ hash_ipport6_data_next(struct hash_ipport4_elem *next,
 
 #define MTYPE		hash_ipport6
 #define HOST_MASK	128
-#define	IP_SET_EMIT_CREATE
+#define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
 static int
-- 
1.7.10.4

