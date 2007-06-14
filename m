From: vignesh babu <vignesh.babu@wipro.com>
Subject: [PATCH]is_power_of_2-net/core/neighbour.c
Date: Thu, 14 Jun 2007 16:04:47 +0530
Message-ID: <1181817288.2474.20.camel@merlin.linuxcoe.com>
Reply-To: vignesh.babu@wipro.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:59730 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbXFNKeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 06:34:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
--- 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6f3bb73..e663999 100644
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

