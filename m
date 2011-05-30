From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 07/17] batman-adv: Add const type qualifier
	for pointers
Date: Mon, 30 May 2011 09:22:52 +0200
Message-ID: <1306740182-2665-8-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1306740182-2665-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

batman-adv uses pointers which are marked as const and should not
violate that type qualifier by passing it to functions which force a
cast to the non-const version.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/aggregation.c       |   21 ++++++++++---------
 net/batman-adv/aggregation.h       |    5 ++-
 net/batman-adv/bat_debugfs.c       |    4 +-
 net/batman-adv/bat_sysfs.c         |   15 ++++++-------
 net/batman-adv/bitarray.c          |    4 +-
 net/batman-adv/bitarray.h          |    6 ++--
 net/batman-adv/gateway_client.c    |    4 +-
 net/batman-adv/hard-interface.c    |   19 +++++++++--------
 net/batman-adv/hard-interface.h    |    6 +++-
 net/batman-adv/hash.h              |    6 ++--
 net/batman-adv/main.c              |    4 +-
 net/batman-adv/main.h              |   10 +++++---
 net/batman-adv/originator.c        |    4 +-
 net/batman-adv/originator.h        |   14 ++++++------
 net/batman-adv/ring_buffer.c       |    4 +-
 net/batman-adv/ring_buffer.h       |    2 +-
 net/batman-adv/routing.c           |   39 ++++++++++++++++-------------------
 net/batman-adv/routing.h           |   12 +++++-----
 net/batman-adv/send.c              |   27 ++++++++++++------------
 net/batman-adv/send.h              |   12 +++++-----
 net/batman-adv/soft-interface.c    |    7 ++---
 net/batman-adv/soft-interface.h    |    4 +-
 net/batman-adv/translation-table.c |   35 +++++++++++++++++--------------
 net/batman-adv/translation-table.h |   13 ++++++-----
 net/batman-adv/unicast.c           |    4 +-
 net/batman-adv/unicast.h           |    6 ++--
 net/batman-adv/vis.c               |   36 +++++++++++++++++---------------
 27 files changed, 166 insertions(+), 157 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index a8c3203..f8ccb49b 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -26,18 +26,18 @@
 #include "hard-interface.h"
 
 /* calculate the size of the tt information for a given packet */
-static int tt_len(struct batman_packet *batman_packet)
+static int tt_len(const struct batman_packet *batman_packet)
 {
 	return batman_packet->num_tt * ETH_ALEN;
 }
 
 /* return true if new_packet can be aggregated with forw_packet */
-static bool can_aggregate_with(struct batman_packet *new_batman_packet,
+static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 			       int packet_len,
 			       unsigned long send_time,
 			       bool directlink,
-			       struct hard_iface *if_incoming,
-			       struct forw_packet *forw_packet)
+			       const struct hard_iface *if_incoming,
+			       const struct forw_packet *forw_packet)
 {
 	struct batman_packet *batman_packet =
 		(struct batman_packet *)forw_packet->skb->data;
@@ -97,8 +97,9 @@ static bool can_aggregate_with(struct batman_packet *new_batman_packet,
 }
 
 /* create a new aggregated packet and add this packet to it */
-static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
-				  unsigned long send_time, bool direct_link,
+static void new_aggregated_packet(const unsigned char *packet_buff,
+				  int packet_len, unsigned long send_time,
+				  bool direct_link,
 				  struct hard_iface *if_incoming,
 				  int own_packet)
 {
@@ -176,8 +177,7 @@ out:
 
 /* aggregate a new packet into the existing aggregation */
 static void aggregate(struct forw_packet *forw_packet_aggr,
-		      unsigned char *packet_buff,
-		      int packet_len,
+		      const unsigned char *packet_buff, int packet_len,
 		      bool direct_link)
 {
 	unsigned char *skb_buff;
@@ -253,8 +253,9 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 }
 
 /* unpack the aggregated packets and process them one by one */
-void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
-			     int packet_len, struct hard_iface *if_incoming)
+void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
+			     unsigned char *packet_buff, int packet_len,
+			     struct hard_iface *if_incoming)
 {
 	struct batman_packet *batman_packet;
 	int buff_pos = 0;
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 7e6d72f..fedeb8d 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -37,7 +37,8 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
 			    struct hard_iface *if_incoming, char own_packet,
 			    unsigned long send_time);
-void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
-			     int packet_len, struct hard_iface *if_incoming);
+void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
+			     unsigned char *packet_buff, int packet_len,
+			     struct hard_iface *if_incoming);
 
 #endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 628ab18..1049ae3 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -51,7 +51,7 @@ static void emit_log_char(struct debug_log *debug_log, char c)
 }
 
 __printf(2, 3)
-static int fdebug_log(struct debug_log *debug_log, char *fmt, ...)
+static int fdebug_log(struct debug_log *debug_log, const char *fmt, ...)
 {
 	va_list args;
 	static char debug_log_buf[256];
@@ -75,7 +75,7 @@ static int fdebug_log(struct debug_log *debug_log, char *fmt, ...)
 	return 0;
 }
 
-int debug_log(struct bat_priv *bat_priv, char *fmt, ...)
+int debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
 {
 	va_list args;
 	char tmp_log_buf[256];
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 497a070..6f70560 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -96,7 +96,7 @@ ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
 
 static int store_bool_attr(char *buff, size_t count,
 			   struct net_device *net_dev,
-			   char *attr_name, atomic_t *attr)
+			   const char *attr_name, atomic_t *attr)
 {
 	int enabled = -1;
 
@@ -138,16 +138,15 @@ static inline ssize_t __store_bool_attr(char *buff, size_t count,
 {
 	int ret;
 
-	ret = store_bool_attr(buff, count, net_dev, (char *)attr->name,
-			      attr_store);
+	ret = store_bool_attr(buff, count, net_dev, attr->name, attr_store);
 	if (post_func && ret)
 		post_func(net_dev);
 
 	return ret;
 }
 
-static int store_uint_attr(char *buff, size_t count,
-			   struct net_device *net_dev, char *attr_name,
+static int store_uint_attr(const char *buff, size_t count,
+			   struct net_device *net_dev, const char *attr_name,
 			   unsigned int min, unsigned int max, atomic_t *attr)
 {
 	unsigned long uint_val;
@@ -183,15 +182,15 @@ static int store_uint_attr(char *buff, size_t count,
 	return count;
 }
 
-static inline ssize_t __store_uint_attr(char *buff, size_t count,
+static inline ssize_t __store_uint_attr(const char *buff, size_t count,
 			int min, int max,
 			void (*post_func)(struct net_device *),
-			struct attribute *attr,
+			const struct attribute *attr,
 			atomic_t *attr_store, struct net_device *net_dev)
 {
 	int ret;
 
-	ret = store_uint_attr(buff, count, net_dev, (char *)attr->name,
+	ret = store_uint_attr(buff, count, net_dev, attr->name,
 			      min, max, attr_store);
 	if (post_func && ret)
 		post_func(net_dev);
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index ad2ca92..767e237 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -26,7 +26,7 @@
 
 /* returns true if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno */
-uint8_t get_bit_status(unsigned long *seq_bits, uint32_t last_seqno,
+uint8_t get_bit_status(const unsigned long *seq_bits, uint32_t last_seqno,
 		       uint32_t curr_seqno)
 {
 	int32_t diff, word_offset, word_num;
@@ -190,7 +190,7 @@ char bit_get_packet(void *priv, unsigned long *seq_bits,
 /* count the hamming weight, how many good packets did we receive? just count
  * the 1's.
  */
-int bit_packet_count(unsigned long *seq_bits)
+int bit_packet_count(const unsigned long *seq_bits)
 {
 	int i, hamming = 0;
 
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 769c246..e32eb2d 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -26,8 +26,8 @@
 
 /* returns true if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno */
-uint8_t get_bit_status(unsigned long *seq_bits, uint32_t last_seqno,
-					   uint32_t curr_seqno);
+uint8_t get_bit_status(const unsigned long *seq_bits, uint32_t last_seqno,
+		       uint32_t curr_seqno);
 
 /* turn corresponding bit on, so we can remember that we got the packet */
 void bit_mark(unsigned long *seq_bits, int32_t n);
@@ -39,6 +39,6 @@ char bit_get_packet(void *priv, unsigned long *seq_bits,
 		    int32_t seq_num_diff, int8_t set_mark);
 
 /* count the hamming weight, how many good packets did we receive? */
-int  bit_packet_count(unsigned long *seq_bits);
+int bit_packet_count(const unsigned long *seq_bits);
 
 #endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 6e03635..e9c7eb1 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -393,8 +393,8 @@ void gw_node_purge(struct bat_priv *bat_priv)
 /**
  * fails if orig_node has no router
  */
-static int _write_buffer_text(struct bat_priv *bat_priv,
-			      struct seq_file *seq, struct gw_node *gw_node)
+static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
+			      const struct gw_node *gw_node)
 {
 	struct gw_node *curr_gw;
 	struct neigh_node *router;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index dfbfccc..915e12b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -46,7 +46,7 @@ void hardif_free_rcu(struct rcu_head *rcu)
 	kfree(hard_iface);
 }
 
-struct hard_iface *hardif_get_by_netdev(struct net_device *net_dev)
+struct hard_iface *hardif_get_by_netdev(const struct net_device *net_dev)
 {
 	struct hard_iface *hard_iface;
 
@@ -64,7 +64,7 @@ out:
 	return hard_iface;
 }
 
-static int is_valid_iface(struct net_device *net_dev)
+static int is_valid_iface(const struct net_device *net_dev)
 {
 	if (net_dev->flags & IFF_LOOPBACK)
 		return 0;
@@ -86,7 +86,7 @@ static int is_valid_iface(struct net_device *net_dev)
 	return 1;
 }
 
-static struct hard_iface *hardif_get_active(struct net_device *soft_iface)
+static struct hard_iface *hardif_get_active(const struct net_device *soft_iface)
 {
 	struct hard_iface *hard_iface;
 
@@ -160,7 +160,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	atomic_set(&bat_priv->tt_local_changed, 1);
 }
 
-static bool hardif_is_iface_up(struct hard_iface *hard_iface)
+static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
 {
 	if (hard_iface->net_dev->flags & IFF_UP)
 		return true;
@@ -176,9 +176,9 @@ static void update_mac_addresses(struct hard_iface *hard_iface)
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
 
-static void check_known_mac_addr(struct net_device *net_dev)
+static void check_known_mac_addr(const struct net_device *net_dev)
 {
-	struct hard_iface *hard_iface;
+	const struct hard_iface *hard_iface;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
@@ -204,8 +204,8 @@ static void check_known_mac_addr(struct net_device *net_dev)
 
 int hardif_min_mtu(struct net_device *soft_iface)
 {
-	struct bat_priv *bat_priv = netdev_priv(soft_iface);
-	struct hard_iface *hard_iface;
+	const struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	const struct hard_iface *hard_iface;
 	/* allow big frames if all devices are capable to do so
 	 * (have MTU > 1500 + BAT_HEADER_LEN) */
 	int min_mtu = ETH_DATA_LEN;
@@ -285,7 +285,8 @@ static void hardif_deactivate_interface(struct hard_iface *hard_iface)
 	update_min_mtu(hard_iface->soft_iface);
 }
 
-int hardif_enable_interface(struct hard_iface *hard_iface, char *iface_name)
+int hardif_enable_interface(struct hard_iface *hard_iface,
+			    const char *iface_name)
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 6426599..79e25cb 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -31,8 +31,10 @@
 
 extern struct notifier_block hard_if_notifier;
 
-struct hard_iface *hardif_get_by_netdev(struct net_device *net_dev);
-int hardif_enable_interface(struct hard_iface *hard_iface, char *iface_name);
+struct hard_iface*
+hardif_get_by_netdev(const struct net_device *net_dev);
+int hardif_enable_interface(struct hard_iface *hard_iface,
+			    const char *iface_name);
 void hardif_disable_interface(struct hard_iface *hard_iface);
 void hardif_remove_interfaces(void);
 int hardif_min_mtu(struct net_device *soft_iface);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 434822b..dd5c9fd 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -28,12 +28,12 @@
  * compare 2 element datas for their keys,
  * return 0 if same and not 0 if not
  * same */
-typedef int (*hashdata_compare_cb)(struct hlist_node *, void *);
+typedef int (*hashdata_compare_cb)(const struct hlist_node *, const void *);
 
 /* the hashfunction, should return an index
  * based on the key in the data of the first
  * argument and the size the second */
-typedef int (*hashdata_choose_cb)(void *, int);
+typedef int (*hashdata_choose_cb)(const void *, int);
 typedef void (*hashdata_free_cb)(struct hlist_node *, void *);
 
 struct hashtable_t {
@@ -80,7 +80,7 @@ static inline void hash_delete(struct hashtable_t *hash,
 static inline int hash_add(struct hashtable_t *hash,
 			   hashdata_compare_cb compare,
 			   hashdata_choose_cb choose,
-			   void *data, struct hlist_node *data_node)
+			   const void *data, struct hlist_node *data_node)
 {
 	int index;
 	struct hlist_head *head;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 0a7cee0..2d6445e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -155,9 +155,9 @@ void dec_module_count(void)
 	module_put(THIS_MODULE);
 }
 
-int is_my_mac(uint8_t *addr)
+int is_my_mac(const uint8_t *addr)
 {
-	struct hard_iface *hard_iface;
+	const struct hard_iface *hard_iface;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ba28436..0150897a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -133,10 +133,10 @@ int mesh_init(struct net_device *soft_iface);
 void mesh_free(struct net_device *soft_iface);
 void inc_module_count(void);
 void dec_module_count(void);
-int is_my_mac(uint8_t *addr);
+int is_my_mac(const uint8_t *addr);
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-int debug_log(struct bat_priv *bat_priv, char *fmt, ...) __printf(2, 3);
+int debug_log(struct bat_priv *bat_priv, const char *fmt, ...) __printf(2, 3);
 
 #define bat_dbg(type, bat_priv, fmt, arg...)			\
 	do {							\
@@ -148,7 +148,7 @@ int debug_log(struct bat_priv *bat_priv, char *fmt, ...) __printf(2, 3);
 __printf(3, 4)
 static inline void bat_dbg(char type __always_unused,
 			   struct bat_priv *bat_priv __always_unused,
-			   char *fmt __always_unused, ...)
+			   const char *fmt __always_unused, ...)
 {
 }
 #endif
@@ -173,11 +173,13 @@ static inline void bat_dbg(char type __always_unused,
  *
  * note: can't use compare_ether_addr() as it requires aligned memory
  */
-static inline int compare_eth(void *data1, void *data2)
+
+static inline int compare_eth(const void *data1, const void *data2)
 {
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
+
 #define atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
 
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ae54f77..3ea997d 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -77,7 +77,7 @@ struct neigh_node *orig_node_get_router(struct orig_node *orig_node)
 
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
-				   uint8_t *neigh,
+				   const uint8_t *neigh,
 				   struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -183,7 +183,7 @@ void originator_free(struct bat_priv *bat_priv)
 
 /* this function finds or creates an originator entry for the given
  * address if it does not exits */
-struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 {
 	struct orig_node *orig_node;
 	int size;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index e1d641f..8e307af 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -28,10 +28,10 @@ int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
 void orig_node_free_ref(struct orig_node *orig_node);
-struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
-				   uint8_t *neigh,
+				   const uint8_t *neigh,
 				   struct hard_iface *if_incoming);
 void neigh_node_free_ref(struct neigh_node *neigh_node);
 struct neigh_node *orig_node_get_router(struct orig_node *orig_node);
@@ -41,18 +41,18 @@ int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 
 /* returns 1 if they are the same originator */
-static inline int compare_orig(struct hlist_node *node, void *data2)
+static inline int compare_orig(const struct hlist_node *node, const void *data2)
 {
-	void *data1 = container_of(node, struct orig_node, hash_entry);
+	const void *data1 = container_of(node, struct orig_node, hash_entry);
 
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
 /* hashfunction to choose an entry in a hash table of given size */
 /* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
-static inline int choose_orig(void *data, int32_t size)
+static inline int choose_orig(const void *data, int32_t size)
 {
-	unsigned char *key = data;
+	const unsigned char *key = data;
 	uint32_t hash = 0;
 	size_t i;
 
@@ -70,7 +70,7 @@ static inline int choose_orig(void *data, int32_t size)
 }
 
 static inline struct orig_node *orig_hash_find(struct bat_priv *bat_priv,
-					       void *data)
+					       const void *data)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index 5bb6a61..f1ccfa7 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -28,9 +28,9 @@ void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value)
 	*lq_index = (*lq_index + 1) % TQ_GLOBAL_WINDOW_SIZE;
 }
 
-uint8_t ring_buffer_avg(uint8_t lq_recv[])
+uint8_t ring_buffer_avg(const uint8_t lq_recv[])
 {
-	uint8_t *ptr;
+	const uint8_t *ptr;
 	uint16_t count = 0, i = 0, sum = 0;
 
 	ptr = lq_recv;
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index 0395b27..7cdfe62 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -23,6 +23,6 @@
 #define _NET_BATMAN_ADV_RING_BUFFER_H_
 
 void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value);
-uint8_t ring_buffer_avg(uint8_t lq_recv[]);
+uint8_t ring_buffer_avg(const uint8_t lq_recv[]);
 
 #endif /* _NET_BATMAN_ADV_RING_BUFFER_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8c403ce..e0df4a0 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -65,7 +65,7 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 }
 
 static void update_TT(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		       unsigned char *tt_buff, int tt_buff_len)
+		      const unsigned char *tt_buff, int tt_buff_len)
 {
 	if ((tt_buff_len != orig_node->tt_buff_len) ||
 	    ((tt_buff_len > 0) &&
@@ -82,10 +82,9 @@ static void update_TT(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	}
 }
 
-static void update_route(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node,
+static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			 struct neigh_node *neigh_node,
-			 unsigned char *tt_buff, int tt_buff_len)
+			 const unsigned char *tt_buff, int tt_buff_len)
 {
 	struct neigh_node *curr_router;
 
@@ -133,9 +132,8 @@ static void update_route(struct bat_priv *bat_priv,
 		neigh_node_free_ref(curr_router);
 }
 
-
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, unsigned char *tt_buff,
+		   struct neigh_node *neigh_node, const unsigned char *tt_buff,
 		   int tt_buff_len)
 {
 	struct neigh_node *router = NULL;
@@ -348,9 +346,9 @@ out:
 }
 
 /* copy primary address for bonding */
-static void bonding_save_primary(struct orig_node *orig_node,
+static void bonding_save_primary(const struct orig_node *orig_node,
 				 struct orig_node *orig_neigh_node,
-				 struct batman_packet *batman_packet)
+				 const struct batman_packet *batman_packet)
 {
 	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
 		return;
@@ -358,12 +356,11 @@ static void bonding_save_primary(struct orig_node *orig_node,
 	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
 }
 
-static void update_orig(struct bat_priv *bat_priv,
-			struct orig_node *orig_node,
-			struct ethhdr *ethhdr,
-			struct batman_packet *batman_packet,
+static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
+			const struct ethhdr *ethhdr,
+			const struct batman_packet *batman_packet,
 			struct hard_iface *if_incoming,
-			unsigned char *tt_buff, int tt_buff_len,
+			const unsigned char *tt_buff, int tt_buff_len,
 			char is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
@@ -531,9 +528,9 @@ static int window_protected(struct bat_priv *bat_priv,
  *  -1 the packet is old and has been received while the seqno window
  *     was protected. Caller should drop it.
  */
-static char count_real_packets(struct ethhdr *ethhdr,
-			       struct batman_packet *batman_packet,
-			       struct hard_iface *if_incoming)
+static char count_real_packets(const struct ethhdr *ethhdr,
+			       const struct batman_packet *batman_packet,
+			       const struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
@@ -595,9 +592,9 @@ out:
 	return ret;
 }
 
-void receive_bat_packet(struct ethhdr *ethhdr,
+void receive_bat_packet(const struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
-			unsigned char *tt_buff, int tt_buff_len,
+			const unsigned char *tt_buff, int tt_buff_len,
 			struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -1077,7 +1074,7 @@ out:
  * This method rotates the bonding list and increases the
  * returned router's refcount. */
 static struct neigh_node *find_bond_router(struct orig_node *primary_orig,
-					   struct hard_iface *recv_if)
+					   const struct hard_iface *recv_if)
 {
 	struct neigh_node *tmp_neigh_node;
 	struct neigh_node *router = NULL, *first_candidate = NULL;
@@ -1128,7 +1125,7 @@ out:
  *
  * Increases the returned router's refcount */
 static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
-					      struct hard_iface *recv_if)
+					      const struct hard_iface *recv_if)
 {
 	struct neigh_node *tmp_neigh_node;
 	struct neigh_node *router = NULL, *first_candidate = NULL;
@@ -1176,7 +1173,7 @@ static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
  * refcount.*/
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
-			       struct hard_iface *recv_if)
+			       const struct hard_iface *recv_if)
 {
 	struct orig_node *primary_orig_node;
 	struct orig_node *router_orig;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 870f298..0ce0392 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -23,12 +23,12 @@
 #define _NET_BATMAN_ADV_ROUTING_H_
 
 void slide_own_bcast_window(struct hard_iface *hard_iface);
-void receive_bat_packet(struct ethhdr *ethhdr,
-				struct batman_packet *batman_packet,
-				unsigned char *tt_buff, int tt_buff_len,
-				struct hard_iface *if_incoming);
+void receive_bat_packet(const struct ethhdr *ethhdr,
+			struct batman_packet *batman_packet,
+			const unsigned char *tt_buff, int tt_buff_len,
+			struct hard_iface *if_incoming);
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, unsigned char *tt_buff,
+		   struct neigh_node *neigh_node, const unsigned char *tt_buff,
 		   int tt_buff_len);
 int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
@@ -39,7 +39,7 @@ int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bat_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
-			       struct hard_iface *recv_if);
+			       const struct hard_iface *recv_if);
 void bonding_candidate_del(struct orig_node *orig_node,
 			   struct neigh_node *neigh_node);
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3377927..9a20ba9 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -33,14 +33,14 @@
 static void send_outstanding_bcast_packet(struct work_struct *work);
 
 /* apply hop penalty for a normal link */
-static uint8_t hop_penalty(const uint8_t tq, struct bat_priv *bat_priv)
+static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
 {
 	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
 	return (tq * (TQ_MAX_VALUE - hop_penalty)) / (TQ_MAX_VALUE);
 }
 
 /* when do we schedule our own packet to be sent */
-static unsigned long own_send_time(struct bat_priv *bat_priv)
+static unsigned long own_send_time(const struct bat_priv *bat_priv)
 {
 	return jiffies + msecs_to_jiffies(
 		   atomic_read(&bat_priv->orig_interval) -
@@ -55,9 +55,8 @@ static unsigned long forward_send_time(void)
 
 /* send out an already prepared packet to the given address via the
  * specified batman interface */
-int send_skb_packet(struct sk_buff *skb,
-				struct hard_iface *hard_iface,
-				uint8_t *dst_addr)
+int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
+		    const uint8_t *dst_addr)
 {
 	struct ethhdr *ethhdr;
 
@@ -307,7 +306,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 }
 
 void schedule_forward_packet(struct orig_node *orig_node,
-			     struct ethhdr *ethhdr,
+			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
 			     uint8_t directlink, int tt_buff_len,
 			     struct hard_iface *if_incoming)
@@ -408,11 +407,13 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
  *
  * The skb is not consumed, so the caller should make sure that the
  * skb is freed. */
-int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
+int add_bcast_packet_to_list(struct bat_priv *bat_priv,
+			     const struct sk_buff *skb)
 {
 	struct hard_iface *primary_if = NULL;
 	struct forw_packet *forw_packet;
 	struct bcast_packet *bcast_packet;
+	struct sk_buff *newskb;
 
 	if (!atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
 		bat_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
@@ -428,17 +429,17 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
 	if (!forw_packet)
 		goto out_and_inc;
 
-	skb = skb_copy(skb, GFP_ATOMIC);
-	if (!skb)
+	newskb = skb_copy(skb, GFP_ATOMIC);
+	if (!newskb)
 		goto packet_free;
 
 	/* as we have a copy now, it is safe to decrease the TTL */
-	bcast_packet = (struct bcast_packet *)skb->data;
+	bcast_packet = (struct bcast_packet *)newskb->data;
 	bcast_packet->ttl--;
 
-	skb_reset_mac_header(skb);
+	skb_reset_mac_header(newskb);
 
-	forw_packet->skb = skb;
+	forw_packet->skb = newskb;
 	forw_packet->if_incoming = primary_if;
 
 	/* how often did we send the bcast packet ? */
@@ -537,7 +538,7 @@ out:
 }
 
 void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       struct hard_iface *hard_iface)
+			       const struct hard_iface *hard_iface)
 {
 	struct forw_packet *forw_packet;
 	struct hlist_node *tmp_node, *safe_tmp_node;
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 247172d..eceab87 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -22,18 +22,18 @@
 #ifndef _NET_BATMAN_ADV_SEND_H_
 #define _NET_BATMAN_ADV_SEND_H_
 
-int send_skb_packet(struct sk_buff *skb,
-				struct hard_iface *hard_iface,
-				uint8_t *dst_addr);
+int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
+		    const uint8_t *dst_addr);
 void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
-			     struct ethhdr *ethhdr,
+			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
 			     uint8_t directlink, int tt_buff_len,
 			     struct hard_iface *if_outgoing);
-int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb);
+int add_bcast_packet_to_list(struct bat_priv *bat_priv,
+			     const struct sk_buff *skb);
 void send_outstanding_bat_packet(struct work_struct *work);
 void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       struct hard_iface *hard_iface);
+			       const struct hard_iface *hard_iface);
 
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d5aa609..1bec3a0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -146,7 +146,7 @@ out:
 }
 
 static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
-					     uint8_t *addr, short vid)
+					     const uint8_t *addr, short vid)
 {
 	struct softif_neigh_vid *softif_neigh_vid;
 	struct softif_neigh *softif_neigh = NULL;
@@ -793,7 +793,7 @@ static void interface_setup(struct net_device *dev)
 	memset(priv, 0, sizeof(struct bat_priv));
 }
 
-struct net_device *softif_create(char *name)
+struct net_device *softif_create(const char *name)
 {
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
@@ -872,7 +872,7 @@ void softif_destroy(struct net_device *soft_iface)
 	unregister_netdevice(soft_iface);
 }
 
-int softif_is_valid(struct net_device *net_dev)
+int softif_is_valid(const struct net_device *net_dev)
 {
 #ifdef HAVE_NET_DEVICE_OPS
 	if (net_dev->netdev_ops->ndo_start_xmit == interface_tx)
@@ -924,4 +924,3 @@ static u32 bat_get_link(struct net_device *dev)
 {
 	return 1;
 }
-
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 4789b6f..c24906d 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -29,8 +29,8 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface);
 void interface_rx(struct net_device *soft_iface,
 		  struct sk_buff *skb, struct hard_iface *recv_if,
 		  int hdr_size);
-struct net_device *softif_create(char *name);
+struct net_device *softif_create(const char *name);
 void softif_destroy(struct net_device *soft_iface);
-int softif_is_valid(struct net_device *net_dev);
+int softif_is_valid(const struct net_device *net_dev);
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7b72966..be7b5cc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -29,20 +29,22 @@
 static void tt_local_purge(struct work_struct *work);
 static void _tt_global_del_orig(struct bat_priv *bat_priv,
 				 struct tt_global_entry *tt_global_entry,
-				 char *message);
+				 const char *message);
 
 /* returns 1 if they are the same mac addr */
-static int compare_ltt(struct hlist_node *node, void *data2)
+static int compare_ltt(const struct hlist_node *node, const void *data2)
 {
-	void *data1 = container_of(node, struct tt_local_entry, hash_entry);
+	const void *data1 = container_of(node, struct tt_local_entry,
+					 hash_entry);
 
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
 /* returns 1 if they are the same mac addr */
-static int compare_gtt(struct hlist_node *node, void *data2)
+static int compare_gtt(const struct hlist_node *node, const void *data2)
 {
-	void *data1 = container_of(node, struct tt_global_entry, hash_entry);
+	const void *data1 = container_of(node, struct tt_global_entry,
+					 hash_entry);
 
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
@@ -54,7 +56,7 @@ static void tt_local_start_timer(struct bat_priv *bat_priv)
 }
 
 static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
-						   void *data)
+						 const void *data)
 {
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct hlist_head *head;
@@ -82,7 +84,7 @@ static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
 }
 
 static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
-						     void *data)
+						   const void *data)
 {
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
 	struct hlist_head *head;
@@ -126,7 +128,7 @@ int tt_local_init(struct bat_priv *bat_priv)
 	return 1;
 }
 
-void tt_local_add(struct net_device *soft_iface, uint8_t *addr)
+void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry;
@@ -320,8 +322,8 @@ static void _tt_local_del(struct hlist_node *node, void *arg)
 }
 
 static void tt_local_del(struct bat_priv *bat_priv,
-			  struct tt_local_entry *tt_local_entry,
-			  char *message)
+			 struct tt_local_entry *tt_local_entry,
+			 const char *message)
 {
 	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local tt entry (%pM): %s\n",
 		tt_local_entry->addr, message);
@@ -332,7 +334,7 @@ static void tt_local_del(struct bat_priv *bat_priv,
 }
 
 void tt_local_remove(struct bat_priv *bat_priv,
-		      uint8_t *addr, char *message)
+		     const uint8_t *addr, const char *message)
 {
 	struct tt_local_entry *tt_local_entry;
 
@@ -409,12 +411,12 @@ int tt_global_init(struct bat_priv *bat_priv)
 
 void tt_global_add_orig(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node,
-			 unsigned char *tt_buff, int tt_buff_len)
+			 const unsigned char *tt_buff, int tt_buff_len)
 {
 	struct tt_global_entry *tt_global_entry;
 	struct tt_local_entry *tt_local_entry;
 	int tt_buff_count = 0;
-	unsigned char *tt_ptr;
+	const unsigned char *tt_ptr;
 
 	while ((tt_buff_count + 1) * ETH_ALEN <= tt_buff_len) {
 		spin_lock_bh(&bat_priv->tt_ghash_lock);
@@ -557,7 +559,7 @@ out:
 
 static void _tt_global_del_orig(struct bat_priv *bat_priv,
 				 struct tt_global_entry *tt_global_entry,
-				 char *message)
+				 const char *message)
 {
 	bat_dbg(DBG_ROUTES, bat_priv,
 		"Deleting global tt entry %pM (via %pM): %s\n",
@@ -570,7 +572,7 @@ static void _tt_global_del_orig(struct bat_priv *bat_priv,
 }
 
 void tt_global_del_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node, char *message)
+			 struct orig_node *orig_node, const char *message)
 {
 	struct tt_global_entry *tt_global_entry;
 	int tt_buff_count = 0;
@@ -616,7 +618,8 @@ void tt_global_free(struct bat_priv *bat_priv)
 	bat_priv->tt_global_hash = NULL;
 }
 
-struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
+struct orig_node *transtable_search(struct bat_priv *bat_priv,
+				    const uint8_t *addr)
 {
 	struct tt_global_entry *tt_global_entry;
 	struct orig_node *orig_node = NULL;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 46152c3..0f2b990 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -23,21 +23,22 @@
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
 int tt_local_init(struct bat_priv *bat_priv);
-void tt_local_add(struct net_device *soft_iface, uint8_t *addr);
+void tt_local_add(struct net_device *soft_iface, const uint8_t *addr);
 void tt_local_remove(struct bat_priv *bat_priv,
-		      uint8_t *addr, char *message);
+		     const uint8_t *addr, const char *message);
 int tt_local_fill_buffer(struct bat_priv *bat_priv,
 			  unsigned char *buff, int buff_len);
 int tt_local_seq_print_text(struct seq_file *seq, void *offset);
 void tt_local_free(struct bat_priv *bat_priv);
 int tt_global_init(struct bat_priv *bat_priv);
 void tt_global_add_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node,
-			 unsigned char *tt_buff, int tt_buff_len);
+			struct orig_node *orig_node,
+			const unsigned char *tt_buff, int tt_buff_len);
 int tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_del_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node, char *message);
+			 struct orig_node *orig_node, const char *message);
 void tt_global_free(struct bat_priv *bat_priv);
-struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr);
+struct orig_node *transtable_search(struct bat_priv *bat_priv,
+				    const uint8_t *addr);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index bab6076..e2deb44 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -115,7 +115,7 @@ static int frag_create_buffer(struct list_head *head)
 }
 
 static struct frag_packet_list_entry *frag_search_packet(struct list_head *head,
-						 struct unicast_frag_packet *up)
+					   const struct unicast_frag_packet *up)
 {
 	struct frag_packet_list_entry *tfp;
 	struct unicast_frag_packet *tmp_up = NULL;
@@ -218,7 +218,7 @@ out:
 }
 
 int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct hard_iface *hard_iface, uint8_t dstaddr[])
+		  struct hard_iface *hard_iface, const uint8_t dstaddr[])
 {
 	struct unicast_packet tmp_uc, *unicast_packet;
 	struct hard_iface *primary_if;
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 16ad7a9..2ba867c 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -32,11 +32,11 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 void frag_list_free(struct list_head *head);
 int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
 int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct hard_iface *hard_iface, uint8_t dstaddr[]);
+		  struct hard_iface *hard_iface, const uint8_t dstaddr[]);
 
-static inline int frag_can_reassemble(struct sk_buff *skb, int mtu)
+static inline int frag_can_reassemble(const struct sk_buff *skb, int mtu)
 {
-	struct unicast_frag_packet *unicast_packet;
+	const struct unicast_frag_packet *unicast_packet;
 	int uneven_correction = 0;
 	unsigned int merged_size;
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c39f20c..adb0327 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -68,10 +68,10 @@ static void free_info(struct kref *ref)
 }
 
 /* Compare two vis packets, used by the hashing algorithm */
-static int vis_info_cmp(struct hlist_node *node, void *data2)
+static int vis_info_cmp(const struct hlist_node *node, const void *data2)
 {
-	struct vis_info *d1, *d2;
-	struct vis_packet *p1, *p2;
+	const struct vis_info *d1, *d2;
+	const struct vis_packet *p1, *p2;
 
 	d1 = container_of(node, struct vis_info, hash_entry);
 	d2 = data2;
@@ -82,11 +82,11 @@ static int vis_info_cmp(struct hlist_node *node, void *data2)
 
 /* hash function to choose an entry in a hash table of given size */
 /* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
-static int vis_info_choose(void *data, int size)
+static int vis_info_choose(const void *data, int size)
 {
-	struct vis_info *vis_info = data;
-	struct vis_packet *packet;
-	unsigned char *key;
+	const struct vis_info *vis_info = data;
+	const struct vis_packet *packet;
+	const unsigned char *key;
 	uint32_t hash = 0;
 	size_t i;
 
@@ -106,7 +106,7 @@ static int vis_info_choose(void *data, int size)
 }
 
 static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
-				      void *data)
+				      const void *data)
 {
 	struct hashtable_t *hash = bat_priv->vis_hash;
 	struct hlist_head *head;
@@ -143,7 +143,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
-		if (compare_eth(entry->addr, (void *)interface))
+		if (compare_eth(entry->addr, interface))
 			return;
 	}
 
@@ -156,7 +156,8 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	hlist_add_head(&entry->list, if_list);
 }
 
-static ssize_t vis_data_read_prim_sec(char *buff, struct hlist_head *if_list)
+static ssize_t vis_data_read_prim_sec(char *buff,
+				      const struct hlist_head *if_list)
 {
 	struct if_list_entry *entry;
 	struct hlist_node *pos;
@@ -189,8 +190,9 @@ static size_t vis_data_count_prim_sec(struct hlist_head *if_list)
 }
 
 /* read an entry  */
-static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
-				   uint8_t *src, bool primary)
+static ssize_t vis_data_read_entry(char *buff,
+				   const struct vis_info_entry *entry,
+				   const uint8_t *src, bool primary)
 {
 	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
@@ -361,7 +363,7 @@ static void send_list_del(struct vis_info *info)
 
 /* tries to add one entry to the receive list. */
 static void recv_list_add(struct bat_priv *bat_priv,
-			  struct list_head *recv_list, char *mac)
+			  struct list_head *recv_list, const char *mac)
 {
 	struct recvlist_node *entry;
 
@@ -377,9 +379,9 @@ static void recv_list_add(struct bat_priv *bat_priv,
 
 /* returns 1 if this mac is in the recv_list */
 static int recv_list_is_in(struct bat_priv *bat_priv,
-			   struct list_head *recv_list, char *mac)
+			   const struct list_head *recv_list, const char *mac)
 {
-	struct recvlist_node *entry;
+	const struct recvlist_node *entry;
 
 	spin_lock_bh(&bat_priv->vis_list_lock);
 	list_for_each_entry(entry, recv_list, list) {
@@ -599,9 +601,9 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 }
 
 /* Return true if the vis packet is full. */
-static bool vis_packet_full(struct vis_info *info)
+static bool vis_packet_full(const struct vis_info *info)
 {
-	struct vis_packet *packet;
+	const struct vis_packet *packet;
 	packet = (struct vis_packet *)info->skb_packet->data;
 
 	if (MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_entry)
-- 
1.7.5.3
