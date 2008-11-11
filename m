From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: remove struct neigh_table::pde
Date: Tue, 11 Nov 2008 15:07:40 +0300
Message-ID: <20081111120740.GC30773@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:53637 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455AbYKKMEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 07:04:16 -0500
Received: by ug-out-1314.google.com with SMTP id 39so710177ugf.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 04:04:14 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->pde isn't actually needed, since name is stashed in ->id.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/neighbour.h |    3 ---
 net/core/neighbour.c    |    5 ++---
 2 files changed, 2 insertions(+), 6 deletions(-)

--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -180,9 +180,6 @@ struct neigh_table
 	__u32			hash_rnd;
 	unsigned int		hash_chain_gc;
 	struct pneigh_entry	**phash_buckets;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry	*pde;
-#endif
 };
 
 /* flags for neigh_update() */
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1424,9 +1424,8 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour cache statistics");
 
 #ifdef CONFIG_PROC_FS
-	tbl->pde = proc_create_data(tbl->id, 0, init_net.proc_net_stat,
-				    &neigh_stat_seq_fops, tbl);
-	if (!tbl->pde)
+	if (!proc_create_data(tbl->id, 0, init_net.proc_net_stat,
+			      &neigh_stat_seq_fops, tbl))
 		panic("cannot create neighbour proc dir entry");
 #endif
 
