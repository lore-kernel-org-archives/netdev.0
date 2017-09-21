From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 46/64] drivers: net: dmfe: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:07 +0530
Message-ID: <1506013525-29291-47-git-send-email-allen.lkml@gmail.com>
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
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/dec/tulip/dmfe.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 07e10a4..6585f73 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -596,10 +596,8 @@ static int dmfe_open(struct net_device *dev)
 	netif_wake_queue(dev);
 
 	/* set and active a timer process */
-	init_timer(&db->timer);
+	setup_timer(&db->timer, dmfe_timer, (unsigned long)dev);
 	db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
-	db->timer.data = (unsigned long)dev;
-	db->timer.function = dmfe_timer;
 	add_timer(&db->timer);
 
 	return 0;
-- 
2.7.4

