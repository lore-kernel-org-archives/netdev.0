From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Remove redundant variable/code in __qdisc_run
Date: Fri, 15 Jul 2011 14:46:21 +0530
Message-ID: <20110715091621.23013.37893.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:35583 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965364Ab1GOJQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 05:16:26 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p6F9GMPU013086
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 14:46:22 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6F9GLZU331960
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 14:46:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6F9GLt5011381
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 14:46:21 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant variable "work".

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/sched/sch_generic.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2011-06-27 16:16:07.000000000 +0530
+++ new/net/sched/sch_generic.c	2011-07-13 10:58:39.000000000 +0530
@@ -190,16 +190,14 @@ static inline int qdisc_restart(struct Q
 void __qdisc_run(struct Qdisc *q)
 {
 	int quota = weight_p;
-	int work = 0;
 
 	while (qdisc_restart(q)) {
-		work++;
 		/*
 		 * Ordered by possible occurrence: Postpone processing if
 		 * 1. we've exceeded packet quota
 		 * 2. another process needs the CPU;
 		 */
-		if (work >= quota || need_resched()) {
+		if (--quota <= 0 || need_resched()) {
 			__netif_schedule(q);
 			break;
 		}
