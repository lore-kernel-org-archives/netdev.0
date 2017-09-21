From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 03/64] drivers: net: pcnet32: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:24 +0530
Message-ID: <1506013525-29291-4-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/amd/pcnet32.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 7f60d17..e461536 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1970,9 +1970,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 			lp->options |= PCNET32_PORT_MII;
 	}
 
-	init_timer(&lp->watchdog_timer);
-	lp->watchdog_timer.data = (unsigned long)dev;
-	lp->watchdog_timer.function = (void *)&pcnet32_watchdog;
+	setup_timer(&lp->watchdog_timer, (void *)&pcnet32_watchdog,
+		    (unsigned long)dev);
 
 	/* The PCNET32-specific entries in the device structure. */
 	dev->netdev_ops = &pcnet32_netdev_ops;
-- 
2.7.4
