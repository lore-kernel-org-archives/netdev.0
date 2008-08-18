From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_prio: Use return value from inner qdisc requeue
Date: Sun, 17 Aug 2008 22:45:29 -0700 (PDT)
Message-ID: <20080817.224529.236814631.davem@davemloft.net>
References: <20080807221014.32639.89849.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbYHRFp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 01:45:29 -0400
In-Reply-To: <20080807221014.32639.89849.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Fri, 08 Aug 2008 01:10:14 +0300

> Use return value from inner qdisc requeue when value returned isn't
> NET_XMIT_SUCCESS, instead of always returning NET_XMIT_DROP.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied, thanks Jussi.

I added the following followon patch afterwards:

sch_prio: Use NET_XMIT_SUCCESS instead of "0" constant.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_prio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 7cdc3e6..a6697c6 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -113,7 +113,7 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	if ((ret = qdisc->ops->requeue(skb, qdisc)) == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))
 		sch->qstats.drops++;
-- 
1.5.6.5.GIT

