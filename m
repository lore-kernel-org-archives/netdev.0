From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] linux/ibmtr.h: add constants for appropriate delays
Date: Mon, 1 Nov 2004 11:22:10 -0800
Message-ID: <20041101192210.GD1730@us.ibm.com>
References: <E1CO1wB-0002eM-If@sputnik> <4184C66B.8040501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C66B.8040501@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:03:07AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >Any comments would be appreciated.
> >
> >Description: Use msleep() / msleep_interruptible() [as appropriate]
> >instead of schedule_timeout() to guarantee the task delays as expected.
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> >
> >---
> >
> > linux-2.6.10-rc1-max/drivers/net/tokenring/ibmtr.c |   11 +++++------
> > 1 files changed, 5 insertions(+), 6 deletions(-)

<snip>

> >-		schedule_timeout(TR_RST_TIME); /* wait 50ms */
> >+		msleep(jiffies_to_msecs(TR_RST_TIME)); /* wait 50ms */

<snip>

> >-	current->state=TASK_UNINTERRUPTIBLE;
> >-	schedule_timeout(TR_RST_TIME); /* wait 50ms */
> >+	msleep(jiffies_to_msecs(TR_RST_TIME));		/* wait 50ms */

<snip>

> >-		current->state=TASK_INTERRUPTIBLE;
> >-		i=schedule_timeout(TR_RETRY_INTERVAL); /* wait 30 seconds */
> >-		if(i!=0) break; /*prob. a signal, like the i>24*HZ case 
> >above */
> >+		if(msleep_interruptible(jiffies_to_msecs(TR_RETRY_INTERVAL)))
> >+			break; /*prob. a signal, like the i>24*HZ case above 

<snip>

> It makes more sense to convert the constants to msecs in the source 
> code, instead of converting them at runtime.

This required changing both the .h and .c files, the first of which is
attached below.

Description: Adds constant definitions for timeout variables in terms of
milliseconds to avoid run-time constant conversion.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.10-rc1-vanilla/include/linux/ibmtr.h	2004-10-30 15:34:03.000000000 -0700
+++ 2.6.10-rc1/include/linux/ibmtr.h	2004-11-01 11:13:41.000000000 -0800
@@ -6,8 +6,10 @@
 
 /* ported to the Alpha architecture 02/20/96 (just used the HZ macro) */
 
-#define TR_RETRY_INTERVAL	(30*HZ)	/* 500 on PC = 5 s */
-#define TR_RST_TIME		(HZ/20) /* 5 on PC = 50 ms */
+#define TR_RETRY_INTERVAL	(30*HZ)	/* 500 on PC = 5 s (in jiffies) */
+#define TR_RETRY_INTERVAL	(30000) /* 500 on PC = 5 s */
+#define TR_RST_TIME		(HZ/20) /* 5 on PC = 50 ms (in jiffies) */
+#define TR_RST_TIME_MS		(50)    /* 5 on PC = 50 ms */
 #define TR_BUSY_INTERVAL	(HZ/5)	/* 5 on PC = 200 ms */
 #define TR_SPIN_INTERVAL	(3*HZ)	/* 3 seconds before init timeout */
 
