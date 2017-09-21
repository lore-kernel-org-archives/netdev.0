From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 12/64] drivers: net: atp: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:33 +0530
Message-ID: <1506013525-29291-13-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/realtek/atp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index bed3468..bdc3833 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -438,10 +438,8 @@ static int net_open(struct net_device *dev)
 
 	hardware_init(dev);
 
-	init_timer(&lp->timer);
+	setup_timer(&lp->timer, atp_timed_checker, (unsigned long)dev);
 	lp->timer.expires = jiffies + TIMED_CHECKER;
-	lp->timer.data = (unsigned long)dev;
-	lp->timer.function = atp_timed_checker;    /* timer handler */
 	add_timer(&lp->timer);
 
 	netif_start_queue(dev);
-- 
2.7.4
