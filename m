From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: sched_timeout() sets curr_state (cosa)
Date: Sun, 5 Oct 2003 20:40:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005204027.182a0188.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.0-test6-current.

--
~Randy


From: Alexey Dobriyan <adobriyan@mail.ru>


 linux-260-test6-kj1-rddunlap/drivers/net/wan/cosa.c |    2 --
 1 files changed, 2 deletions(-)

diff -puN drivers/net/wan/cosa.c~net_wan_taskrun drivers/net/wan/cosa.c
--- linux-260-test6-kj1/drivers/net/wan/cosa.c~net_wan_taskrun	2003-09-29 17:35:07.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/drivers/net/wan/cosa.c	2003-09-29 17:35:07.000000000 -0700
@@ -519,7 +519,6 @@ static int cosa_probe(int base, int irq,
 		current->state = TASK_INTERRUPTIBLE;
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
 		schedule_timeout(30);
-		current->state = TASK_RUNNING;
 		irq = probe_irq_off(irqs);
 		/* Disable all IRQs from the card */
 		cosa_putstatus(cosa, 0);
@@ -1532,7 +1531,6 @@ static int cosa_reset_and_read_id(struct
 #ifdef MODULE
 	current->state = TASK_INTERRUPTIBLE;
 	schedule_timeout(HZ/2);
-	current->state = TASK_RUNNING;
 #else
 	udelay(5*100000);
 #endif

_
