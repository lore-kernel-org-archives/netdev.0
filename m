From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 52/64] drivers: net: appletalk: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:13 +0530
Message-ID: <1506013525-29291-53-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/appletalk/ltpc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index ac755d2..e4aa374 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1165,9 +1165,7 @@ struct net_device * __init ltpc_probe(void)
 		dev->irq = 0;
 		/* polled mode -- 20 times per second */
 		/* this is really, really slow... should it poll more often? */
-		init_timer(&ltpc_timer);
-		ltpc_timer.function=ltpc_poll;
-		ltpc_timer.data = (unsigned long) dev;
+		setup_timer(&ltpc_timer, ltpc_poll, (unsigned long)dev);
 
 		ltpc_timer.expires = jiffies + HZ/20;
 		add_timer(&ltpc_timer);
-- 
2.7.4
