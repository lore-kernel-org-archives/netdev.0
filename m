From: janitor@sternwelten.at
Subject: [patch 14/16]  net/ibmtr: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:03:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGi-0007uM-UH@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







On Tue, Jul 27, 2004 at 01:43:32PM -0700, Nishanth Aravamudan wrote:
> I would appreciate any comments from the janitor@sternweltens list. 
> 
> 
> 
> Description: Use msleep() instead of schedule_timeout() to guarantee
> the task delays for the desired time.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

The previous patch introduced extraneous whitespace, sorry. Thanks,
Domen.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.6.9-rc1-bk7-max/drivers/net/tokenring/ibmtr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/tokenring/ibmtr.c~msleep-drivers_net_tokenring_ibmtr drivers/net/tokenring/ibmtr.c
--- linux-2.6.9-rc1-bk7/drivers/net/tokenring/ibmtr.c~msleep-drivers_net_tokenring_ibmtr	2004-09-01 19:35:37.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/tokenring/ibmtr.c	2004-09-01 19:35:37.000000000 +0200
@@ -108,6 +108,7 @@ in the event that chatty debug messages 
 #define IBMTR_DEBUG_MESSAGES 0
 
 #include <linux/module.h>
+#include <linux/delay.h>
 
 #ifdef PCMCIA		/* required for ibmtr_cs.c to build */
 #undef MODULE		/* yes, really */
@@ -858,8 +859,7 @@ static int tok_init_card(struct net_devi
 	writeb(~INT_ENABLE, ti->mmio + ACA_OFFSET + ACA_RESET + ISRP_EVEN);
 	outb(0, PIOaddr + ADAPTRESET);
 
-	current->state=TASK_UNINTERRUPTIBLE;
-	schedule_timeout(TR_RST_TIME); /* wait 50ms */
+	msleep(jiffies_to_msecs(TR_RST_TIME));
 
 	outb(0, PIOaddr + ADAPTRESETREL);
 #ifdef ENABLE_PAGING

_
