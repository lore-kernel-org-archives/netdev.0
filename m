From: janitor@sternwelten.at
Subject: [patch 04/18]  net/ni65: replace 	schedule_timeout() with msleep()
Date: Sun, 31 Oct 2004 00:42:29 +0200
Message-ID: <E1CO1vZ-000201-Fn@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/ni65.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ni65.c~msleep-drivers_net_ni65 drivers/net/ni65.c
--- linux-2.6.10-rc1/drivers/net/ni65.c~msleep-drivers_net_ni65	2004-10-24 17:04:58.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/ni65.c	2004-10-24 17:04:58.000000000 +0200
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
