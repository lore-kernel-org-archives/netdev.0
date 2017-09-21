From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 59/64] drivers: net: i40evf: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:20 +0530
Message-ID: <1506013525-29291-60-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1825d95..c243f9d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2686,9 +2686,8 @@ static void i40evf_init_task(struct work_struct *work)
 		ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 	}
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &i40evf_watchdog_timer;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
+	setup_timer(&adapter->watchdog_timer, &i40evf_watchdog_timer,
+		    (unsigned long)adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
 	adapter->tx_desc_count = I40EVF_DEFAULT_TXD;
-- 
2.7.4
