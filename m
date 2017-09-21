From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 55/64] drivers: net: hamradio: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:16 +0530
Message-ID: <1506013525-29291-56-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/hamradio/6pack.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 021a8ec..97fe8df 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -623,9 +623,7 @@ static int sixpack_open(struct tty_struct *tty)
 
 	netif_start_queue(dev);
 
-	init_timer(&sp->tx_t);
-	sp->tx_t.function = sp_xmit_on_air;
-	sp->tx_t.data = (unsigned long) sp;
+	setup_timer(&sp->tx_t, sp_xmit_on_air, (unsigned long)sp);
 
 	init_timer(&sp->resync_t);
 
-- 
2.7.4
