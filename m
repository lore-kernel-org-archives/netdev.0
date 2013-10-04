From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/33] netfilter: ipset: Rename extension offset ids to extension ids
Date: Fri,  4 Oct 2013 10:32:59 +0200
Message-ID: <1380875598-5250-15-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h    |   16 ++++++++--------
 net/netfilter/ipset/ip_set_bitmap_gen.h   |    4 ++--
 net/netfilter/ipset/ip_set_bitmap_ip.c    |   10 +++++-----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |   10 +++++-----
 net/netfilter/ipset/ip_set_bitmap_port.c  |   10 +++++-----
 net/netfilter/ipset/ip_set_hash_gen.h     |   22 +++++++++++-----------
 net/netfilter/ipset/ip_set_list_set.c     |   14 +++++++-------
 7 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 56012a3..b4db791 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -56,20 +56,20 @@ enum ip_set_extension {
 	IPSET_EXT_COUNTER = (1 << IPSET_EXT_BIT_COUNTER),
 };
 
-/* Extension offsets */
-enum ip_set_offset {
-	IPSET_OFFSET_TIMEOUT = 0,
-	IPSET_OFFSET_COUNTER,
-	IPSET_OFFSET_MAX,
-};
-
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
 #define SET_WITH_COUNTER(s)	((s)->extensions & IPSET_EXT_COUNTER)
 
+/* Extension id, in size order */
+enum ip_set_ext_id {
+	IPSET_EXT_ID_COUNTER = 0,
+	IPSET_EXT_ID_TIMEOUT,
+	IPSET_EXT_ID_MAX,
+};
+
 struct ip_set_ext {
-	u32 timeout;
 	u64 packets;
 	u64 bytes;
+	u32 timeout;
 };
 
 struct ip_set;
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index d39905e..889a929 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -33,9 +33,9 @@
 #define mtype			MTYPE
 
 #define ext_timeout(e, m)	\
-	(unsigned long *)((e) + (m)->offset[IPSET_OFFSET_TIMEOUT])
+	(unsigned long *)((e) + (m)->offset[IPSET_EXT_ID_TIMEOUT])
 #define ext_counter(e, m)	\
-	(struct ip_set_counter *)((e) + (m)->offset[IPSET_OFFSET_COUNTER])
+	(struct ip_set_counter *)((e) + (m)->offset[IPSET_EXT_ID_COUNTER])
 #define get_ext(map, id)	((map)->extensions + (map)->dsize * (id))
 
 static void
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index ce99d26..2ee210e 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -45,7 +45,7 @@ struct bitmap_ip {
 	u32 hosts;		/* number of hosts in a subnet */
 	size_t memsize;		/* members size */
 	size_t dsize;		/* extensions struct size */
-	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
+	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	u8 netmask;		/* subnet netmask */
 	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
@@ -342,9 +342,9 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
 			map->dsize = sizeof(struct bitmap_ipct_elem);
-			map->offset[IPSET_OFFSET_TIMEOUT] =
+			map->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_ipct_elem, timeout);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipct_elem, counter);
 
 			if (!init_map_ip(set, map, first_ip, last_ip,
@@ -360,7 +360,7 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			bitmap_ip_gc_init(set, bitmap_ip_gc);
 		} else {
 			map->dsize = sizeof(struct bitmap_ipc_elem);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipc_elem, counter);
 
 			if (!init_map_ip(set, map, first_ip, last_ip,
@@ -371,7 +371,7 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_ipt_elem);
-		map->offset[IPSET_OFFSET_TIMEOUT] =
+		map->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_ipt_elem, timeout);
 
 		if (!init_map_ip(set, map, first_ip, last_ip,
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 6d5bad9..e711875 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -52,7 +52,7 @@ struct bitmap_ipmac {
 	struct timer_list gc;	/* garbage collector */
 	size_t memsize;		/* members size */
 	size_t dsize;		/* size of element */
-	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
+	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 };
 
 /* ADT structure for generic function args */
@@ -405,9 +405,9 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
 			map->dsize = sizeof(struct bitmap_ipmacct_elem);
-			map->offset[IPSET_OFFSET_TIMEOUT] =
+			map->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_ipmacct_elem, timeout);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipmacct_elem, counter);
 
 			if (!init_map_ipmac(set, map, first_ip, last_ip,
@@ -421,7 +421,7 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 			bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
 		} else {
 			map->dsize = sizeof(struct bitmap_ipmacc_elem);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipmacc_elem, counter);
 
 			if (!init_map_ipmac(set, map, first_ip, last_ip,
@@ -432,7 +432,7 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_ipmact_elem);
-		map->offset[IPSET_OFFSET_TIMEOUT] =
+		map->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_ipmact_elem, timeout);
 
 		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index b220489..bebc137 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -39,7 +39,7 @@ struct bitmap_port {
 	u32 elements;		/* number of max elements in the set */
 	size_t memsize;		/* members size */
 	size_t dsize;		/* extensions struct size */
-	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
+	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
 };
@@ -282,9 +282,9 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
 			map->dsize = sizeof(struct bitmap_portct_elem);
-			map->offset[IPSET_OFFSET_TIMEOUT] =
+			map->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_portct_elem, timeout);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_portct_elem, counter);
 			if (!init_map_port(set, map, first_port, last_port)) {
 				kfree(map);
@@ -297,7 +297,7 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			bitmap_port_gc_init(set, bitmap_port_gc);
 		} else {
 			map->dsize = sizeof(struct bitmap_portc_elem);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_portc_elem, counter);
 			if (!init_map_port(set, map, first_port, last_port)) {
 				kfree(map);
@@ -306,7 +306,7 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_portt_elem);
-		map->offset[IPSET_OFFSET_TIMEOUT] =
+		map->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_portt_elem, timeout);
 		if (!init_map_port(set, map, first_port, last_port)) {
 			kfree(map);
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index a833240..e4db925 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -179,9 +179,9 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #endif /* IP_SET_HASH_WITH_NETS */
 
 #define ext_timeout(e, h)	\
-(unsigned long *)(((void *)(e)) + (h)->offset[IPSET_OFFSET_TIMEOUT])
+(unsigned long *)(((void *)(e)) + (h)->offset[IPSET_EXT_ID_TIMEOUT])
 #define ext_counter(e, h)	\
-(struct ip_set_counter *)(((void *)(e)) + (h)->offset[IPSET_OFFSET_COUNTER])
+(struct ip_set_counter *)(((void *)(e)) + (h)->offset[IPSET_EXT_ID_COUNTER])
 
 #endif /* _IP_SET_HASH_GEN_H */
 
@@ -278,7 +278,7 @@ struct htype {
 	u32 initval;		/* random jhash init value */
 	u32 timeout;		/* timeout value, if enabled */
 	size_t dsize;		/* data struct size */
-	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
+	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	struct timer_list gc;	/* garbage collection when timeout enabled */
 	struct mtype_elem next; /* temporary storage for uadd */
 #ifdef IP_SET_HASH_WITH_MULTI
@@ -1059,11 +1059,11 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			if (set->family == NFPROTO_IPV4) {
 				h->dsize = sizeof(struct
 					IPSET_TOKEN(HTYPE, 4ct_elem));
-				h->offset[IPSET_OFFSET_TIMEOUT] =
+				h->offset[IPSET_EXT_ID_TIMEOUT] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4ct_elem),
 						timeout);
-				h->offset[IPSET_OFFSET_COUNTER] =
+				h->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4ct_elem),
 						counter);
@@ -1072,11 +1072,11 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			} else {
 				h->dsize = sizeof(struct
 					IPSET_TOKEN(HTYPE, 6ct_elem));
-				h->offset[IPSET_OFFSET_TIMEOUT] =
+				h->offset[IPSET_EXT_ID_TIMEOUT] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6ct_elem),
 						timeout);
-				h->offset[IPSET_OFFSET_COUNTER] =
+				h->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6ct_elem),
 						counter);
@@ -1088,7 +1088,7 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 				h->dsize =
 					sizeof(struct
 						IPSET_TOKEN(HTYPE, 4c_elem));
-				h->offset[IPSET_OFFSET_COUNTER] =
+				h->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4c_elem),
 						counter);
@@ -1096,7 +1096,7 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 				h->dsize =
 					sizeof(struct
 						IPSET_TOKEN(HTYPE, 6c_elem));
-				h->offset[IPSET_OFFSET_COUNTER] =
+				h->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6c_elem),
 						counter);
@@ -1107,14 +1107,14 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		set->extensions |= IPSET_EXT_TIMEOUT;
 		if (set->family == NFPROTO_IPV4) {
 			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4t_elem));
-			h->offset[IPSET_OFFSET_TIMEOUT] =
+			h->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct IPSET_TOKEN(HTYPE, 4t_elem),
 					 timeout);
 			IPSET_TOKEN(HTYPE, 4_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 4_gc));
 		} else {
 			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6t_elem));
-			h->offset[IPSET_OFFSET_TIMEOUT] =
+			h->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct IPSET_TOKEN(HTYPE, 6t_elem),
 					 timeout);
 			IPSET_TOKEN(HTYPE, 6_gc_init)(set,
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index a9e301f..0ed19b5 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -59,7 +59,7 @@ struct set_adt_elem {
 /* Type structure */
 struct list_set {
 	size_t dsize;		/* element size */
-	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
+	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	u32 size;		/* size of set list array */
 	u32 timeout;		/* timeout value */
 	struct timer_list gc;	/* garbage collection */
@@ -73,9 +73,9 @@ list_set_elem(const struct list_set *map, u32 id)
 }
 
 #define ext_timeout(e, m)	\
-(unsigned long *)((void *)(e) + (m)->offset[IPSET_OFFSET_TIMEOUT])
+(unsigned long *)((void *)(e) + (m)->offset[IPSET_EXT_ID_TIMEOUT])
 #define ext_counter(e, m)	\
-(struct ip_set_counter *)((void *)(e) + (m)->offset[IPSET_OFFSET_COUNTER])
+(struct ip_set_counter *)((void *)(e) + (m)->offset[IPSET_EXT_ID_COUNTER])
 
 static int
 list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
@@ -667,9 +667,9 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			if (!map)
 				return -ENOMEM;
 			set->extensions |= IPSET_EXT_TIMEOUT;
-			map->offset[IPSET_OFFSET_TIMEOUT] =
+			map->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct setct_elem, timeout);
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct setct_elem, counter);
 			list_set_gc_init(set, list_set_gc);
 		} else {
@@ -677,7 +677,7 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 					    sizeof(struct setc_elem), 0);
 			if (!map)
 				return -ENOMEM;
-			map->offset[IPSET_OFFSET_COUNTER] =
+			map->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct setc_elem, counter);
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
@@ -686,7 +686,7 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		if (!map)
 			return -ENOMEM;
 		set->extensions |= IPSET_EXT_TIMEOUT;
-		map->offset[IPSET_OFFSET_TIMEOUT] =
+		map->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct sett_elem, timeout);
 		list_set_gc_init(set, list_set_gc);
 	} else {
-- 
1.7.10.4

