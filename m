From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/9] netfilter: use IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
Date: Fri,  3 Oct 2014 19:20:18 +0200
Message-ID: <1412356824-6362-4-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 34666d4 ("netfilter: bridge: move br_netfilter out of the core"),
the bridge netfilter code has been modularized.

Use IS_ENABLED instead of ifdef to cover the module case.

Fixes: 34666d4 ("netfilter: bridge: move br_netfilter out of the core")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/core/skbuff.c                          |    2 +-
 net/ipv4/ip_output.c                       |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c            |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c        |    2 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c |    4 ++--
 net/netfilter/nf_log_common.c              |    2 +-
 net/netfilter/nf_queue.c                   |    4 ++--
 net/netfilter/nfnetlink_log.c              |    8 ++++----
 net/netfilter/nfnetlink_queue_core.c       |   12 ++++++------
 10 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4be570a..7de3d67 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -566,7 +566,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
 #endif
 /* XXX: IS this still necessary? - JHS */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c8fa624..e35b712 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -516,7 +516,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	hlen = iph->ihl * 4;
 	mtu = mtu - hlen;	/* Size of data space */
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge)
 		mtu -= nf_bridge_mtu_reduction(skb);
 #endif
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 5b6e0df..8f48f55 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -20,7 +20,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv4/ipt_REJECT.h>
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 #include <linux/netfilter_bridge.h>
 #endif
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 76bd1ae..7e5ca6f 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -50,7 +50,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge &&
 	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
 		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 7b9a748..e70382e 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -40,7 +40,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge &&
 	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
 		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 03cdb69..35dd358 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -237,7 +237,7 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 #define SRCDIR		(opt->flags & IPSET_DIM_TWO_SRC)
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		const struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
 		if (!nf_bridge)
@@ -474,7 +474,7 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	ip6_netmask(&e.ip, e.cidr);
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		const struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
 		if (!nf_bridge)
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index eeb8ef4..a2233e7 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -158,7 +158,7 @@ nf_log_dump_packet_common(struct nf_log_buf *m, u_int8_t pf,
 	       '0' + loginfo->u.log.level, prefix,
 	       in ? in->name : "",
 	       out ? out->name : "");
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge) {
 		const struct net_device *physindev;
 		const struct net_device *physoutdev;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 5d24b1f..4c8b68e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -52,7 +52,7 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 		dev_put(entry->indev);
 	if (entry->outdev)
 		dev_put(entry->outdev);
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
 
@@ -77,7 +77,7 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 		dev_hold(entry->indev);
 	if (entry->outdev)
 		dev_hold(entry->outdev);
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
 		struct net_device *physdev;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index a11c5ff..b1e3a05 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -36,7 +36,7 @@
 
 #include <linux/atomic.h>
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 #include "../bridge/br_private.h"
 #endif
 
@@ -429,7 +429,7 @@ __build_packet_message(struct nfnl_log_net *log,
 		goto nla_put_failure;
 
 	if (indev) {
-#ifndef CONFIG_BRIDGE_NETFILTER
+#if !IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		if (nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
 				 htonl(indev->ifindex)))
 			goto nla_put_failure;
@@ -460,7 +460,7 @@ __build_packet_message(struct nfnl_log_net *log,
 	}
 
 	if (outdev) {
-#ifndef CONFIG_BRIDGE_NETFILTER
+#if !IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		if (nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
 				 htonl(outdev->ifindex)))
 			goto nla_put_failure;
@@ -640,7 +640,7 @@ nfulnl_log_packet(struct net *net,
 		+ nla_total_size(sizeof(struct nfulnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 #endif
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 108120f..a82077d 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -36,7 +36,7 @@
 
 #include <linux/atomic.h>
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 #include "../bridge/br_private.h"
 #endif
 
@@ -302,7 +302,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 #endif
@@ -380,7 +380,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 
 	indev = entry->indev;
 	if (indev) {
-#ifndef CONFIG_BRIDGE_NETFILTER
+#if !IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		if (nla_put_be32(skb, NFQA_IFINDEX_INDEV, htonl(indev->ifindex)))
 			goto nla_put_failure;
 #else
@@ -410,7 +410,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	}
 
 	if (outdev) {
-#ifndef CONFIG_BRIDGE_NETFILTER
+#if !IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		if (nla_put_be32(skb, NFQA_IFINDEX_OUTDEV, htonl(outdev->ifindex)))
 			goto nla_put_failure;
 #else
@@ -569,7 +569,7 @@ nf_queue_entry_dup(struct nf_queue_entry *e)
 	return NULL;
 }
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 /* When called from bridge netfilter, skb->data must point to MAC header
  * before calling skb_gso_segment(). Else, original MAC header is lost
  * and segmented skbs will be sent to wrong destination.
@@ -763,7 +763,7 @@ dev_cmp(struct nf_queue_entry *entry, unsigned long ifindex)
 	if (entry->outdev)
 		if (entry->outdev->ifindex == ifindex)
 			return 1;
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		if (entry->skb->nf_bridge->physindev &&
 		    entry->skb->nf_bridge->physindev->ifindex == ifindex)
-- 
1.7.10.4

