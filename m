From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 26/64] drivers: net: xen-netback: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:47 +0530
Message-ID: <1506013525-29291-27-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/xen-netback/interface.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index ee8ed9da..dcfcb15 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -520,8 +520,7 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 
 	queue->credit_bytes = queue->remaining_credit = ~0UL;
 	queue->credit_usec  = 0UL;
-	init_timer(&queue->credit_timeout);
-	queue->credit_timeout.function = xenvif_tx_credit_callback;
+	setup_timer(&queue->credit_timeout, xenvif_tx_credit_callback, 0UL);
 	queue->credit_window_start = get_jiffies_64();
 
 	queue->rx_queue_max = XENVIF_RX_QUEUE_BYTES;
-- 
2.7.4
