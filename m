From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 43/64] drivers: net: mlx4: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:04 +0530
Message-ID: <1506013525-29291-44-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/mellanox/mlx4/catas.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 53daa6c..de0f9e5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -277,7 +277,7 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 	phys_addr_t addr;
 
 	INIT_LIST_HEAD(&priv->catas_err.list);
-	init_timer(&priv->catas_err.timer);
+	setup_timer(&priv->catas_err.timer, poll_catas, (unsigned long)dev);
 	priv->catas_err.map = NULL;
 
 	if (!mlx4_is_slave(dev)) {
@@ -293,8 +293,6 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 		}
 	}
 
-	priv->catas_err.timer.data     = (unsigned long) dev;
-	priv->catas_err.timer.function = poll_catas;
 	priv->catas_err.timer.expires  =
 		round_jiffies(jiffies + MLX4_CATAS_POLL_INTERVAL);
 	add_timer(&priv->catas_err.timer);
-- 
2.7.4
