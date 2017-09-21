From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 27/64] drivers: net: atmel: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:48 +0530
Message-ID: <1506013525-29291-28-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wireless/atmel/atmel.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/atmel/atmel.c b/drivers/net/wireless/atmel/atmel.c
index b68436b..e816d53 100644
--- a/drivers/net/wireless/atmel/atmel.c
+++ b/drivers/net/wireless/atmel/atmel.c
@@ -1579,11 +1579,10 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	priv->default_beacon_period = priv->beacon_period = 100;
 	priv->listen_interval = 1;
 
-	init_timer(&priv->management_timer);
+	setup_timer(&priv->management_timer, atmel_management_timer,
+		    (unsigned long)dev);
 	spin_lock_init(&priv->irqlock);
 	spin_lock_init(&priv->timerlock);
-	priv->management_timer.function = atmel_management_timer;
-	priv->management_timer.data = (unsigned long) dev;
 
 	dev->netdev_ops = &atmel_netdev_ops;
 	dev->wireless_handlers = &atmel_handler_def;
-- 
2.7.4
