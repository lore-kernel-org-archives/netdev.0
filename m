From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/mlx4_en: dereferencing freed memory
Date: Wed, 11 Jul 2012 09:34:07 +0300
Message-ID: <20120711063407.GD11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Alexander Guller <alexg@mellanox.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:18461 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab2GKGe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:34:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dereferenced "mclist" after the kfree().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 94375a8..4ce5ca8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -503,9 +503,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 				/* remove from list */
 				list_del(&mclist->list);
 				kfree(mclist);
-			}
-
-			if (mclist->action == MCLIST_ADD) {
+			} else if (mclist->action == MCLIST_ADD) {
 				/* attach the address */
 				memcpy(&mc_list[10], mclist->addr, ETH_ALEN);
 				/* needed for B0 steering support */
