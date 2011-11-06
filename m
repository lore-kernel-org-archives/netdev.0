From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 12/11] sch_hfsc.c: converter fixups
Date: Sun,  6 Nov 2011 02:09:23 +0100
Message-ID: <1320541763-17370-1-git-send-email-soltys@ziu.info>
References: <1320460377-8682-9-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:17724 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193Ab1KFBJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 21:09:31 -0400
In-Reply-To: <1320460377-8682-9-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove WARN_ON()s added in earlier commit, as the cases they are
supposed to warn about are purely theoretical (would require - aside
from extreme input values - much smaller SM_SHIFT (sm<->m) and larger
PSCHED_SHIFT (dx<->d)).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 05cecc0..d0cef0f 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -407,12 +407,7 @@ cftree_update(struct hfsc_class *cl)
  * 2) initialization functions: m2sm, m2ism, d2dx, dx2d
  *
  * These are used only during [re]setup/reports. Nothing particulary special
- * about those, as user input is limited to 32bit. One remark though:
- *
- * Theoretically, due to rounding up in d2dx() and m2sm(), it's possible that
- * in dx2d() and sm2m() we could overflow as well, but that would require input
- * values near 2^32-1 provided during d2dx() and m2sm(). Just in case, we catch
- * that possibility with WARN_ON().
+ * about those, as user input is limited to 32bit.
  *
  * 3) rtsc_min
  *
@@ -481,7 +476,6 @@ seg_y2x(u64 y, u64 ism)
 static u64
 m2sm(u32 m)
 {
-	WARN_ON(m & (1<<31));
 	return div_u64(((u64)m << SM_SHIFT) + PTPS - 1, PTPS);
 }
 
@@ -510,7 +504,6 @@ m2ism(u32 m)
 static u64
 d2dx(u32 d)
 {
-	WARN_ON(d & (1<<31));
 	return div_u64(((u64)d * PTPS) + USPS - 1, USPS);
 }
 
-- 
1.7.7.1
