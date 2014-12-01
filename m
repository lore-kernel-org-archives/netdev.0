From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/4] openvswitch: Fix coding style.
Date: Mon,  1 Dec 2014 14:30:51 -0800
Message-ID: <1417473051-2223-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:35325 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932477AbaLAWax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:30:53 -0500
Received: by mail-pd0-f174.google.com with SMTP id w10so11778071pde.33
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:30:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes comment style issues, removes redundant egress_tun_info
reset.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c      |    3 +--
 net/openvswitch/datapath.c     |   11 ++++++-----
 net/openvswitch/flow.c         |   11 ++++++-----
 net/openvswitch/flow_netlink.c |   12 +++++++-----
 net/openvswitch/flow_table.c   |    3 ++-
 5 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 770064c..453d5b8 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -90,7 +90,7 @@ static struct deferred_action *action_fifo_put(struct action_fifo *fifo)
 	return &fifo->fifo[fifo->head++];
 }
 
-/* Return true if fifo is not full */
+/* Return queue entry if fifo is not full */
 static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 						    const struct sw_flow_key *key,
 						    const struct nlattr *attr)
@@ -872,7 +872,6 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	int err;
 
 	this_cpu_inc(exec_actions_level);
-	OVS_CB(skb)->egress_tun_info = NULL;
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 332b5a0..55ce8c8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -78,7 +78,8 @@ static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
 };
 
 /* Check if need to build a reply message.
- * OVS userspace sets the NLM_F_ECHO flag if it needs the reply. */
+ * OVS userspace sets the NLM_F_ECHO flag if it needs the reply.
+ */
 static bool ovs_must_notify(struct genl_family *family, struct genl_info *info,
 			    unsigned int group)
 {
@@ -481,7 +482,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	/* Only reserve room for attribute header, packet data is added
-	 * in skb_zerocopy() */
+	 * in skb_zerocopy()
+	 */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
 		err = -ENOBUFS;
 		goto out;
@@ -546,7 +548,8 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	/* Normally, setting the skb 'protocol' field would be handled by a
 	 * call to eth_type_trans(), but it assumes there's a sending
-	 * device, which we may not have. */
+	 * device, which we may not have.
+	 */
 	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		packet->protocol = eth->h_proto;
 	else
@@ -1894,7 +1897,6 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 			goto exit_unlock_free;
 	}
 
-
 	if (a[OVS_VPORT_ATTR_UPCALL_PID]) {
 		struct nlattr *ids = a[OVS_VPORT_ATTR_UPCALL_PID];
 
@@ -1906,7 +1908,6 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
 	BUG_ON(err < 0);
-
 	ovs_unlock();
 	ovs_notify(&dp_vport_genl_family, reply, info);
 	return 0;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 70bef2a..96480fe 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -552,7 +552,8 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 				struct icmphdr *icmp = icmp_hdr(skb);
 				/* The ICMP type and code fields use the 16-bit
 				 * transport port fields, so we need to store
-				 * them in 16-bit network byte order. */
+				 * them in 16-bit network byte order.
+				 */
 				key->tp.src = htons(icmp->type);
 				key->tp.dst = htons(icmp->code);
 			} else {
@@ -686,17 +687,17 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 	if (tun_info) {
 		memcpy(&key->tun_key, &tun_info->tunnel, sizeof(key->tun_key));
 
+		BUILD_BUG_ON(((1 << (sizeof(tun_info->options_len) * 8)) - 1) >
+			     sizeof(key->tun_opts));
+
 		if (tun_info->options) {
-			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
-						   8)) - 1
-					> sizeof(key->tun_opts));
 			memcpy(GENEVE_OPTS(key, tun_info->options_len),
 			       tun_info->options, tun_info->options_len);
 			key->tun_opts_len = tun_info->options_len;
 		} else {
 			key->tun_opts_len = 0;
 		}
-	} else  {
+	} else {
 		key->tun_opts_len = 0;
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
 	}
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index df3c7f2..3c92a86 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -18,8 +18,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include "flow.h"
-#include "datapath.h"
 #include <linux/uaccess.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -48,6 +46,8 @@
 #include <net/ndisc.h>
 #include <net/mpls.h>
 
+#include "datapath.h"
+#include "flow.h"
 #include "flow_netlink.h"
 
 static void update_range(struct sw_flow_match *match,
@@ -118,7 +118,8 @@ static bool match_validate(const struct sw_flow_match *match,
 	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
 
 	/* The following mask attributes allowed only if they
-	 * pass the validation tests. */
+	 * pass the validation tests.
+	 */
 	mask_allowed &= ~((1 << OVS_KEY_ATTR_IPV4)
 			| (1 << OVS_KEY_ATTR_IPV6)
 			| (1 << OVS_KEY_ATTR_TCP)
@@ -833,7 +834,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				mpls_key->mpls_lse, is_mask);
 
 		attrs &= ~(1 << OVS_KEY_ATTR_MPLS);
-	 }
+	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_TCP)) {
 		const struct ovs_key_tcp *tcp_key;
@@ -1366,7 +1367,8 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 }
 
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
- * The caller must hold rcu_read_lock for this to be sensible. */
+ * The caller must hold rcu_read_lock for this to be sensible.
+ */
 void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
 {
 	kfree_rcu(sf_acts, rcu);
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e0a7fef..d40fdb2 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -617,7 +617,8 @@ int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 }
 
 /* Initializes the flow module.
- * Returns zero if successful or a negative error code. */
+ * Returns zero if successful or a negative error code.
+ */
 int ovs_flow_init(void)
 {
 	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
-- 
1.7.1
