From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 37/64] drivers: net: arcnet: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:58 +0530
Message-ID: <1506013525-29291-38-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/arcnet/arcnet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index fcfccbb..13236b2 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -450,9 +450,7 @@ struct net_device *alloc_arcdev(const char *name)
 
 		lp->dev = dev;
 		spin_lock_init(&lp->lock);
-		init_timer(&lp->timer);
-		lp->timer.data = (unsigned long) dev;
-		lp->timer.function = arcnet_timer;
+		setup_timer(&lp->timer, arcnet_timer, (unsigned long)dev);
 	}
 
 	return dev;
-- 
2.7.4
