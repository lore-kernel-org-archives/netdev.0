From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 53/64] drivers: net: dscc: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:14 +0530
Message-ID: <1506013525-29291-54-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wan/dscc4.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index a043fb1..64f1764 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1127,10 +1127,8 @@ static int dscc4_open(struct net_device *dev)
 done:
 	netif_start_queue(dev);
 
-        init_timer(&dpriv->timer);
+	setup_timer(&dpriv->timer, dscc4_timer, (unsigned long)dev);
         dpriv->timer.expires = jiffies + 10*HZ;
-        dpriv->timer.data = (unsigned long)dev;
-	dpriv->timer.function = dscc4_timer;
         add_timer(&dpriv->timer);
 	netif_carrier_on(dev);
 
-- 
2.7.4
