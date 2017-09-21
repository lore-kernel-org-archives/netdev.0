From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 58/64] drivers: net: packetengines: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:19 +0530
Message-ID: <1506013525-29291-59-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/packetengines/hamachi.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 482b85e..77bc7cc 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -979,10 +979,8 @@ static int hamachi_open(struct net_device *dev)
 			   dev->name, readw(ioaddr + RxStatus), readw(ioaddr + TxStatus));
 	}
 	/* Set the timer to check for link beat. */
-	init_timer(&hmp->timer);
+	setup_timer(&hmp->timer, hamachi_timer, (unsigned long)dev);
 	hmp->timer.expires = RUN_AT((24*HZ)/10);			/* 2.4 sec. */
-	hmp->timer.data = (unsigned long)dev;
-	hmp->timer.function = hamachi_timer;				/* timer handler */
 	add_timer(&hmp->timer);
 
 	return 0;
-- 
2.7.4
