From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 13/64] drivers: net: ns83820: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:34 +0530
Message-ID: <1506013525-29291-14-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/natsemi/ns83820.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 729095d..99d3c78 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1652,9 +1652,7 @@ static int ns83820_open(struct net_device *ndev)
 	writel(0, dev->base + TXDP_HI);
 	writel(desc, dev->base + TXDP);
 
-	init_timer(&dev->tx_watchdog);
-	dev->tx_watchdog.data = (unsigned long)ndev;
-	dev->tx_watchdog.function = ns83820_tx_watch;
+	setup_timer(&dev->tx_watchdog, ns83820_tx_watch, (unsigned long)ndev);
 	mod_timer(&dev->tx_watchdog, jiffies + 2*HZ);
 
 	netif_start_queue(ndev);	/* FIXME: wait for phy to come up */
-- 
2.7.4
