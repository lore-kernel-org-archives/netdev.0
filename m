From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 14/26] net/slip: replace schedule_timeout() with msleep()
Date: Wed, 23 Mar 2005 09:28:38 -0800
Message-ID: <20050323172838.GA2679@us.ibm.com>
References: <20050306103322.857041F203@trashy.coderock.org> <4240B152.4080904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: domen@coderock.org, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4240B152.4080904@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2005 at 06:59:14PM -0500, Jeff Garzik wrote:
> domen@coderock.org wrote:
> >Use msleep() instead of schedule_timeout() to guarantee
> >the task delays as expected. While the original code does use
> >TASK_INTERRUPTIBLE, it does not check for signals, so I believe msleep() 
> >is more
> >appropriate.
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >Signed-off-by: Domen Puncer <domen@coderock.org>
> >---
> >
> >
> > kj-domen/drivers/net/slip.c |    7 +++----
> > 1 files changed, 3 insertions(+), 4 deletions(-)
> >
> >diff -puN drivers/net/slip.c~msleep-drivers_net_slip drivers/net/slip.c
> >--- kj/drivers/net/slip.c~msleep-drivers_net_slip	2005-03-05 
> >16:10:49.000000000 +0100
> >+++ kj-domen/drivers/net/slip.c	2005-03-05 16:10:49.000000000 +0100
> >@@ -75,6 +75,7 @@
> > #include <linux/if_arp.h>
> > #include <linux/if_slip.h>
> > #include <linux/init.h>
> >+#include <linux/delay.h>
> > #include "slip.h"
> > #ifdef CONFIG_INET
> > #include <linux/ip.h>
> >@@ -1395,10 +1396,8 @@ static void __exit slip_exit(void)
> > 	/* First of all: check for active disciplines and hangup them.
> > 	 */
> > 	do {
> >-		if (busy) {
> >-			set_current_state(TASK_INTERRUPTIBLE);
> >-			schedule_timeout(HZ / 10);
> >-		}
> >+		if (busy)
> >+			msleep(100);
> 
> msleep_interruptible

I'm fine with changing this; what should the code do if a signal causes
an early return? I switched to msleep() in my patch because the current
code did nothing and that seemed buggy to me.

Thanks for the feedback,
Nish
