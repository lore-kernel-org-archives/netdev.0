From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 45/64] drivers: net: fealnx: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:06 +0530
Message-ID: <1506013525-29291-46-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/fealnx.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index e92859d..c898231 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -909,17 +909,13 @@ static int netdev_open(struct net_device *dev)
 		printk(KERN_DEBUG "%s: Done netdev_open().\n", dev->name);
 
 	/* Set the timer to check for link beat. */
-	init_timer(&np->timer);
+	setup_timer(&np->timer, netdev_timer, (unsigned long)dev);
 	np->timer.expires = RUN_AT(3 * HZ);
-	np->timer.data = (unsigned long) dev;
-	np->timer.function = netdev_timer;
 
 	/* timer handler */
 	add_timer(&np->timer);
 
-	init_timer(&np->reset_timer);
-	np->reset_timer.data = (unsigned long) dev;
-	np->reset_timer.function = reset_timer;
+	setup_timer(&np->reset_timer, reset_timer, (unsigned long)dev);
 	np->reset_timer_armed = 0;
 	return rc;
 }
-- 
2.7.4
