From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] bridge: use DEVICE_ATTR_xx macros
Date: Mon, 06 Jan 2014 11:00:44 -0800
Message-ID: <20140106190044.10912.47228.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, curt@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:57034 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725AbaAFTBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 14:01:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DEVICE_ATTR_RO/RW macros to simplify bridge sysfs attribute definitions.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 net/bridge/br_sysfs_br.c |  249 ++++++++++++++++++++--------------------------
 1 file changed, 108 insertions(+), 141 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 3b9637f..8dac6555 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -49,53 +49,51 @@ static ssize_t store_bridge_parm(struct device *d,
 }
 
 
-static ssize_t show_forward_delay(struct device *d,
+static ssize_t forward_delay_show(struct device *d,
 				  struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
 }
 
-static ssize_t store_forward_delay(struct device *d,
+static ssize_t forward_delay_store(struct device *d,
 				   struct device_attribute *attr,
 				   const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_set_forward_delay);
 }
-static DEVICE_ATTR(forward_delay, S_IRUGO | S_IWUSR,
-		   show_forward_delay, store_forward_delay);
+static DEVICE_ATTR_RW(forward_delay);
 
-static ssize_t show_hello_time(struct device *d, struct device_attribute *attr,
+static ssize_t hello_time_show(struct device *d, struct device_attribute *attr,
 			       char *buf)
 {
 	return sprintf(buf, "%lu\n",
 		       jiffies_to_clock_t(to_bridge(d)->hello_time));
 }
 
-static ssize_t store_hello_time(struct device *d,
+static ssize_t hello_time_store(struct device *d,
 				struct device_attribute *attr, const char *buf,
 				size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_set_hello_time);
 }
-static DEVICE_ATTR(hello_time, S_IRUGO | S_IWUSR, show_hello_time,
-		   store_hello_time);
+static DEVICE_ATTR_RW(hello_time);
 
-static ssize_t show_max_age(struct device *d, struct device_attribute *attr,
+static ssize_t max_age_show(struct device *d, struct device_attribute *attr,
 			    char *buf)
 {
 	return sprintf(buf, "%lu\n",
 		       jiffies_to_clock_t(to_bridge(d)->max_age));
 }
 
-static ssize_t store_max_age(struct device *d, struct device_attribute *attr,
+static ssize_t max_age_store(struct device *d, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_set_max_age);
 }
-static DEVICE_ATTR(max_age, S_IRUGO | S_IWUSR, show_max_age, store_max_age);
+static DEVICE_ATTR_RW(max_age);
 
-static ssize_t show_ageing_time(struct device *d,
+static ssize_t ageing_time_show(struct device *d,
 				struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -108,16 +106,15 @@ static int set_ageing_time(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_ageing_time(struct device *d,
+static ssize_t ageing_time_store(struct device *d,
 				 struct device_attribute *attr,
 				 const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_ageing_time);
 }
-static DEVICE_ATTR(ageing_time, S_IRUGO | S_IWUSR, show_ageing_time,
-		   store_ageing_time);
+static DEVICE_ATTR_RW(ageing_time);
 
-static ssize_t show_stp_state(struct device *d,
+static ssize_t stp_state_show(struct device *d,
 			      struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -125,7 +122,7 @@ static ssize_t show_stp_state(struct device *d,
 }
 
 
-static ssize_t store_stp_state(struct device *d,
+static ssize_t stp_state_store(struct device *d,
 			       struct device_attribute *attr, const char *buf,
 			       size_t len)
 {
@@ -147,20 +144,21 @@ static ssize_t store_stp_state(struct device *d,
 
 	return len;
 }
-static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
-		   store_stp_state);
+static DEVICE_ATTR_RW(stp_state);
 
-static ssize_t show_group_fwd_mask(struct device *d,
-			      struct device_attribute *attr, char *buf)
+static ssize_t group_fwd_mask_show(struct device *d,
+				   struct device_attribute *attr,
+				   char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%#x\n", br->group_fwd_mask);
 }
 
 
-static ssize_t store_group_fwd_mask(struct device *d,
-			       struct device_attribute *attr, const char *buf,
-			       size_t len)
+static ssize_t group_fwd_mask_store(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf,
+				    size_t len)
 {
 	struct net_bridge *br = to_bridge(d);
 	char *endp;
@@ -180,10 +178,9 @@ static ssize_t store_group_fwd_mask(struct device *d,
 
 	return len;
 }
-static DEVICE_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
-		   store_group_fwd_mask);
+static DEVICE_ATTR_RW(group_fwd_mask);
 
-static ssize_t show_priority(struct device *d, struct device_attribute *attr,
+static ssize_t priority_show(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -197,93 +194,91 @@ static int set_priority(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_priority(struct device *d, struct device_attribute *attr,
-			       const char *buf, size_t len)
+static ssize_t priority_store(struct device *d, struct device_attribute *attr,
+			      const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_priority);
 }
-static DEVICE_ATTR(priority, S_IRUGO | S_IWUSR, show_priority, store_priority);
+static DEVICE_ATTR_RW(priority);
 
-static ssize_t show_root_id(struct device *d, struct device_attribute *attr,
+static ssize_t root_id_show(struct device *d, struct device_attribute *attr,
 			    char *buf)
 {
 	return br_show_bridge_id(buf, &to_bridge(d)->designated_root);
 }
-static DEVICE_ATTR(root_id, S_IRUGO, show_root_id, NULL);
+static DEVICE_ATTR_RO(root_id);
 
-static ssize_t show_bridge_id(struct device *d, struct device_attribute *attr,
+static ssize_t bridge_id_show(struct device *d, struct device_attribute *attr,
 			      char *buf)
 {
 	return br_show_bridge_id(buf, &to_bridge(d)->bridge_id);
 }
-static DEVICE_ATTR(bridge_id, S_IRUGO, show_bridge_id, NULL);
+static DEVICE_ATTR_RO(bridge_id);
 
-static ssize_t show_root_port(struct device *d, struct device_attribute *attr,
+static ssize_t root_port_show(struct device *d, struct device_attribute *attr,
 			      char *buf)
 {
 	return sprintf(buf, "%d\n", to_bridge(d)->root_port);
 }
-static DEVICE_ATTR(root_port, S_IRUGO, show_root_port, NULL);
+static DEVICE_ATTR_RO(root_port);
 
-static ssize_t show_root_path_cost(struct device *d,
+static ssize_t root_path_cost_show(struct device *d,
 				   struct device_attribute *attr, char *buf)
 {
 	return sprintf(buf, "%d\n", to_bridge(d)->root_path_cost);
 }
-static DEVICE_ATTR(root_path_cost, S_IRUGO, show_root_path_cost, NULL);
+static DEVICE_ATTR_RO(root_path_cost);
 
-static ssize_t show_topology_change(struct device *d,
+static ssize_t topology_change_show(struct device *d,
 				    struct device_attribute *attr, char *buf)
 {
 	return sprintf(buf, "%d\n", to_bridge(d)->topology_change);
 }
-static DEVICE_ATTR(topology_change, S_IRUGO, show_topology_change, NULL);
+static DEVICE_ATTR_RO(topology_change);
 
-static ssize_t show_topology_change_detected(struct device *d,
+static ssize_t topology_change_detected_show(struct device *d,
 					     struct device_attribute *attr,
 					     char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%d\n", br->topology_change_detected);
 }
-static DEVICE_ATTR(topology_change_detected, S_IRUGO,
-		   show_topology_change_detected, NULL);
+static DEVICE_ATTR_RO(topology_change_detected);
 
-static ssize_t show_hello_timer(struct device *d,
+static ssize_t hello_timer_show(struct device *d,
 				struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%ld\n", br_timer_value(&br->hello_timer));
 }
-static DEVICE_ATTR(hello_timer, S_IRUGO, show_hello_timer, NULL);
+static DEVICE_ATTR_RO(hello_timer);
 
-static ssize_t show_tcn_timer(struct device *d, struct device_attribute *attr,
+static ssize_t tcn_timer_show(struct device *d, struct device_attribute *attr,
 			      char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%ld\n", br_timer_value(&br->tcn_timer));
 }
-static DEVICE_ATTR(tcn_timer, S_IRUGO, show_tcn_timer, NULL);
+static DEVICE_ATTR_RO(tcn_timer);
 
-static ssize_t show_topology_change_timer(struct device *d,
+static ssize_t topology_change_timer_show(struct device *d,
 					  struct device_attribute *attr,
 					  char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%ld\n", br_timer_value(&br->topology_change_timer));
 }
-static DEVICE_ATTR(topology_change_timer, S_IRUGO, show_topology_change_timer,
-		   NULL);
+static DEVICE_ATTR_RO(topology_change_timer);
 
-static ssize_t show_gc_timer(struct device *d, struct device_attribute *attr,
+static ssize_t gc_timer_show(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%ld\n", br_timer_value(&br->gc_timer));
 }
-static DEVICE_ATTR(gc_timer, S_IRUGO, show_gc_timer, NULL);
+static DEVICE_ATTR_RO(gc_timer);
 
-static ssize_t show_group_addr(struct device *d,
+static ssize_t group_addr_show(struct device *d,
 			       struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -293,7 +288,7 @@ static ssize_t show_group_addr(struct device *d,
 		       br->group_addr[4], br->group_addr[5]);
 }
 
-static ssize_t store_group_addr(struct device *d,
+static ssize_t group_addr_store(struct device *d,
 				struct device_attribute *attr,
 				const char *buf, size_t len)
 {
@@ -324,10 +319,9 @@ static ssize_t store_group_addr(struct device *d,
 	return len;
 }
 
-static DEVICE_ATTR(group_addr, S_IRUGO | S_IWUSR,
-		   show_group_addr, store_group_addr);
+static DEVICE_ATTR_RW(group_addr);
 
-static ssize_t store_flush(struct device *d,
+static ssize_t flush_store(struct device *d,
 			   struct device_attribute *attr,
 			   const char *buf, size_t len)
 {
@@ -339,26 +333,25 @@ static ssize_t store_flush(struct device *d,
 	br_fdb_flush(br);
 	return len;
 }
-static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
+static DEVICE_ATTR_WO(flush);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-static ssize_t show_multicast_router(struct device *d,
+static ssize_t multicast_router_show(struct device *d,
 				     struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%d\n", br->multicast_router);
 }
 
-static ssize_t store_multicast_router(struct device *d,
+static ssize_t multicast_router_store(struct device *d,
 				      struct device_attribute *attr,
 				      const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_multicast_set_router);
 }
-static DEVICE_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
-		   store_multicast_router);
+static DEVICE_ATTR_RW(multicast_router);
 
-static ssize_t show_multicast_snooping(struct device *d,
+static ssize_t multicast_snooping_show(struct device *d,
 				       struct device_attribute *attr,
 				       char *buf)
 {
@@ -366,18 +359,17 @@ static ssize_t show_multicast_snooping(struct device *d,
 	return sprintf(buf, "%d\n", !br->multicast_disabled);
 }
 
-static ssize_t store_multicast_snooping(struct device *d,
+static ssize_t multicast_snooping_store(struct device *d,
 					struct device_attribute *attr,
 					const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_multicast_toggle);
 }
-static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
-		   show_multicast_snooping, store_multicast_snooping);
+static DEVICE_ATTR_RW(multicast_snooping);
 
-static ssize_t show_multicast_query_use_ifaddr(struct device *d,
-				      struct device_attribute *attr,
-				      char *buf)
+static ssize_t multicast_query_use_ifaddr_show(struct device *d,
+					       struct device_attribute *attr,
+					       char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%d\n", br->multicast_query_use_ifaddr);
@@ -390,17 +382,15 @@ static int set_query_use_ifaddr(struct net_bridge *br, unsigned long val)
 }
 
 static ssize_t
-store_multicast_query_use_ifaddr(struct device *d,
+multicast_query_use_ifaddr_store(struct device *d,
 				 struct device_attribute *attr,
 				 const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_query_use_ifaddr);
 }
-static DEVICE_ATTR(multicast_query_use_ifaddr, S_IRUGO | S_IWUSR,
-		   show_multicast_query_use_ifaddr,
-		   store_multicast_query_use_ifaddr);
+static DEVICE_ATTR_RW(multicast_query_use_ifaddr);
 
-static ssize_t show_multicast_querier(struct device *d,
+static ssize_t multicast_querier_show(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
 {
@@ -408,16 +398,15 @@ static ssize_t show_multicast_querier(struct device *d,
 	return sprintf(buf, "%d\n", br->multicast_querier);
 }
 
-static ssize_t store_multicast_querier(struct device *d,
+static ssize_t multicast_querier_store(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_multicast_set_querier);
 }
-static DEVICE_ATTR(multicast_querier, S_IRUGO | S_IWUSR,
-		   show_multicast_querier, store_multicast_querier);
+static DEVICE_ATTR_RW(multicast_querier);
 
-static ssize_t show_hash_elasticity(struct device *d,
+static ssize_t hash_elasticity_show(struct device *d,
 				    struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -430,31 +419,29 @@ static int set_elasticity(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_hash_elasticity(struct device *d,
+static ssize_t hash_elasticity_store(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_elasticity);
 }
-static DEVICE_ATTR(hash_elasticity, S_IRUGO | S_IWUSR, show_hash_elasticity,
-		   store_hash_elasticity);
+static DEVICE_ATTR_RW(hash_elasticity);
 
-static ssize_t show_hash_max(struct device *d, struct device_attribute *attr,
+static ssize_t hash_max_show(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
 	return sprintf(buf, "%u\n", br->hash_max);
 }
 
-static ssize_t store_hash_max(struct device *d, struct device_attribute *attr,
+static ssize_t hash_max_store(struct device *d, struct device_attribute *attr,
 			      const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_multicast_set_hash_max);
 }
-static DEVICE_ATTR(hash_max, S_IRUGO | S_IWUSR, show_hash_max,
-		   store_hash_max);
+static DEVICE_ATTR_RW(hash_max);
 
-static ssize_t show_multicast_last_member_count(struct device *d,
+static ssize_t multicast_last_member_count_show(struct device *d,
 						struct device_attribute *attr,
 						char *buf)
 {
@@ -468,17 +455,15 @@ static int set_last_member_count(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_last_member_count(struct device *d,
+static ssize_t multicast_last_member_count_store(struct device *d,
 						 struct device_attribute *attr,
 						 const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_last_member_count);
 }
-static DEVICE_ATTR(multicast_last_member_count, S_IRUGO | S_IWUSR,
-		   show_multicast_last_member_count,
-		   store_multicast_last_member_count);
+static DEVICE_ATTR_RW(multicast_last_member_count);
 
-static ssize_t show_multicast_startup_query_count(
+static ssize_t multicast_startup_query_count_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -491,17 +476,15 @@ static int set_startup_query_count(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_startup_query_count(
+static ssize_t multicast_startup_query_count_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_startup_query_count);
 }
-static DEVICE_ATTR(multicast_startup_query_count, S_IRUGO | S_IWUSR,
-		   show_multicast_startup_query_count,
-		   store_multicast_startup_query_count);
+static DEVICE_ATTR_RW(multicast_startup_query_count);
 
-static ssize_t show_multicast_last_member_interval(
+static ssize_t multicast_last_member_interval_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -515,17 +498,15 @@ static int set_last_member_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_last_member_interval(
+static ssize_t multicast_last_member_interval_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_last_member_interval);
 }
-static DEVICE_ATTR(multicast_last_member_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_last_member_interval,
-		   store_multicast_last_member_interval);
+static DEVICE_ATTR_RW(multicast_last_member_interval);
 
-static ssize_t show_multicast_membership_interval(
+static ssize_t multicast_membership_interval_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -539,17 +520,15 @@ static int set_membership_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_membership_interval(
+static ssize_t multicast_membership_interval_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_membership_interval);
 }
-static DEVICE_ATTR(multicast_membership_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_membership_interval,
-		   store_multicast_membership_interval);
+static DEVICE_ATTR_RW(multicast_membership_interval);
 
-static ssize_t show_multicast_querier_interval(struct device *d,
+static ssize_t multicast_querier_interval_show(struct device *d,
 					       struct device_attribute *attr,
 					       char *buf)
 {
@@ -564,17 +543,15 @@ static int set_querier_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_querier_interval(struct device *d,
+static ssize_t multicast_querier_interval_store(struct device *d,
 						struct device_attribute *attr,
 						const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_querier_interval);
 }
-static DEVICE_ATTR(multicast_querier_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_querier_interval,
-		   store_multicast_querier_interval);
+static DEVICE_ATTR_RW(multicast_querier_interval);
 
-static ssize_t show_multicast_query_interval(struct device *d,
+static ssize_t multicast_query_interval_show(struct device *d,
 					     struct device_attribute *attr,
 					     char *buf)
 {
@@ -589,17 +566,15 @@ static int set_query_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_query_interval(struct device *d,
+static ssize_t multicast_query_interval_store(struct device *d,
 					      struct device_attribute *attr,
 					      const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_query_interval);
 }
-static DEVICE_ATTR(multicast_query_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_query_interval,
-		   store_multicast_query_interval);
+static DEVICE_ATTR_RW(multicast_query_interval);
 
-static ssize_t show_multicast_query_response_interval(
+static ssize_t multicast_query_response_interval_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -614,17 +589,15 @@ static int set_query_response_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_query_response_interval(
+static ssize_t multicast_query_response_interval_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_query_response_interval);
 }
-static DEVICE_ATTR(multicast_query_response_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_query_response_interval,
-		   store_multicast_query_response_interval);
+static DEVICE_ATTR_RW(multicast_query_response_interval);
 
-static ssize_t show_multicast_startup_query_interval(
+static ssize_t multicast_startup_query_interval_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -639,18 +612,16 @@ static int set_startup_query_interval(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_multicast_startup_query_interval(
+static ssize_t multicast_startup_query_interval_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_startup_query_interval);
 }
-static DEVICE_ATTR(multicast_startup_query_interval, S_IRUGO | S_IWUSR,
-		   show_multicast_startup_query_interval,
-		   store_multicast_startup_query_interval);
+static DEVICE_ATTR_RW(multicast_startup_query_interval);
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
-static ssize_t show_nf_call_iptables(
+static ssize_t nf_call_iptables_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -663,16 +634,15 @@ static int set_nf_call_iptables(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_nf_call_iptables(
+static ssize_t nf_call_iptables_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_nf_call_iptables);
 }
-static DEVICE_ATTR(nf_call_iptables, S_IRUGO | S_IWUSR,
-		   show_nf_call_iptables, store_nf_call_iptables);
+static DEVICE_ATTR_RW(nf_call_iptables);
 
-static ssize_t show_nf_call_ip6tables(
+static ssize_t nf_call_ip6tables_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -685,16 +655,15 @@ static int set_nf_call_ip6tables(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_nf_call_ip6tables(
+static ssize_t nf_call_ip6tables_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_nf_call_ip6tables);
 }
-static DEVICE_ATTR(nf_call_ip6tables, S_IRUGO | S_IWUSR,
-		   show_nf_call_ip6tables, store_nf_call_ip6tables);
+static DEVICE_ATTR_RW(nf_call_ip6tables);
 
-static ssize_t show_nf_call_arptables(
+static ssize_t nf_call_arptables_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
@@ -707,17 +676,16 @@ static int set_nf_call_arptables(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-static ssize_t store_nf_call_arptables(
+static ssize_t nf_call_arptables_store(
 	struct device *d, struct device_attribute *attr, const char *buf,
 	size_t len)
 {
 	return store_bridge_parm(d, buf, len, set_nf_call_arptables);
 }
-static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
-		   show_nf_call_arptables, store_nf_call_arptables);
+static DEVICE_ATTR_RW(nf_call_arptables);
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-static ssize_t show_vlan_filtering(struct device *d,
+static ssize_t vlan_filtering_show(struct device *d,
 				   struct device_attribute *attr,
 				   char *buf)
 {
@@ -725,14 +693,13 @@ static ssize_t show_vlan_filtering(struct device *d,
 	return sprintf(buf, "%d\n", br->vlan_enabled);
 }
 
-static ssize_t store_vlan_filtering(struct device *d,
+static ssize_t vlan_filtering_store(struct device *d,
 				    struct device_attribute *attr,
 				    const char *buf, size_t len)
 {
 	return store_bridge_parm(d, buf, len, br_vlan_filter_toggle);
 }
-static DEVICE_ATTR(vlan_filtering, S_IRUGO | S_IWUSR,
-		   show_vlan_filtering, store_vlan_filtering);
+static DEVICE_ATTR_RW(vlan_filtering);
 #endif
 
 static struct attribute *bridge_attrs[] = {
