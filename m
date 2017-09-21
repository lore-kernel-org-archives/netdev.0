From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 51/64] drivers: net: caif: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:12 +0530
Message-ID: <1506013525-29291-52-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/caif/caif_hsi.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 438966b..fed75e7 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1211,17 +1211,14 @@ static int cfhsi_open(struct net_device *ndev)
 	init_waitqueue_head(&cfhsi->flush_fifo_wait);
 
 	/* Setup the inactivity timer. */
-	init_timer(&cfhsi->inactivity_timer);
-	cfhsi->inactivity_timer.data = (unsigned long)cfhsi;
-	cfhsi->inactivity_timer.function = cfhsi_inactivity_tout;
+	setup_timer(&cfhsi->inactivity_timer, cfhsi_inactivity_tout,
+		    (unsigned long)cfhsi);
 	/* Setup the slowpath RX timer. */
-	init_timer(&cfhsi->rx_slowpath_timer);
-	cfhsi->rx_slowpath_timer.data = (unsigned long)cfhsi;
-	cfhsi->rx_slowpath_timer.function = cfhsi_rx_slowpath;
+	setup_timer(&cfhsi->rx_slowpath_timer, cfhsi_rx_slowpath,
+		    (unsigned long)cfhsi);
 	/* Setup the aggregation timer. */
-	init_timer(&cfhsi->aggregation_timer);
-	cfhsi->aggregation_timer.data = (unsigned long)cfhsi;
-	cfhsi->aggregation_timer.function = cfhsi_aggregation_tout;
+	setup_timer(&cfhsi->aggregation_timer, cfhsi_aggregation_tout,
+		    (unsigned long)cfhsi);
 
 	/* Activate HSI interface. */
 	res = cfhsi->ops->cfhsi_up(cfhsi->ops);
-- 
2.7.4
