From: kaber@trash.net
Subject: [PATCH 32/79] netfilter: xtables: use guarded types
Date: Wed, 19 Jan 2011 20:14:32 +0100
Message-ID: <1295464519-21763-33-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab1ASTPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:30 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

We are supposed to use the kernel's own types in userspace exports.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_CT.h          |   10 +++++-----
 include/linux/netfilter/xt_TCPOPTSTRIP.h |    2 +-
 include/linux/netfilter/xt_TPROXY.h      |    8 ++++----
 include/linux/netfilter/xt_cluster.h     |    8 ++++----
 include/linux/netfilter/xt_quota.h       |    6 +++---
 include/linux/netfilter/xt_time.h        |   14 +++++++-------
 include/linux/netfilter/xt_u32.h         |   16 ++++++++--------
 7 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
index 1b56410..fbf4c56 100644
--- a/include/linux/netfilter/xt_CT.h
+++ b/include/linux/netfilter/xt_CT.h
@@ -4,11 +4,11 @@
 #define XT_CT_NOTRACK	0x1
 
 struct xt_ct_target_info {
-	u_int16_t	flags;
-	u_int16_t	zone;
-	u_int32_t	ct_events;
-	u_int32_t	exp_events;
-	char		helper[16];
+	__u16 flags;
+	__u16 zone;
+	__u32 ct_events;
+	__u32 exp_events;
+	char helper[16];
 
 	/* Used internally by the kernel */
 	struct nf_conn	*ct __attribute__((aligned(8)));
diff --git a/include/linux/netfilter/xt_TCPOPTSTRIP.h b/include/linux/netfilter/xt_TCPOPTSTRIP.h
index 2db5432..342ef14 100644
--- a/include/linux/netfilter/xt_TCPOPTSTRIP.h
+++ b/include/linux/netfilter/xt_TCPOPTSTRIP.h
@@ -7,7 +7,7 @@
 	(((1U << (idx & 31)) & bmap[(idx) >> 5]) != 0)
 
 struct xt_tcpoptstrip_target_info {
-	u_int32_t strip_bmap[8];
+	__u32 strip_bmap[8];
 };
 
 #endif /* _XT_TCPOPTSTRIP_H */
diff --git a/include/linux/netfilter/xt_TPROXY.h b/include/linux/netfilter/xt_TPROXY.h
index 3f3d693..8097e0b 100644
--- a/include/linux/netfilter/xt_TPROXY.h
+++ b/include/linux/netfilter/xt_TPROXY.h
@@ -5,15 +5,15 @@
  * redirection. We can get rid of that whenever we get support for
  * mutliple targets in the same rule. */
 struct xt_tproxy_target_info {
-	u_int32_t mark_mask;
-	u_int32_t mark_value;
+	__u32 mark_mask;
+	__u32 mark_value;
 	__be32 laddr;
 	__be16 lport;
 };
 
 struct xt_tproxy_target_info_v1 {
-	u_int32_t mark_mask;
-	u_int32_t mark_value;
+	__u32 mark_mask;
+	__u32 mark_value;
 	union nf_inet_addr laddr;
 	__be16 lport;
 };
diff --git a/include/linux/netfilter/xt_cluster.h b/include/linux/netfilter/xt_cluster.h
index 8866826..66cfa3c 100644
--- a/include/linux/netfilter/xt_cluster.h
+++ b/include/linux/netfilter/xt_cluster.h
@@ -6,10 +6,10 @@ enum xt_cluster_flags {
 };
 
 struct xt_cluster_match_info {
-	u_int32_t		total_nodes;
-	u_int32_t		node_mask;
-	u_int32_t		hash_seed;
-	u_int32_t		flags;
+	__u32 total_nodes;
+	__u32 node_mask;
+	__u32 hash_seed;
+	__u32 flags;
 };
 
 #define XT_CLUSTER_NODES_MAX	32
diff --git a/include/linux/netfilter/xt_quota.h b/include/linux/netfilter/xt_quota.h
index b0d28c6..8bda65f 100644
--- a/include/linux/netfilter/xt_quota.h
+++ b/include/linux/netfilter/xt_quota.h
@@ -9,9 +9,9 @@ enum xt_quota_flags {
 struct xt_quota_priv;
 
 struct xt_quota_info {
-	u_int32_t		flags;
-	u_int32_t		pad;
-	aligned_u64		quota;
+	__u32 flags;
+	__u32 pad;
+	aligned_u64 quota;
 
 	/* Used internally by the kernel */
 	struct xt_quota_priv	*master;
diff --git a/include/linux/netfilter/xt_time.h b/include/linux/netfilter/xt_time.h
index 14b6df4..b8bd456 100644
--- a/include/linux/netfilter/xt_time.h
+++ b/include/linux/netfilter/xt_time.h
@@ -2,13 +2,13 @@
 #define _XT_TIME_H 1
 
 struct xt_time_info {
-	u_int32_t date_start;
-	u_int32_t date_stop;
-	u_int32_t daytime_start;
-	u_int32_t daytime_stop;
-	u_int32_t monthdays_match;
-	u_int8_t weekdays_match;
-	u_int8_t flags;
+	__u32 date_start;
+	__u32 date_stop;
+	__u32 daytime_start;
+	__u32 daytime_stop;
+	__u32 monthdays_match;
+	__u8 weekdays_match;
+	__u8 flags;
 };
 
 enum {
diff --git a/include/linux/netfilter/xt_u32.h b/include/linux/netfilter/xt_u32.h
index 9947f56..e8c3d87 100644
--- a/include/linux/netfilter/xt_u32.h
+++ b/include/linux/netfilter/xt_u32.h
@@ -9,13 +9,13 @@ enum xt_u32_ops {
 };
 
 struct xt_u32_location_element {
-	u_int32_t number;
-	u_int8_t nextop;
+	__u32 number;
+	__u8 nextop;
 };
 
 struct xt_u32_value_element {
-	u_int32_t min;
-	u_int32_t max;
+	__u32 min;
+	__u32 max;
 };
 
 /*
@@ -27,14 +27,14 @@ struct xt_u32_value_element {
 struct xt_u32_test {
 	struct xt_u32_location_element location[XT_U32_MAXSIZE+1];
 	struct xt_u32_value_element value[XT_U32_MAXSIZE+1];
-	u_int8_t nnums;
-	u_int8_t nvalues;
+	__u8 nnums;
+	__u8 nvalues;
 };
 
 struct xt_u32 {
 	struct xt_u32_test tests[XT_U32_MAXSIZE+1];
-	u_int8_t ntests;
-	u_int8_t invert;
+	__u8 ntests;
+	__u8 invert;
 };
 
 #endif /* _XT_U32_H */
-- 
1.7.2.3

