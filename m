From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 20/64] drivers: net: spider_net: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:41 +0530
Message-ID: <1506013525-29291-21-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/toshiba/spider_net.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index cec9e70..a913538 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2256,16 +2256,14 @@ spider_net_setup_netdev(struct spider_net_card *card)
 
 	pci_set_drvdata(card->pdev, netdev);
 
-	init_timer(&card->tx_timer);
-	card->tx_timer.function =
-		(void (*)(unsigned long)) spider_net_cleanup_tx_ring;
-	card->tx_timer.data = (unsigned long) card;
+	setup_timer(&card->tx_timer,
+		    (void(*)(unsigned long))spider_net_cleanup_tx_ring,
+		    (unsigned long)card);
 	netdev->irq = card->pdev->irq;
 
 	card->aneg_count = 0;
-	init_timer(&card->aneg_timer);
-	card->aneg_timer.function = spider_net_link_phy;
-	card->aneg_timer.data = (unsigned long) card;
+	setup_timer(&card->aneg_timer, spider_net_link_phy,
+		    (unsigned long)card);
 
 	netif_napi_add(netdev, &card->napi,
 		       spider_net_poll, SPIDER_NET_NAPI_WEIGHT);
-- 
2.7.4
