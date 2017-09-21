From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 31/64] drivers: net: e1000e: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:52 +0530
Message-ID: <1506013525-29291-32-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 327dfe5..8436c5f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7252,13 +7252,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_eeprom;
 	}
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = e1000_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
-
-	init_timer(&adapter->phy_info_timer);
-	adapter->phy_info_timer.function = e1000_update_phy_info;
-	adapter->phy_info_timer.data = (unsigned long)adapter;
+	setup_timer(&adapter->watchdog_timer, e1000_watchdog,
+		    (unsigned long)adapter);
+	setup_timer(&adapter->phy_info_timer, e1000_update_phy_info,
+		    (unsigned long)adapter);
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
-- 
2.7.4
