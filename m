From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 40/64] drivers: net: sis900: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:01 +0530
Message-ID: <1506013525-29291-41-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/sis/sis900.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 40bd883..cb61247 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1065,10 +1065,8 @@ sis900_open(struct net_device *net_dev)
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
-	init_timer(&sis_priv->timer);
+	setup_timer(&sis_priv->timer, sis900_timer, (unsigned long)net_dev);
 	sis_priv->timer.expires = jiffies + HZ;
-	sis_priv->timer.data = (unsigned long)net_dev;
-	sis_priv->timer.function = sis900_timer;
 	add_timer(&sis_priv->timer);
 
 	return 0;
-- 
2.7.4
