From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 09/17] gtp: use addr_hash when traversing pdp contexts
Date: Mon, 23 Jan 2017 12:56:58 +0100
Message-ID: <20170123115706.4354-10-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:58164 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750895AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prepares for the removal of the tid_hash from the device.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 5b35ebb..762dd6b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -778,7 +778,7 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	int i;
 
 	for (i = 0; i < gtp->hash_size; i++)
-		hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid)
+		hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[i], hlist_addr)
 			pdp_context_delete(pctx);
 
 	synchronize_rcu();
@@ -1188,7 +1188,7 @@ static int gtp_genl_dump_pdp(struct sk_buff *skb,
 			last_gtp = NULL;
 
 		for (i = k; i < gtp->hash_size; i++) {
-			hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid) {
+			hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[i], hlist_addr) {
 				if (tid && tid != pctx->u.tid)
 					continue;
 				else
-- 
2.10.2
