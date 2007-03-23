From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/11]: sch_netem: fix off-by-one in send time comparison
Date: Fri, 23 Mar 2007 14:35:40 +0100 (MET)
Message-ID: <20070323133514.10264.46311.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61414 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934055AbXCWNfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:41 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_netem: fix off-by-one in send time comparison

netem checks PSCHED_TLESS(cb->time_to_send, now) to find out whether it is
allowed to send a packet, which is equivalent to cb->time_to_send < now.
Use !PSCHED_TLESS(now, cb->time_to_send) instead to properly handle
cb->time_to_send == now.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9f8c07452088f432c79ac3a8d87d6adebcce57df
tree 42b214f74b8b2d5bd3065e9f63d8048beb4f3bdc
parent 3231f075945001667eafaf325abab8c992b3d1e4
author Patrick McHardy <kaber@trash.net> Thu, 22 Mar 2007 23:57:32 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:26 +0100

 net/sched/sch_netem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3e1b633..bc42843 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -286,7 +286,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 		/* if more time remaining? */
 		PSCHED_GET_TIME(now);
 
-		if (PSCHED_TLESS(cb->time_to_send, now)) {
+		if (!PSCHED_TLESS(now, cb->time_to_send)) {
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			return skb;
