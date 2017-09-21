From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 01/64] drivers: net: de4x: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:22 +0530
Message-ID: <1506013525-29291-2-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/dec/tulip/de4x5.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 0affee9..299812e 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1147,9 +1147,8 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 	lp->timeout = -1;
 	lp->gendev = gendev;
 	spin_lock_init(&lp->lock);
-	init_timer(&lp->timer);
-	lp->timer.function = (void (*)(unsigned long))de4x5_ast;
-	lp->timer.data = (unsigned long)dev;
+	setup_timer(&lp->timer, (void (*)(unsigned long))de4x5_ast,
+		    (unsigned long)dev);
 	de4x5_parse_params(dev);
 
 	/*
-- 
2.7.4
