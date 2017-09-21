From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 30/64] drivers: net: qlogic: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:51 +0530
Message-ID: <1506013525-29291-31-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/qlogic/qla3xxx.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 2991179..05479d4 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3891,10 +3891,8 @@ static int ql3xxx_probe(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->tx_timeout_work, ql_tx_timeout_work);
 	INIT_DELAYED_WORK(&qdev->link_state_work, ql_link_state_machine_work);
 
-	init_timer(&qdev->adapter_timer);
-	qdev->adapter_timer.function = ql3xxx_timer;
+	setup_timer(&qdev->adapter_timer, ql3xxx_timer, (unsigned long)qdev);
 	qdev->adapter_timer.expires = jiffies + HZ * 2;	/* two second delay */
-	qdev->adapter_timer.data = (unsigned long)qdev;
 
 	if (!cards_found) {
 		pr_alert("%s\n", DRV_STRING);
-- 
2.7.4
