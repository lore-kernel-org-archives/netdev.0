From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 16:08:21 +0200
Message-ID: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: linux-wireles@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20827 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbcBKOIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 09:08:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
 include/net/codel.h | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index 267e702..0775c24 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -92,18 +92,18 @@ struct codel_skb_cb {
 	codel_time_t enqueue_time;
 };
 
-static struct codel_skb_cb *get_codel_cb(const struct sk_buff *skb)
+static inline struct codel_skb_cb *get_codel_cb(const struct sk_buff *skb)
 {
 	qdisc_cb_private_validate(skb, sizeof(struct codel_skb_cb));
 	return (struct codel_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
-static codel_time_t codel_get_enqueue_time(const struct sk_buff *skb)
+static inline codel_time_t codel_get_enqueue_time(const struct sk_buff *skb)
 {
 	return get_codel_cb(skb)->enqueue_time;
 }
 
-static void codel_set_enqueue_time(struct sk_buff *skb)
+static inline void codel_set_enqueue_time(struct sk_buff *skb)
 {
 	get_codel_cb(skb)->enqueue_time = codel_get_time();
 }
@@ -174,8 +174,8 @@ struct codel_stats {
 
 #define CODEL_DISABLED_THRESHOLD INT_MAX
 
-static void codel_params_init(struct codel_params *params,
-			      const struct Qdisc *sch)
+static inline void codel_params_init(struct codel_params *params,
+				     const struct Qdisc *sch)
 {
 	params->interval = MS2TIME(100);
 	params->target = MS2TIME(5);
@@ -184,12 +184,12 @@ static void codel_params_init(struct codel_params *params,
 	params->ecn = false;
 }
 
-static void codel_vars_init(struct codel_vars *vars)
+static inline void codel_vars_init(struct codel_vars *vars)
 {
 	memset(vars, 0, sizeof(*vars));
 }
 
-static void codel_stats_init(struct codel_stats *stats)
+static inline void codel_stats_init(struct codel_stats *stats)
 {
 	stats->maxpacket = 0;
 }
@@ -200,7 +200,7 @@ static void codel_stats_init(struct codel_stats *stats)
  *
  * Here, invsqrt is a fixed point number (< 1.0), 32bit mantissa, aka Q0.32
  */
-static void codel_Newton_step(struct codel_vars *vars)
+static inline void codel_Newton_step(struct codel_vars *vars)
 {
 	u32 invsqrt = ((u32)vars->rec_inv_sqrt) << REC_INV_SQRT_SHIFT;
 	u32 invsqrt2 = ((u64)invsqrt * invsqrt) >> 32;
@@ -217,19 +217,19 @@ static void codel_Newton_step(struct codel_vars *vars)
  * We maintain in rec_inv_sqrt the reciprocal value of sqrt(count) to avoid
  * both sqrt() and divide operation.
  */
-static codel_time_t codel_control_law(codel_time_t t,
-				      codel_time_t interval,
-				      u32 rec_inv_sqrt)
+static inline codel_time_t codel_control_law(codel_time_t t,
+					     codel_time_t interval,
+					     u32 rec_inv_sqrt)
 {
 	return t + reciprocal_scale(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
 }
 
-static bool codel_should_drop(const struct sk_buff *skb,
-			      struct Qdisc *sch,
-			      struct codel_vars *vars,
-			      struct codel_params *params,
-			      struct codel_stats *stats,
-			      codel_time_t now)
+static inline bool codel_should_drop(const struct sk_buff *skb,
+				     struct Qdisc *sch,
+				     struct codel_vars *vars,
+				     struct codel_params *params,
+				     struct codel_stats *stats,
+				     codel_time_t now)
 {
 	bool ok_to_drop;
 
@@ -265,11 +265,11 @@ static bool codel_should_drop(const struct sk_buff *skb,
 typedef struct sk_buff * (*codel_skb_dequeue_t)(struct codel_vars *vars,
 						struct Qdisc *sch);
 
-static struct sk_buff *codel_dequeue(struct Qdisc *sch,
-				     struct codel_params *params,
-				     struct codel_vars *vars,
-				     struct codel_stats *stats,
-				     codel_skb_dequeue_t dequeue_func)
+static inline struct sk_buff *codel_dequeue(struct Qdisc *sch,
+					    struct codel_params *params,
+					    struct codel_vars *vars,
+					    struct codel_stats *stats,
+					    codel_skb_dequeue_t dequeue_func)
 {
 	struct sk_buff *skb = dequeue_func(vars, sch);
 	codel_time_t now;
-- 
2.5.0
