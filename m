From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 41/64] drivers: net: packetengines: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:02 +0530
Message-ID: <1506013525-29291-42-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/packetengines/yellowfin.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index fa7770d..33c241f 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -632,10 +632,8 @@ static int yellowfin_open(struct net_device *dev)
 	}
 
 	/* Set the timer to check for link beat. */
-	init_timer(&yp->timer);
+	setup_timer(&yp->timer, yellowfin_timer, (unsigned long)dev);
 	yp->timer.expires = jiffies + 3*HZ;
-	yp->timer.data = (unsigned long)dev;
-	yp->timer.function = yellowfin_timer;				/* timer handler */
 	add_timer(&yp->timer);
 out:
 	return rc;
-- 
2.7.4
