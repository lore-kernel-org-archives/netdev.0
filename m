From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 34/64] drivers: net: eql: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:55 +0530
Message-ID: <1506013525-29291-35-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/eql.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index fe13bfe..fccce4b 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -178,10 +178,8 @@ static void __init eql_setup(struct net_device *dev)
 {
 	equalizer_t *eql = netdev_priv(dev);
 
-	init_timer(&eql->timer);
-	eql->timer.data     	= (unsigned long) eql;
+	setup_timer(&eql->timer, eql_timer, (unsigned long)eql);
 	eql->timer.expires  	= jiffies + EQL_DEFAULT_RESCHED_IVAL;
-	eql->timer.function 	= eql_timer;
 
 	spin_lock_init(&eql->queue.lock);
 	INIT_LIST_HEAD(&eql->queue.all_slaves);
-- 
2.7.4
