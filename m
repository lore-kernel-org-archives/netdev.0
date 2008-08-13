From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix oops in htb_delete.
Date: Wed, 13 Aug 2008 22:13:00 +0200
Message-ID: <20080813201259.GA4350@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:39858 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYHMUMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 16:12:52 -0400
Received: by mu-out-0910.google.com with SMTP id w8so187309mue.1
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 13:12:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Fix oops in htb_delete.

Recent changes introduced a bug in htb_delete(): cl->parent->children
counter update misses checking cl->parent for NULL, which is used for
root classes, so deleting them causes an oops.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_htb.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index be35422..6febd24 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1279,7 +1279,8 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	/* delete from hash and active; remainder in destroy_class */
 	qdisc_class_hash_remove(&q->clhash, &cl->common);
-	cl->parent->children--;
+	if (cl->parent)
+		cl->parent->children--;
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
