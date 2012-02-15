From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 2/3] mlx4: fix QP tree trashing
Date: Wed, 15 Feb 2012 18:22:57 +0200
Message-ID: <4F3BDBE1.8010702@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:57894 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750935Ab2BOQXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:23:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

When adding new unicast steer entry, before moving qp to state ready,
actually before calling mlx4_RST2INIT_QP_wrapper(), there were added
a lot of entries with local_qpn=0 into radix tree.
This fact impacted the get_res() function and proper functioning
of resource tracker in addition to adding trash entries into radix tree.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@melllanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 1420dbc..629cc30 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -374,6 +374,7 @@ static struct res_common *alloc_qp_tr(int id)
 
 	ret->com.res_id = id;
 	ret->com.state = RES_QP_RESERVED;
+	ret->local_qpn = id;
 	INIT_LIST_HEAD(&ret->mcg_list);
 	spin_lock_init(&ret->mcg_spl);
 
-- 
1.5.4.3
