From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 4/5] mlx4: not using spin_lock_irq when getting vf
 by resource.
Date: Mon, 19 Dec 2011 16:03:05 +0200
Message-ID: <4EEF4419.100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:47141 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752062Ab1LSQRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:17:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

The function is always called from irq context, changing the call
to spin_lock().

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index bdd61c3..b41762d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -339,14 +339,14 @@ int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 
 	if (type == RES_QP)
 		id &= 0x7fffff;
-	spin_lock_irq(mlx4_tlock(dev));
+	spin_lock(mlx4_tlock(dev));
 
 	r = find_res(dev, id, type);
 	if (r) {
 		*slave = r->owner;
 		err = 0;
 	}
-	spin_unlock_irq(mlx4_tlock(dev));
+	spin_unlock(mlx4_tlock(dev));
 
 	return err;
 }
-- 
1.7.7
