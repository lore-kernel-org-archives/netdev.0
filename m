From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 11/64] drivers: net: rsi_91x: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:32 +0530
Message-ID: <1506013525-29291-12-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wireless/rsi/rsi_91x_hal.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_hal.c b/drivers/net/wireless/rsi/rsi_91x_hal.c
index 070dfd6..7ad286d 100644
--- a/drivers/net/wireless/rsi/rsi_91x_hal.c
+++ b/drivers/net/wireless/rsi/rsi_91x_hal.c
@@ -411,9 +411,8 @@ static void bl_cmd_timeout(unsigned long priv)
 
 static int bl_start_cmd_timer(struct rsi_hw *adapter, u32 timeout)
 {
-	init_timer(&adapter->bl_cmd_timer);
-	adapter->bl_cmd_timer.data = (unsigned long)adapter;
-	adapter->bl_cmd_timer.function = (void *)&bl_cmd_timeout;
+	setup_timer(&adapter->bl_cmd_timer, (void *)&bl_cmd_timeout,
+		    (unsigned long)adapter);
 	adapter->bl_cmd_timer.expires = (msecs_to_jiffies(timeout) + jiffies);
 
 	adapter->blcmd_timer_expired = false;
-- 
2.7.4
