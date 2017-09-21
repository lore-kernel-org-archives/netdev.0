From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 09/64] drivers: net: et131x: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:30 +0530
Message-ID: <1506013525-29291-10-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/agere/et131x.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 54eff90..658e92f 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3624,11 +3624,10 @@ static int et131x_open(struct net_device *netdev)
 	int result;
 
 	/* Start the timer to track NIC errors */
-	init_timer(&adapter->error_timer);
+	setup_timer(&adapter->error_timer, et131x_error_timer_handler,
+		    (unsigned long)adapter);
 	adapter->error_timer.expires = jiffies +
 		msecs_to_jiffies(TX_ERROR_PERIOD);
-	adapter->error_timer.function = et131x_error_timer_handler;
-	adapter->error_timer.data = (unsigned long)adapter;
 	add_timer(&adapter->error_timer);
 
 	result = request_irq(irq, et131x_isr,
-- 
2.7.4
