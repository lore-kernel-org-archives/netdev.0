From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 1/1] tipc: eliminate KASAN warning
Date: Wed, 25 Oct 2017 16:19:52 +0200
Message-ID: <1508941192-15311-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:48962 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdJYOUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following warning was reported by syzbot on Oct 24. 2017:
KASAN: slab-out-of-bounds Read in tipc_nametbl_lookup_dst_nodes

This is a harmless bug, but we still want to get rid of the warning,
so we swap the two conditions in question.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 2856e19..b3829bc 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -697,7 +697,7 @@ void tipc_nametbl_lookup_dst_nodes(struct net *net, u32 type, u32 lower,
 	spin_lock_bh(&seq->lock);
 	sseq = seq->sseqs + nameseq_locate_subseq(seq, lower);
 	stop = seq->sseqs + seq->first_free;
-	for (; sseq->lower <= upper && sseq != stop; sseq++) {
+	for (; sseq != stop && sseq->lower <= upper; sseq++) {
 		info = sseq->info;
 		list_for_each_entry(publ, &info->zone_list, zone_list) {
 			if (tipc_in_scope(domain, publ->node))
-- 
2.1.4
