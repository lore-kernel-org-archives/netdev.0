From: janitor@sternwelten.at
Subject: [patch 02/16]  net/3c505: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:02:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cFf-0007lp-03@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list.

Thanks,
Nish



Description: Uses msleep() instead of schedule_timeout() so the task
is guaranteed to delay the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/3c505.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/3c505.c~msleep-drivers_net_3c505 drivers/net/3c505.c
--- linux-2.6.9-rc1-bk7/drivers/net/3c505.c~msleep-drivers_net_3c505	2004-09-01 19:35:25.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/3c505.c	2004-09-01 19:35:25.000000000 +0200
@@ -1327,8 +1327,7 @@ static int __init elp_sense(struct net_d
 	if (orig_HSR & DIR) {
 		/* If HCR.DIR is up, we pull it down. HSR.DIR should follow. */
 		outb(0, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (inb_status(addr) & DIR) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 2);
@@ -1337,8 +1336,7 @@ static int __init elp_sense(struct net_d
 	} else {
 		/* If HCR.DIR is down, we pull it up. HSR.DIR should follow. */
 		outb(DIR, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (!(inb_status(addr) & DIR)) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 3);

_
