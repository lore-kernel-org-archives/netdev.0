From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 5/6] openvswitch: Constify various function arguments
Date: Sun,  9 Nov 2014 19:59:23 -0800
Message-ID: <1415591963-1680-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@noironetworks.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:36749 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752088AbaKJD70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:26 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so7407891pad.29
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@noironetworks.com>

Help produce better optimized code.

Signed-off-by: Thomas Graf <tgraf@noironetworks.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c      |  7 ++++---
 net/openvswitch/datapath.c     | 10 +++++-----
 net/openvswitch/datapath.h     |  4 ++--
 net/openvswitch/flow.c         |  4 ++--
 net/openvswitch/flow.h         | 11 ++++++-----
 net/openvswitch/flow_table.c   | 12 ++++++------
 net/openvswitch/flow_table.h   |  8 ++++----
 net/openvswitch/vport-geneve.c |  2 +-
 net/openvswitch/vport-netdev.c |  2 +-
 net/openvswitch/vport.c        |  8 ++++----
 net/openvswitch/vport.h        |  6 +++---
 11 files changed, 38 insertions(+), 36 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 10c94ac..394efa6 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -69,7 +69,7 @@ static void action_fifo_init(struct action_fifo *fifo)
 	fifo->tail = 0;
 }
 
-static bool action_fifo_is_empty(struct action_fifo *fifo)
+static bool action_fifo_is_empty(const struct action_fifo *fifo)
 {
 	return (fifo->head == fifo->tail);
 }
@@ -92,7 +92,7 @@ static struct deferred_action *action_fifo_put(struct action_fifo *fifo)
 
 /* Return true if fifo is not full */
 static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
-						    struct sw_flow_key *key,
+						    const struct sw_flow_key *key,
 						    const struct nlattr *attr)
 {
 	struct action_fifo *fifo;
@@ -944,7 +944,8 @@ static void process_deferred_actions(struct datapath *dp)
 
 /* Execute a list of actions against 'skb'. */
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			struct sw_flow_actions *acts, struct sw_flow_key *key)
+			const struct sw_flow_actions *acts,
+			struct sw_flow_key *key)
 {
 	int level = this_cpu_read(exec_actions_level);
 	int err;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7146b38..65561eb 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -178,7 +178,7 @@ const char *ovs_dp_name(const struct datapath *dp)
 	return vport->ops->get_name(vport);
 }
 
-static int get_dpifindex(struct datapath *dp)
+static int get_dpifindex(const struct datapath *dp)
 {
 	struct vport *local;
 	int ifindex;
@@ -633,7 +633,7 @@ static struct genl_family dp_packet_genl_family = {
 	.n_ops = ARRAY_SIZE(dp_packet_genl_ops),
 };
 
-static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
+static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
 			 struct ovs_dp_megaflow_stats *mega_stats)
 {
 	int i;
@@ -1352,7 +1352,7 @@ static struct sk_buff *ovs_dp_cmd_alloc_info(struct genl_info *info)
 
 /* Called with rcu_read_lock or ovs_mutex. */
 static struct datapath *lookup_datapath(struct net *net,
-					struct ovs_header *ovs_header,
+					const struct ovs_header *ovs_header,
 					struct nlattr *a[OVS_DP_ATTR_MAX + 1])
 {
 	struct datapath *dp;
@@ -1380,7 +1380,7 @@ static void ovs_dp_reset_user_features(struct sk_buff *skb, struct genl_info *in
 	dp->user_features = 0;
 }
 
-static void ovs_dp_change(struct datapath *dp, struct nlattr **a)
+static void ovs_dp_change(struct datapath *dp, struct nlattr *a[])
 {
 	if (a[OVS_DP_ATTR_USER_FEATURES])
 		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
@@ -1744,7 +1744,7 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 
 /* Called with ovs_mutex or RCU read lock. */
 static struct vport *lookup_vport(struct net *net,
-				  struct ovs_header *ovs_header,
+				  const struct ovs_header *ovs_header,
 				  struct nlattr *a[OVS_VPORT_ATTR_MAX + 1])
 {
 	struct datapath *dp;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 8de9f7e..8389c1d 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -149,7 +149,7 @@ int lockdep_ovsl_is_held(void);
 #define rcu_dereference_ovsl(p)					\
 	rcu_dereference_check(p, lockdep_ovsl_is_held())
 
-static inline struct net *ovs_dp_get_net(struct datapath *dp)
+static inline struct net *ovs_dp_get_net(const struct datapath *dp)
 {
 	return read_pnet(&dp->net);
 }
@@ -192,7 +192,7 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			struct sw_flow_actions *acts, struct sw_flow_key *);
+			const struct sw_flow_actions *, struct sw_flow_key *);
 
 void ovs_dp_notify_wq(struct work_struct *work);
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 90a2101..25e9abc 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -66,7 +66,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 #define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
 void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
-			   struct sk_buff *skb)
+			   const struct sk_buff *skb)
 {
 	struct flow_stats *stats;
 	int node = numa_node_id();
@@ -679,7 +679,7 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 	return key_extract(skb, key);
 }
 
-int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info,
+int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	/* Extract metadata from packet. */
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 543b358..9e0a787 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -53,7 +53,7 @@ struct ovs_key_ipv4_tunnel {
 
 struct ovs_tunnel_info {
 	struct ovs_key_ipv4_tunnel tunnel;
-	struct geneve_opt *options;
+	const struct geneve_opt *options;
 	u8 options_len;
 };
 
@@ -73,7 +73,7 @@ static inline void __ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					    __be16 tp_dst,
 					    __be64 tun_id,
 					    __be16 tun_flags,
-					    struct geneve_opt *opts,
+					    const struct geneve_opt *opts,
 					    u8 opts_len)
 {
 	tun_info->tunnel.tun_id = tun_id;
@@ -105,7 +105,7 @@ static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					  __be16 tp_dst,
 					  __be64 tun_id,
 					  __be16 tun_flags,
-					  struct geneve_opt *opts,
+					  const struct geneve_opt *opts,
 					  u8 opts_len)
 {
 	__ovs_flow_tun_info_init(tun_info, iph->saddr, iph->daddr,
@@ -244,14 +244,15 @@ struct arp_eth_header {
 } __packed;
 
 void ovs_flow_stats_update(struct sw_flow *, __be16 tcp_flags,
-			   struct sk_buff *);
+			   const struct sk_buff *);
 void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 			unsigned long *used, __be16 *tcp_flags);
 void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key);
-int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info, struct sk_buff *skb,
+int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
+			 struct sk_buff *skb,
 			 struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
 int ovs_flow_key_extract_userspace(const struct nlattr *attr,
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 90f8b40..e0a7fef 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -107,7 +107,7 @@ err:
 	return ERR_PTR(-ENOMEM);
 }
 
-int ovs_flow_tbl_count(struct flow_table *table)
+int ovs_flow_tbl_count(const struct flow_table *table)
 {
 	return table->count;
 }
@@ -401,7 +401,7 @@ static bool flow_cmp_masked_key(const struct sw_flow *flow,
 }
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       struct sw_flow_match *match)
+			       const struct sw_flow_match *match)
 {
 	struct sw_flow_key *key = match->key;
 	int key_start = flow_key_start(key);
@@ -412,7 +412,7 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 
 static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 					  const struct sw_flow_key *unmasked,
-					  struct sw_flow_mask *mask)
+					  const struct sw_flow_mask *mask)
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
@@ -460,7 +460,7 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 }
 
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
-					  struct sw_flow_match *match)
+					  const struct sw_flow_match *match)
 {
 	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
 	struct sw_flow_mask *mask;
@@ -563,7 +563,7 @@ static struct sw_flow_mask *flow_mask_find(const struct flow_table *tbl,
 
 /* Add 'mask' into the mask list, if it is not already there. */
 static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
-			    struct sw_flow_mask *new)
+			    const struct sw_flow_mask *new)
 {
 	struct sw_flow_mask *mask;
 	mask = flow_mask_find(tbl, new);
@@ -586,7 +586,7 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
 
 /* Must be called with OVS mutex held. */
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-			struct sw_flow_mask *mask)
+			const struct sw_flow_mask *mask)
 {
 	struct table_instance *new_ti = NULL;
 	struct table_instance *ti;
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index f682c8c..309fa64 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -61,12 +61,12 @@ struct sw_flow *ovs_flow_alloc(void);
 void ovs_flow_free(struct sw_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
-int ovs_flow_tbl_count(struct flow_table *table);
+int ovs_flow_tbl_count(const struct flow_table *table);
 void ovs_flow_tbl_destroy(struct flow_table *table);
 int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-			struct sw_flow_mask *mask);
+			const struct sw_flow_mask *mask);
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
 int  ovs_flow_tbl_num_masks(const struct flow_table *table);
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
@@ -77,9 +77,9 @@ struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
-					  struct sw_flow_match *match);
+					  const struct sw_flow_match *match);
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       struct sw_flow_match *match);
+			       const struct sw_flow_match *match);
 
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index e31f19c..347fa23 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -68,7 +68,7 @@ static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 }
 
 /* Convert 24 bit VNI to 64 bit tunnel ID. */
-static __be64 vni_to_tunnel_id(__u8 *vni)
+static __be64 vni_to_tunnel_id(const __u8 *vni)
 {
 #ifdef __BIG_ENDIAN
 	return (vni[0] << 16) | (vni[1] << 8) | vni[2];
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 877ee74..4776282 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -77,7 +77,7 @@ static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-static struct net_device *get_dpdev(struct datapath *dp)
+static struct net_device *get_dpdev(const struct datapath *dp)
 {
 	struct vport *local;
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 630e819..e771a46 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -68,7 +68,7 @@ void ovs_vport_exit(void)
 	kfree(dev_table);
 }
 
-static struct hlist_head *hash_bucket(struct net *net, const char *name)
+static struct hlist_head *hash_bucket(const struct net *net, const char *name)
 {
 	unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
 	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
@@ -107,7 +107,7 @@ EXPORT_SYMBOL_GPL(ovs_vport_ops_unregister);
  *
  * Must be called with ovs or RCU read lock.
  */
-struct vport *ovs_vport_locate(struct net *net, const char *name)
+struct vport *ovs_vport_locate(const struct net *net, const char *name)
 {
 	struct hlist_head *bucket = hash_bucket(net, name);
 	struct vport *vport;
@@ -380,7 +380,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  *
  * Must be called with ovs_mutex.
  */
-int ovs_vport_set_upcall_portids(struct vport *vport,  struct nlattr *ids)
+int ovs_vport_set_upcall_portids(struct vport *vport, const struct nlattr *ids)
 {
 	struct vport_portids *old, *vport_portids;
 
@@ -471,7 +471,7 @@ u32 ovs_vport_find_upcall_portid(const struct vport *vport, struct sk_buff *skb)
  * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       struct ovs_tunnel_info *tun_info)
+		       const struct ovs_tunnel_info *tun_info)
 {
 	struct pcpu_sw_netstats *stats;
 	struct sw_flow_key key;
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 0635d1d..99c8e71 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -45,14 +45,14 @@ void ovs_vport_exit(void);
 struct vport *ovs_vport_add(const struct vport_parms *);
 void ovs_vport_del(struct vport *);
 
-struct vport *ovs_vport_locate(struct net *net, const char *name);
+struct vport *ovs_vport_locate(const struct net *net, const char *name);
 
 void ovs_vport_get_stats(struct vport *, struct ovs_vport_stats *);
 
 int ovs_vport_set_options(struct vport *, struct nlattr *options);
 int ovs_vport_get_options(const struct vport *, struct sk_buff *);
 
-int ovs_vport_set_upcall_portids(struct vport *, struct nlattr *pids);
+int ovs_vport_set_upcall_portids(struct vport *, const struct nlattr *pids);
 int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
 u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
@@ -224,7 +224,7 @@ static inline struct vport *vport_from_priv(void *priv)
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       struct ovs_tunnel_info *);
+		       const struct ovs_tunnel_info *);
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
-- 
1.9.3
