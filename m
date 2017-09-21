From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 25/64] drivers: net: bnx2: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:46 +0530
Message-ID: <1506013525-29291-26-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/broadcom/bnx2.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e3af1f3..b3055a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8462,10 +8462,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bnx2_set_default_link(bp);
 	bp->req_flow_ctrl = FLOW_CTRL_RX | FLOW_CTRL_TX;
 
-	init_timer(&bp->timer);
+	setup_timer(&bp->timer, bnx2_timer, (unsigned long)bp);
 	bp->timer.expires = RUN_AT(BNX2_TIMER_INTERVAL);
-	bp->timer.data = (unsigned long) bp;
-	bp->timer.function = bnx2_timer;
 
 #ifdef BCM_CNIC
 	if (bnx2_shmem_rd(bp, BNX2_ISCSI_INITIATOR) & BNX2_ISCSI_INITIATOR_EN)
-- 
2.7.4
