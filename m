From: janitor@sternwelten.at
Subject: [patch 04/16]  net/cs89x0: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:02:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cFp-0007nF-Vx@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. This is one (of
many) cases where I made a decision about replacing

set_current_state(TASK_INTERRUPTIBLE);
schedule_timeout(some_time);

with

msleep(jiffies_to_msecs(some_time));

msleep() is not exactly the same as the previous code, but I only did
this replacement where I thought long delays were *desired*. If this is
not the case here, then just disregard this patch. 

Thanks,
Nish



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/cs89x0.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/cs89x0.c~msleep-drivers_net_cs89x0 drivers/net/cs89x0.c
--- linux-2.6.9-rc1-bk7/drivers/net/cs89x0.c~msleep-drivers_net_cs89x0	2004-09-01 19:35:27.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/cs89x0.c	2004-09-01 19:35:27.000000000 +0200
@@ -891,8 +891,7 @@ void  __init reset_chip(struct net_devic
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
 
 	/* wait 30 ms */
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(30*HZ/1000);
+	msleep(30);
 
 	if (lp->chip_type != CS8900) {
 		/* Hardware problem requires PNP registers to be reconfigured after a reset */

_
