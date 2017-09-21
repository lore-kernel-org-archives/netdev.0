From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 23/64] drivers: net: winbond-840: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:44 +0530
Message-ID: <1506013525-29291-24-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/dec/tulip/winbond-840.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 32d7229..6f88d68 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -655,10 +655,8 @@ static int netdev_open(struct net_device *dev)
 		netdev_dbg(dev, "Done netdev_open()\n");
 
 	/* Set the timer to check for link beat. */
-	init_timer(&np->timer);
+	setup_timer(&np->timer, netdev_timer, (unsigned long)dev);
 	np->timer.expires = jiffies + 1*HZ;
-	np->timer.data = (unsigned long)dev;
-	np->timer.function = netdev_timer;				/* timer handler */
 	add_timer(&np->timer);
 	return 0;
 out_err:
-- 
2.7.4
