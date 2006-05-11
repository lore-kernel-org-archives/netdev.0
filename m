From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: HFSC: fix thinko in hfsc_adjust_levels()
Date: Thu, 11 May 2006 16:56:02 +0200
Message-ID: <44635082.7000701@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050704060003040404060202"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34547 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751818AbWEKO4F
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 10:56:05 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050704060003040404060202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050704060003040404060202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: HFSC: fix thinko in hfsc_adjust_levels()

When deleting the last child the level of a class should drop to zero.

Noticed by Andreas Mueller <andreas@stapelspeicher.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c75053e281212b5ed3990a0aaced865db7e456d2
tree be2c674d4545ea41200fc5c57d53a03cb0672a93
parent 0e44dc383787b472a7f13564c6bd8a44cc07d408
author Patrick McHardy <kaber@trash.net> Thu, 11 May 2006 10:29:30 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 11 May 2006 10:29:30 +0200

 net/sched/sch_hfsc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 91132f6..f1c7bd2 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -974,10 +974,10 @@ hfsc_adjust_levels(struct hfsc_class *cl
 	do {
 		level = 0;
 		list_for_each_entry(p, &cl->children, siblings) {
-			if (p->level > level)
-				level = p->level;
+			if (p->level >= level)
+				level = p->level + 1;
 		}
-		cl->level = level + 1;
+		cl->level = level;
 	} while ((cl = cl->cl_parent) != NULL);
 }
 

--------------050704060003040404060202--
