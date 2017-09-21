From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 05/64] drivers : net: niu: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:26 +0530
Message-ID: <1506013525-29291-6-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/sun/niu.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 6a4e8e1..bde19b3 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6123,10 +6123,8 @@ static int niu_open(struct net_device *dev)
 
 	err = niu_init_hw(np);
 	if (!err) {
-		init_timer(&np->timer);
+		setup_timer(&np->timer, niu_timer, (unsigned long)np);
 		np->timer.expires = jiffies + HZ;
-		np->timer.data = (unsigned long) np;
-		np->timer.function = niu_timer;
 
 		err = niu_enable_interrupts(np, 1);
 		if (err)
-- 
2.7.4
