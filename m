From: domen@coderock.org
Subject: [patch 09/19] net/ni65: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:34 +0100
Message-ID: <20050111231034.838F71F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
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
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/ni65.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ni65.c~msleep-drivers_net_ni65 drivers/net/ni65.c
--- kj/drivers/net/ni65.c~msleep-drivers_net_ni65	2005-01-10 18:00:02.000000000 +0100
+++ kj-domen/drivers/net/ni65.c	2005-01-10 18:00:02.000000000 +0100
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
