From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 32/64] drivers: net: amd: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:53 +0530
Message-ID: <1506013525-29291-33-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/amd/sunlance.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 291ca51..0183ffb 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1459,9 +1459,8 @@ static int sparc_lance_probe_one(struct platform_device *op,
 	 * can occur from interrupts (ex. IPv6).  So we
 	 * use a timer to try again later when necessary. -DaveM
 	 */
-	init_timer(&lp->multicast_timer);
-	lp->multicast_timer.data = (unsigned long) dev;
-	lp->multicast_timer.function = lance_set_multicast_retry;
+	setup_timer(&lp->multicast_timer, lance_set_multicast_retry,
+		    (unsigned long)dev);
 
 	if (register_netdev(dev)) {
 		printk(KERN_ERR "SunLance: Cannot register device.\n");
-- 
2.7.4
