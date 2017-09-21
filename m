From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 19/64] drivers: net: slip: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:40 +0530
Message-ID: <1506013525-29291-20-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/slip/slip.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 436dd78..eb8a189 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -763,12 +763,8 @@ static struct slip *sl_alloc(dev_t line)
 	sl->mode        = SL_MODE_DEFAULT;
 #ifdef CONFIG_SLIP_SMART
 	/* initialize timer_list struct */
-	init_timer(&sl->keepalive_timer);
-	sl->keepalive_timer.data = (unsigned long)sl;
-	sl->keepalive_timer.function = sl_keepalive;
-	init_timer(&sl->outfill_timer);
-	sl->outfill_timer.data = (unsigned long)sl;
-	sl->outfill_timer.function = sl_outfill;
+	setup_timer(&sl->keepalive_timer, sl_keepalive, (unsigned long)sl);
+	setup_timer(&sl->outfill_timer, sl_outfill, (unsigned long)sl);
 #endif
 	slip_devs[i] = dev;
 	return sl;
-- 
2.7.4
