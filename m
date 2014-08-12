From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: [PATCH] lec: Fix bug introduced by
 b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
Date: Tue, 12 Aug 2014 09:00:36 -0400
Message-ID: <20140812090036.5e4530ad@thirdoffive.cmf.nrl.navy.mil>
References: <201408121224.s7CCOKCk008781@thirdoffive.cmf.nrl.navy.mil>
	<53EA09DC.5070909@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:33437 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaHLNA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 09:00:57 -0400
In-Reply-To: <53EA09DC.5070909@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

b67bfe0d42cac56c512dd5da4b1b347a23f4b70a (hlist: drop the node
parameter from iterators) dropped the node parameter from
iterators which lec_tbl_walk() was using to iterate the list.

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
---
 net/atm/lec.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 4c5b8ba..e4853b5 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -833,7 +833,6 @@ static void *lec_tbl_walk(struct lec_state *state, struct hlist_head *tbl,
 			  loff_t *l)
 {
 	struct hlist_node *e = state->node;
-	struct lec_arp_table *tmp;
 
 	if (!e)
 		e = tbl->first;
@@ -842,9 +841,7 @@ static void *lec_tbl_walk(struct lec_state *state, struct hlist_head *tbl,
 		--*l;
 	}
 
-	tmp = container_of(e, struct lec_arp_table, next);
-
-	hlist_for_each_entry_from(tmp, next) {
+	for (; e; e = e->next) {
 		if (--*l < 0)
 			break;
 	}
-- 
1.9.3
