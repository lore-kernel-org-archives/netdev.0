From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 49/64] drivers: net: adi: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:10 +0530
Message-ID: <1506013525-29291-50-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/adi/bfin_mac.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index a251de8..0658cde 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1650,9 +1650,8 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	ndev->netdev_ops = &bfin_mac_netdev_ops;
 	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
-	init_timer(&lp->tx_reclaim_timer);
-	lp->tx_reclaim_timer.data = (unsigned long)lp;
-	lp->tx_reclaim_timer.function = tx_reclaim_skb_timeout;
+	setup_timer(&lp->tx_reclaim_timer, tx_reclaim_skb_timeout,
+		    (unsigned long)lp);
 
 	lp->flags = 0;
 	netif_napi_add(ndev, &lp->napi, bfin_mac_poll, CONFIG_BFIN_RX_DESC_NUM);
-- 
2.7.4
