From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 47/64] drivers: net: bnxt: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:08 +0530
Message-ID: <1506013525-29291-48-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index aacec8b..c25f5b5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7190,9 +7190,7 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->stats_coal_ticks = BNXT_DEF_STATS_COAL_TICKS;
 
-	init_timer(&bp->timer);
-	bp->timer.data = (unsigned long)bp;
-	bp->timer.function = bnxt_timer;
+	setup_timer(&bp->timer, bnxt_timer, (unsigned long)bp);
 	bp->current_interval = BNXT_TIMER_INTERVAL;
 
 	clear_bit(BNXT_STATE_OPEN, &bp->state);
-- 
2.7.4
