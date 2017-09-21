From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 17/64] drivers: net: sdla: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:38 +0530
Message-ID: <1506013525-29291-18-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wan/sdla.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 236c625..0cc4890 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1617,10 +1617,8 @@ static void setup_sdla(struct net_device *dev)
 	flp->deassoc		= sdla_deassoc;
 	flp->dlci_conf		= sdla_dlci_conf;
 
-	init_timer(&flp->timer);
+	setup_timer(&flp->timer, sdla_poll, (unsigned long)dev);
 	flp->timer.expires	= 1;
-	flp->timer.data		= (unsigned long) dev;
-	flp->timer.function	= sdla_poll;
 }
 
 static struct net_device *sdla;
-- 
2.7.4
