From: David Miller <davem@davemloft.net>
Subject: [PATCH 30/31]: pkt_sched: Don't used locked skb_queue_purge() in
 __qdisc_reset_queue()
Date: Thu, 17 Jul 2008 05:18:30 -0700 (PDT)
Message-ID: <20080717.051830.85610334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759192AbYGQMSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:18:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have to have exclusive access to the given qdisc anyways, so
doing even more locking is superfluous.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2902a42..0a158ff 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -374,7 +374,7 @@ static inline void __qdisc_reset_queue(struct Qdisc *sch,
 	 * We do not know the backlog in bytes of this list, it
 	 * is up to the caller to correct it
 	 */
-	skb_queue_purge(list);
+	__skb_queue_purge(list);
 }
 
 static inline void qdisc_reset_queue(struct Qdisc *sch)
-- 
1.5.6.2.255.gbed62

