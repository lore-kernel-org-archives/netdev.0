From: janitor@sternwelten.at
Subject: [patch 12/16]  net/ns83820: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:03:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGX-0007sw-WC@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







On Tue, Jul 27, 2004 at 02:34:08PM -0400, Benjamin LaHaise wrote:
> The commit message doesn't seem correspond to the actual patch.  What 
> are you trying to "fix"?

Thanks for catching this - it was another typo. Please find the
corrected patch below.

-Nish



Description: Uses msleep() instead of schedule_timeout() to guarantee
the task delays the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/ns83820.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ns83820.c~msleep-drivers_net_ns83820 drivers/net/ns83820.c
--- linux-2.6.9-rc1-bk7/drivers/net/ns83820.c~msleep-drivers_net_ns83820	2004-09-01 19:35:35.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/ns83820.c	2004-09-01 19:35:35.000000000 +0200
@@ -1960,8 +1960,7 @@ static int __devinit ns83820_init_one(st
 	if (reset_phy) {
 		printk(KERN_INFO "%s: resetting phy\n", ndev->name);
 		writel(dev->CFG_cache | CFG_PHY_RST, dev->base + CFG);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout((HZ+99)/100);
+		msleep(10);
 		writel(dev->CFG_cache, dev->base + CFG);
 	}
 

_
