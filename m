From: "Dimitry V. Ketov" <Dimitry.Ketov@avalon.ru>
Subject: [PATCH] [2.4.20] filter_list destroy fix in net/sched/sch_csz.c
Date: Fri, 11 Apr 2003 13:11:17 +0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1B7C89B8DCB084C809A22D7FEB90B381773AE@frodo.avalon.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Same as prio qdisc, the csz qdisc does not destroy its filter list, when
someone deletes qdisc from interface without explicit filter deleting.
So here is the patch. :)

--- linux-2.4.20/net/sched/sch_csz.c	Fri Dec 21 20:42:06 2001
+++ linux/net/sched/sch_csz.c	Fri Apr 11 12:33:08 2003
@@ -749,6 +749,15 @@
 static void
 csz_destroy(struct Qdisc* sch)
 {
+	struct csz_sched_data *q = (struct csz_sched_data *)sch->data;
+	struct tcf_proto *tp;
+
+	while((tp = q->filter_list) != NULL)
+	{
+		q->filter_list = tp->next;
+		tp->ops->destroy(tp);
+	}
+
 	MOD_DEC_USE_COUNT;
 }
