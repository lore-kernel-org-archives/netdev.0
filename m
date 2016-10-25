From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 09/12] net/mlx5: Clear health sick bit when starting health poll
Date: Tue, 25 Oct 2016 18:36:32 +0300
Message-ID: <1477409795-28807-10-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40937 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932696AbcJYPiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:25 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

The health sick status should be cleared when we start the health poll.
This is crucial for driver reload (unload + load) in order to behave
right in case of health issue.

Fixes: fd76ee4da55a ('net/mlx5_core: Fix internal error detection conditions')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 1a05fb9..2cb4094 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -281,6 +281,7 @@ void mlx5_start_health_poll(struct mlx5_core_dev *dev)
 	struct mlx5_core_health *health = &dev->priv.health;
 
 	init_timer(&health->timer);
+	health->sick = 0;
 	health->health = &dev->iseg->health;
 	health->health_counter = &dev->iseg->health_counter;
 
-- 
2.7.4
