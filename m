From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 36/64] drivers: net: can: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:57 +0530
Message-ID: <1506013525-29291-37-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/can/grcan.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index a7be12d..8570cfd 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1626,13 +1626,11 @@ static int grcan_setup_netdev(struct platform_device *ofdev,
 	spin_lock_init(&priv->lock);
 
 	if (priv->need_txbug_workaround) {
-		init_timer(&priv->rr_timer);
-		priv->rr_timer.function = grcan_running_reset;
-		priv->rr_timer.data = (unsigned long)dev;
+		setup_timer(&priv->rr_timer, grcan_running_reset,
+			    (unsigned long)dev);
 
-		init_timer(&priv->hang_timer);
-		priv->hang_timer.function = grcan_initiate_running_reset;
-		priv->hang_timer.data = (unsigned long)dev;
+		setup_timer(&priv->hang_timer, grcan_initiate_running_reset,
+			    (unsigned long)dev);
 	}
 
 	netif_napi_add(dev, &priv->napi, grcan_poll, GRCAN_NAPI_WEIGHT);
-- 
2.7.4
