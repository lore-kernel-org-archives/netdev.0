From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 02/64] drivers: net: b44: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:23 +0530
Message-ID: <1506013525-29291-3-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/broadcom/b44.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index a1125d1..42e44fc 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1474,10 +1474,8 @@ static int b44_open(struct net_device *dev)
 		goto out;
 	}
 
-	init_timer(&bp->timer);
+	setup_timer(&bp->timer, b44_timer, (unsigned long)bp);
 	bp->timer.expires = jiffies + HZ;
-	bp->timer.data = (unsigned long) bp;
-	bp->timer.function = b44_timer;
 	add_timer(&bp->timer);
 
 	b44_enable_ints(bp);
-- 
2.7.4
