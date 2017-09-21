From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 38/64] drivers: net: ath6kl: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:59 +0530
Message-ID: <1506013525-29291-39-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wireless/ath/ath6kl/txrx.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index e6b2517..4e5cc2b 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -1753,9 +1753,7 @@ void aggr_conn_init(struct ath6kl_vif *vif, struct aggr_info *aggr_info,
 
 	aggr_conn->aggr_sz = AGGR_SZ_DEFAULT;
 	aggr_conn->dev = vif->ndev;
-	init_timer(&aggr_conn->timer);
-	aggr_conn->timer.function = aggr_timeout;
-	aggr_conn->timer.data = (unsigned long) aggr_conn;
+	setup_timer(&aggr_conn->timer, aggr_timeout, (unsigned long)aggr_conn);
 	aggr_conn->aggr_info = aggr_info;
 
 	aggr_conn->timer_scheduled = false;
-- 
2.7.4
