From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] net: sched: Cleanup PIE comments
Date: Wed, 12 Feb 2014 18:58:21 -0800
Message-ID: <1392260301-8340-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Mythili Prabhu <mysuryan@cisco.com>,
	Norbert Kiesel <nkiesel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:65190 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbaBMDDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 22:03:21 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so10131422pbc.16
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 19:03:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <vijaynsu@cisco.com>

Fix incorrect comment reported by Norbert Kiesel. Edit another comment to add
more details. Also add references to algorithm (IETF draft and paper) to top of
file.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
CC: Mythili Prabhu <mysuryan@cisco.com>
CC: Norbert Kiesel <nkiesel@gmail.com>
---
 net/sched/sch_pie.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index a255d02..fefeeb7 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -15,6 +15,11 @@
  *
  * ECN support is added by Naeem Khademi <naeemk@ifi.uio.no>
  * University of Oslo, Norway.
+ *
+ * References:
+ * IETF draft submission: http://tools.ietf.org/html/draft-pan-aqm-pie-00
+ * IEEE  Conference on High Performance Switching and Routing 2013 :
+ * "PIE: A * Lightweight Control Scheme to Address the Bufferbloat Problem"
  */
 
 #include <linux/module.h>
@@ -36,7 +41,7 @@ struct pie_params {
 	psched_time_t target;	/* user specified target delay in pschedtime */
 	u32 tupdate;		/* timer frequency (in jiffies) */
 	u32 limit;		/* number of packets that can be enqueued */
-	u32 alpha;		/* alpha and beta are between -4 and 4 */
+	u32 alpha;		/* alpha and beta are between 0 and 32 */
 	u32 beta;		/* and are used for shift relative to 1 */
 	bool ecn;		/* true if ecn is enabled */
 	bool bytemode;		/* to scale drop early prob based on pkt size */
@@ -326,10 +331,16 @@ static void calculate_probability(struct Qdisc *sch)
 	if (qdelay == 0 && qlen != 0)
 		update_prob = false;
 
-	/* Add ranges for alpha and beta, more aggressive for high dropping
-	 * mode and gentle steps for light dropping mode
-	 * In light dropping mode, take gentle steps; in medium dropping mode,
-	 * take medium steps; in high dropping mode, take big steps.
+	/* In the algorithm, alpha and beta are between 0 and 2 with typical
+	 * value for alpha as 0.125. In this implementation, we use values 0-32
+	 * passed from user space to represent this. Also, alpha and beta have
+	 * unit of HZ and need to be scaled before they can used to update
+	 * probability. alpha/beta are updated locally below by 1) scaling them
+	 * appropriately 2) scaling down by 16 to come to 0-2 range.
+	 * Please see paper for details.
+	 *
+	 * We scale alpha and beta differently depending on whether we are in
+	 * light, medium or high dropping mode.
 	 */
 	if (q->vars.prob < MAX_PROB / 100) {
 		alpha =
-- 
1.7.9.5
