From: janitor@sternwelten.at
Subject: [patch 03/16]  net/appletalk: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:02:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cFk-0007mX-Fq@sputnik>
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

 linux-2.6.9-rc1-bk7-max/drivers/net/appletalk/ltpc.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/appletalk/ltpc.c~msleep-drivers_net_appletalk_ltpc drivers/net/appletalk/ltpc.c
--- linux-2.6.9-rc1-bk7/drivers/net/appletalk/ltpc.c~msleep-drivers_net_appletalk_ltpc	2004-09-01 19:35:26.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/appletalk/ltpc.c	2004-09-01 19:35:26.000000000 +0200
@@ -1109,8 +1109,7 @@ struct net_device * __init ltpc_probe(vo
 	inb_p(io+1);
 	inb_p(io+3);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(2*HZ/100);
+	msleep(20);
 
 	inb_p(io+0);
 	inb_p(io+2);
@@ -1120,8 +1119,7 @@ struct net_device * __init ltpc_probe(vo
 	inb_p(io+5); /* enable dma */
 	inb_p(io+6); /* tri-state interrupt line */
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	msleep(1000);
 	
 	/* now, figure out which dma channel we're using, unless it's
 	   already been specified */

_
