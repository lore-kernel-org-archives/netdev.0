From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 5/6] pkt_sched: sch_htb: Optimize htb_find_next_upper()
Date: Tue, 9 Dec 2008 10:21:48 +0000
Message-ID: <20081209102148.GE14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYLIKVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:21:53 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:21:52 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

htb_id_find_next_upper() is usually called to find a class with next
id after some previously removed class, so let's move a check for
equality to the end: it's the least likely here.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2e0a74c..f44a4be 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -702,14 +702,14 @@ static struct rb_node *htb_id_find_next_upper(int prio, struct rb_node *n,
 	while (n) {
 		struct htb_class *cl =
 		    rb_entry(n, struct htb_class, node[prio]);
-		if (id == cl->common.classid)
-			return n;
 
 		if (id > cl->common.classid) {
 			n = n->rb_right;
-		} else {
+		} else if (id < cl->common.classid) {
 			r = n;
 			n = n->rb_left;
+		} else {
+			return n;
 		}
 	}
 	return r;
-- 
1.5.6.5

