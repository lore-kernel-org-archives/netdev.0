From: janitor@sternwelten.at
Subject: [patch 16/16]  parport/ieee1284_ops: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:03:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGt-0007vm-Tz@sputnik>
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



Description: Uses msleep() instead of schedule_timeout() to guarantee
the task delays the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/parport/ieee1284_ops.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/parport/ieee1284_ops.c~msleep-drivers_parport_ieee1284_ops drivers/parport/ieee1284_ops.c
--- linux-2.6.9-rc1-bk7/drivers/parport/ieee1284_ops.c~msleep-drivers_parport_ieee1284_ops	2004-09-01 19:35:41.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/parport/ieee1284_ops.c	2004-09-01 19:35:41.000000000 +0200
@@ -542,8 +542,7 @@ size_t parport_ieee1284_ecp_read_data (s
 			/* Yield the port for a while. */
 			if (count && dev->port->irq != PARPORT_IRQ_NONE) {
 				parport_release (dev);
-				__set_current_state (TASK_INTERRUPTIBLE);
-				schedule_timeout ((HZ + 24) / 25);
+				msleep(40);
 				parport_claim_or_block (dev);
 			}
 			else

_
