From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 42/64] drivers: net: mlx5: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:03 +0530
Message-ID: <1506013525-29291-43-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 8aea0a0..a89a68c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -320,15 +320,13 @@ void mlx5_start_health_poll(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
 
-	init_timer(&health->timer);
+	setup_timer(&health->timer, poll_health, (unsigned long)dev);
 	health->sick = 0;
 	clear_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags);
 	clear_bit(MLX5_DROP_NEW_RECOVERY_WORK, &health->flags);
 	health->health = &dev->iseg->health;
 	health->health_counter = &dev->iseg->health_counter;
 
-	health->timer.data = (unsigned long)dev;
-	health->timer.function = poll_health;
 	health->timer.expires = round_jiffies(jiffies + MLX5_HEALTH_POLL_INTERVAL);
 	add_timer(&health->timer);
 }
-- 
2.7.4
