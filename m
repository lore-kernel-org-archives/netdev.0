From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 24/64] drivers: net: enic: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:45 +0530
Message-ID: <1506013525-29291-25-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/cisco/enic/enic_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index d24ee1a..4a11baf 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2846,9 +2846,8 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Setup notification timer, HW reset task, and wq locks
 	 */
 
-	init_timer(&enic->notify_timer);
-	enic->notify_timer.function = enic_notify_timer;
-	enic->notify_timer.data = (unsigned long)enic;
+	setup_timer(&enic->notify_timer, enic_notify_timer,
+		    (unsigned long)enic);
 
 	enic_set_rx_coal_setting(enic);
 	INIT_WORK(&enic->reset, enic_reset);
-- 
2.7.4
