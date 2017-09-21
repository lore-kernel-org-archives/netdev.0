From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 62/64] drivers: net: cxgb: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:23 +0530
Message-ID: <1506013525-29291-63-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/chelsio/cxgb/sge.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 0f13a7f..75e4399 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -2075,9 +2075,8 @@ struct sge *t1_sge_create(struct adapter *adapter, struct sge_params *p)
 			goto nomem_port;
 	}
 
-	init_timer(&sge->tx_reclaim_timer);
-	sge->tx_reclaim_timer.data = (unsigned long)sge;
-	sge->tx_reclaim_timer.function = sge_tx_reclaim_cb;
+	setup_timer(&sge->tx_reclaim_timer, sge_tx_reclaim_cb,
+		    (unsigned long)sge);
 
 	if (is_T2(sge->adapter)) {
 		init_timer(&sge->espibug_timer);
-- 
2.7.4
