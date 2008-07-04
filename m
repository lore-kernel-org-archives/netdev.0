From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 07/06: sch_htb: remove write-only qdisc filter_cnt
Date: Fri, 04 Jul 2008 14:20:03 +0200
Message-ID: <486E1573.8040303@trash.net>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050004090008080001070409"
Cc: devik@cdi.cz, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35330 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbYGDMUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 08:20:08 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050004090008080001070409
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------050004090008080001070409
Content-Type: text/x-diff;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

commit 50ed378778be0c8d435163122827cf513882a707
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 4 14:18:03 2008 +0200

    net-sched: sch_htb: remove write-only qdisc filter_cnt
    
    The filter_cnt is supposed to count filter references to a class.
    Since the qdisc can't be the target of a filter, it doesn't need
    a filter_cnt. In fact the counter is never decreased since cls_api
    considers a return value of zero a failure and doesn't unbind again.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 128a5ab..ee8b4ff 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -159,7 +159,6 @@ struct htb_sched {
 
 	/* filters for qdisc itself */
 	struct tcf_proto *filter_list;
-	int filter_cnt;
 
 	int rate2quantum;	/* quant = rate / rate2quantum */
 	psched_time_t now;	/* cached dequeue time */
@@ -1484,7 +1483,6 @@ static struct tcf_proto **htb_find_tcf(struct Qdisc *sch, unsigned long arg)
 static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
 				     u32 classid)
 {
-	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_find(classid, sch);
 
 	/*if (cl && !cl->level) return 0;
@@ -1498,20 +1496,15 @@ static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
 	 */
 	if (cl)
 		cl->filter_cnt++;
-	else
-		q->filter_cnt++;
 	return (unsigned long)cl;
 }
 
 static void htb_unbind_filter(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 
 	if (cl)
 		cl->filter_cnt--;
-	else
-		q->filter_cnt--;
 }
 
 static void htb_walk(struct Qdisc *sch, struct qdisc_walker *arg)

--------------050004090008080001070409--
