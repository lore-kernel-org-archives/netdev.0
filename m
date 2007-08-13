From: vignesh babu <vignesh.babu@wipro.com>
Subject: [kj] is_power_of_2 in net/core/neighbour.c
Date: Mon, 13 Aug 2007 18:33:47 +0530
Message-ID: <1187010227.7273.16.camel@merlin.linuxcoe.com>
Reply-To: vigneshbabu@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:59318 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031048AbXHMNEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 09:04:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replacing n & (n - 1) for power of 2 check by is_power_of_2(n)

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
---
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca2a153..f7de8f2 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -33,6 +33,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <linux/string.h>
+#include <linux/log2.h>
 
 #define NEIGH_DEBUG 1
 
@@ -311,7 +312,7 @@ static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
 
 	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
 
-	BUG_ON(new_entries & (new_entries - 1));
+	BUG_ON(!is_power_of_2(new_entries));
 	new_hash = neigh_hash_alloc(new_entries);
 	if (!new_hash)
 		return;

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

