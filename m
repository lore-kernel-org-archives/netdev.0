From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 21/64] drivers: net: sun: cassini: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:42 +0530
Message-ID: <1506013525-29291-22-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/sun/cassini.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 382993c..a74d78f 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -5039,10 +5039,7 @@ static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&cp->stat_lock[N_TX_RINGS]);
 	mutex_init(&cp->pm_mutex);
 
-	init_timer(&cp->link_timer);
-	cp->link_timer.function = cas_link_timer;
-	cp->link_timer.data = (unsigned long) cp;
-
+	setup_timer(&cp->link_timer, cas_link_timer, (unsigned long)cp);
 #if 1
 	/* Just in case the implementation of atomic operations
 	 * change so that an explicit initialization is necessary.
-- 
2.7.4
