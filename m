From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] sctp: use bitmap_weight
Date: Sat, 17 Nov 2012 15:39:49 +0900
Message-ID: <1353134389-25583-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59963 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029Ab2KQGkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 01:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use bitmap_weight to count the total number of bits set in bitmap.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sctp/tsnmap.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index b5fb7c4..5f25e0c 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -272,7 +272,7 @@ __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map)
 	__u32 max_tsn = map->max_tsn_seen;
 	__u32 base_tsn = map->base_tsn;
 	__u16 pending_data;
-	u32 gap, i;
+	u32 gap;
 
 	pending_data = max_tsn - cum_tsn;
 	gap = max_tsn - base_tsn;
@@ -280,11 +280,7 @@ __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map)
 	if (gap == 0 || gap >= map->len)
 		goto out;
 
-	for (i = 0; i < gap+1; i++) {
-		if (test_bit(i, map->tsn_map))
-			pending_data--;
-	}
-
+	pending_data -= bitmap_weight(map->tsn_map, gap + 1);
 out:
 	return pending_data;
 }
-- 
1.7.11.7
