From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 39/64] drivers: net: sun: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:00 +0530
Message-ID: <1506013525-29291-40-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/sun/sungem.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index fa607d0..b75ab8f 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2910,9 +2910,7 @@ static int gem_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	gp->msg_enable = DEFAULT_MSG;
 
-	init_timer(&gp->link_timer);
-	gp->link_timer.function = gem_link_timer;
-	gp->link_timer.data = (unsigned long) gp;
+	setup_timer(&gp->link_timer, gem_link_timer, (unsigned long)gp);
 
 	INIT_WORK(&gp->reset_task, gem_reset_task);
 
-- 
2.7.4
