From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/5] netem: report reorder percent correctly.
Date: Wed, 21 Mar 2007 10:42:32 -0700
Message-ID: <20070321174422.477444857@linux-foundation.org>
References: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46929 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933297AbXCUR7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:59:02 -0400
Content-Disposition: inline; filename=netem-report-reorder
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If you setup netem to just delay packets; "tc qdisc ls" will report
the reordering as 100%. Well it's a lie, reorder isn't used unless
gap is set, so just set value to 0 so the output of utility
is correct.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/sched/sch_netem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- net-2.6.22.orig/net/sched/sch_netem.c
+++ net-2.6.22/net/sched/sch_netem.c
@@ -428,7 +428,8 @@ static int netem_change(struct Qdisc *sc
 	/* for compatiablity with earlier versions.
 	 * if gap is set, need to assume 100% probablity
 	 */
-	q->reorder = ~0;
+	if (q->gap)
+		q->reorder = ~0;
 
 	/* Handle nested options after initial queue options.
 	 * Should have put all options in nested format but too late now.

-- 

