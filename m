From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 63/64] drivers: net: bnx2x: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:24 +0530
Message-ID: <1506013525-29291-64-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c12b4d3..54d15713 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12414,10 +12414,8 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->current_interval = CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ;
 
-	init_timer(&bp->timer);
+	setup_timer(&bp->timer, bnx2x_timer, (unsigned long)bp);
 	bp->timer.expires = jiffies + bp->current_interval;
-	bp->timer.data = (unsigned long) bp;
-	bp->timer.function = bnx2x_timer;
 
 	if (SHMEM2_HAS(bp, dcbx_lldp_params_offset) &&
 	    SHMEM2_HAS(bp, dcbx_lldp_dcbx_stat_offset) &&
-- 
2.7.4
