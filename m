From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH] netpoll carrier clarification
Date: Thu, 10 Mar 2005 15:21:38 -0800
Message-ID: <20050310232138.GQ3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Dave Miller <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Clarify the flaky carrier detect code and use msleep().

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: np/net/core/netpoll.c
===================================================================
--- np.orig/net/core/netpoll.c	2005-03-10 16:47:54.000000000 -0600
+++ np/net/core/netpoll.c	2005-03-10 17:15:34.000000000 -0600
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/netpoll.h>
 #include <linux/sched.h>
+#include <linux/delay.h>
 #include <linux/rcupdate.h>
 #include <linux/workqueue.h>
 #include <net/tcp.h>
@@ -660,12 +661,16 @@ int netpoll_setup(struct netpoll *np)
 			cond_resched();
 		}
 
+		/* If carrier appears to come up instantly, we don't
+		 * trust it and pause so that we don't pump all our
+		 * queued console messages into the bitbucket.
+		 */
+
 		if (time_before(jiffies, atleast)) {
-			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
-			       " waiting 4 seconds\n",
+			printk(KERN_NOTICE "%s: carrier detect appears"
+			       " untrustworthy, waiting 4 seconds\n",
 			       np->name);
-			while (time_before(jiffies, atmost))
-				cond_resched();
+			msleep(4000);
 		}
 	}
 

-- 
Mathematics is the supreme nostalgia of our time.
