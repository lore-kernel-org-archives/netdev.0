From: janitor@sternwelten.at
Subject: [patch 06/16]  net/e1000_osdep: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:03:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cG0-0007of-Vj@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







On Tue, Jul 27, 2004 at 04:00:52AM +0100, Matthew Wilcox wrote:
> On Mon, Jul 26, 2004 at 05:00:01PM -0700, Nishanth Aravamudan wrote:
> > I would appreciate any comments from the janitor@sternweltens list. 
> > 
> > 
> > 
> > Description: Replace schedule_timeout() with msleep() to guarantee the
> > task delays for the desired time.
> >  			} else { \
> > -				set_current_state(TASK_UNINTERRUPTIBLE); \
> > -				schedule_timeout((x * HZ)/1000 + 2); \
> > +				msleep(x); \
> >  			} } while(0)
> 
> Looks much better than the previous code.  It's actually possible to do
> better, though.  Simply change to:
> 
> #define msec_delay(x) msleep(x)
> 
> If msleep() ends up scheduling, the bad attempt to sleep will be caught
> by schedule().  There's no need to do the check in the driver.

Thanks for the tip and here is this change:

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/e1000/e1000_osdep.h |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN drivers/net/e1000/e1000_osdep.h~msleep-drivers_net_e1000_osdep drivers/net/e1000/e1000_osdep.h
--- linux-2.6.9-rc1-bk7/drivers/net/e1000/e1000_osdep.h~msleep-drivers_net_e1000_osdep	2004-09-01 19:35:28.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/e1000/e1000_osdep.h	2004-09-01 19:35:28.000000000 +0200
@@ -42,13 +42,7 @@
 #include <linux/sched.h>
 
 #ifndef msec_delay
-#define msec_delay(x)	do { if(in_interrupt()) { \
-				/* Don't mdelay in interrupt context! */ \
-	                	BUG(); \
-			} else { \
-				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000 + 2); \
-			} } while(0)
+#define msec_delay(x)	msleep(x)
 #endif
 
 #define PCI_COMMAND_REGISTER   PCI_COMMAND

_
