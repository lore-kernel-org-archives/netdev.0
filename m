From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 10/64] drivers: net: appletalk: cops: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:31 +0530
Message-ID: <1506013525-29291-11-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/appletalk/cops.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 486e1e6..caf0428 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -424,9 +424,7 @@ static int cops_open(struct net_device *dev)
 		 */
 		if(lp->board==TANGENT)	/* Poll 20 times per second */
 		{
-		    init_timer(&cops_timer);
-		    cops_timer.function = cops_poll;
-		    cops_timer.data 	= (unsigned long)dev;
+		    setup_timer(&cops_timer, cops_poll, (unsigned long)dev);
 		    cops_timer.expires 	= jiffies + HZ/20;
 		    add_timer(&cops_timer);
 		} 
-- 
2.7.4
