From: janitor@sternwelten.at
Subject: [patch 11/16]  net/ni65: replace schedule_timeout() with 	msleep()
Date: Wed, 01 Sep 2004 23:03:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGS-0007sE-Ej@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/ni65.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ni65.c~msleep-drivers_net_ni65 drivers/net/ni65.c
--- linux-2.6.9-rc1-bk7/drivers/net/ni65.c~msleep-drivers_net_ni65	2004-09-01 19:35:35.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/ni65.c	2004-09-01 19:35:35.000000000 +0200
@@ -526,8 +526,7 @@ static int __init ni65_probe1(struct net
 			ni65_init_lance(p,dev->dev_addr,0,0);
 			irq_mask = probe_irq_on();
 			writereg(CSR0_INIT|CSR0_INEA,CSR0); /* trigger interrupt */
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ/50);
+			msleep(20);
 			dev->irq = probe_irq_off(irq_mask);
 			if(!dev->irq)
 			{

_
