From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 14/64] drivers: net: ixgb: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:35 +0530
Message-ID: <1506013525-29291-15-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5a71319..1e6ec22 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -508,9 +508,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->part_num = ixgb_get_ee_pba_number(&adapter->hw);
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = ixgb_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
+	setup_timer(&adapter->watchdog_timer, ixgb_watchdog,
+		    (unsigned long)adapter);
 
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
 
-- 
2.7.4
