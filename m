From: janitor@sternwelten.at
Subject: [patch 06/18]  net/cosa: replace 	schedule_timeout() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:36 +0200
Message-ID: <E1CO1vg-00027C-CO@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com,
        kas@fi.muni.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated. Two patches have been removed from my
set, so the total has been reduced to 38.

Description: Use msleep_interruptible() instead of schedule_timeout()
to guarantee the task delays as expected. Also use set_current_state()
instaed of direct assignment of current->state.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Jan Kasprzak <kas@fi.muni.cz>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/wan/cosa.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff -puN drivers/net/wan/cosa.c~msleep-drivers_net_wan_cosa drivers/net/wan/cosa.c
--- linux-2.6.10-rc1/drivers/net/wan/cosa.c~msleep-drivers_net_wan_cosa	2004-10-24 17:05:02.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/wan/cosa.c	2004-10-24 17:05:02.000000000 +0200
@@ -543,7 +543,7 @@ static int cosa_probe(int base, int irq,
 		 * FIXME: When this code is not used as module, we should
 		 * probably call udelay() instead of the interruptible sleep.
 		 */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
 		schedule_timeout(30);
 		irq = probe_irq_off(irqs);
@@ -1564,8 +1564,7 @@ static int cosa_reset_and_read_id(struct
 	cosa_getdata8(cosa);
 	cosa_putstatus(cosa, SR_RST);
 #ifdef MODULE
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(HZ/2);
+	msleep_interruptible(500);
 #else
 	udelay(5*100000);
 #endif
@@ -1618,7 +1617,7 @@ static int get_wait_data(struct cosa_dat
 			return r;
 		}
 		/* sleep if not ready to read */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1);
 	}
 	printk(KERN_INFO "cosa: timeout in get_wait_data (status 0x%x)\n",
@@ -1645,7 +1644,7 @@ static int put_wait_data(struct cosa_dat
 		}
 #if 0
 		/* sleep if not ready to read */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1);
 #endif
 	}
_
