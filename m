From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 08/15] [NEIGHBOUR]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 18:57:07 +0800
Message-ID: <47C69383.4070505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755629AbYB1K7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:59:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/core/neighbour.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2328acb..aef0153 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1389,10 +1389,10 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour cache statistics");
 
 #ifdef CONFIG_PROC_FS
-	tbl->pde = create_proc_entry(tbl->id, 0, init_net.proc_net_stat);
+	tbl->pde = proc_create(tbl->id, 0, init_net.proc_net_stat,
+			       &neigh_stat_seq_fops);
 	if (!tbl->pde)
 		panic("cannot create neighbour proc dir entry");
-	tbl->pde->proc_fops = &neigh_stat_seq_fops;
 	tbl->pde->data = tbl;
 #endif
 
-- 
WCN


