From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH 2.6.19-rc4-git10][PKT_SCHED] sch_htb: INIT_HLIST_NODE after hlist_del()
Date: Mon, 6 Nov 2006 12:33:53 +0100
Message-ID: <20061106113353.GA4829@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:41629 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1752329AbWKFL2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 06:28:08 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After hlist_del() next and pprev pointers are not NULL
so hlist_unhashed() doesn't work properly.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---


diff -Nurp linux-2.6.19-rc4-git10-/net/sched/sch_htb.c linux-2.6.19-rc4-git10/net/sched/sch_htb.c
--- linux-2.6.19-rc4-git10-/net/sched/sch_htb.c	2006-11-06 11:42:41.000000000 +0100
+++ linux-2.6.19-rc4-git10/net/sched/sch_htb.c	2006-11-06 11:53:15.000000000 +0100
@@ -1284,8 +1284,10 @@ static void htb_destroy_class(struct Qdi
 						  struct htb_class, sibling));
 
 	/* note: this delete may happen twice (see htb_delete) */
-	if (!hlist_unhashed(&cl->hlist))
+	if (!hlist_unhashed(&cl->hlist)) {
 		hlist_del(&cl->hlist);
+		INIT_HLIST_NODE(&cl->hlist);
+	}
 	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
@@ -1333,8 +1335,10 @@ static int htb_delete(struct Qdisc *sch,
 	sch_tree_lock(sch);
 
 	/* delete from hash and active; remainder in destroy_class */
-	if (!hlist_unhashed(&cl->hlist))
+	if (!hlist_unhashed(&cl->hlist)) {
 		hlist_del(&cl->hlist);
+		INIT_HLIST_NODE(&cl->hlist);
+	}
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
