From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 16/64] drivers: net: tg3: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:37 +0530
Message-ID: <1506013525-29291-17-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/broadcom/tg3.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 656e6af..d8d5f20 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11087,9 +11087,7 @@ static void tg3_timer_init(struct tg3 *tp)
 	tp->asf_multiplier = (HZ / tp->timer_offset) *
 			     TG3_FW_UPDATE_FREQ_SEC;
 
-	init_timer(&tp->timer);
-	tp->timer.data = (unsigned long) tp;
-	tp->timer.function = tg3_timer;
+	setup_timer(&tp->timer, tg3_timer, (unsigned long)tp);
 }
 
 static void tg3_timer_start(struct tg3 *tp)
-- 
2.7.4
