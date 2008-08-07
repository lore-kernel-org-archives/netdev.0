From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] sch_prio: Use return value from inner qdisc requeue
Date: Fri, 08 Aug 2008 01:10:14 +0300
Message-ID: <20080807221014.32639.89849.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:58976 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbYHGWKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 18:10:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use return value from inner qdisc requeue when value returned isn't
NET_XMIT_SUCCESS, instead of always returning NET_XMIT_DROP.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 net/sched/sch_prio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index eac1976..7cdc3e6 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -117,7 +117,7 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 	if (net_xmit_drop_count(ret))
 		sch->qstats.drops++;
-	return NET_XMIT_DROP;
+	return ret;
 }
 
 

