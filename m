From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 1/6] netpoll: shorten carrier detect timeout
Date: Thu, 17 Feb 2005 23:25:18 -0600
Message-ID: <2.378217222@selenic.com>
References: <1.378217222@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1.378217222@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shorten carrier detect timeout to 4 seconds.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: tiny-new/net/core/netpoll.c
===================================================================
--- tiny-new.orig/net/core/netpoll.c	2004-11-17 00:05:28.000000000 -0800
+++ tiny-new/net/core/netpoll.c	2004-12-02 11:51:15.775256063 -0800
@@ -584,7 +584,7 @@
 		rtnl_shunlock();
 
 		atleast = jiffies + HZ/10;
- 		atmost = jiffies + 10*HZ;
+ 		atmost = jiffies + 4*HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
 				printk(KERN_NOTICE
@@ -597,7 +597,7 @@
 
 		if (time_before(jiffies, atleast)) {
 			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
-			       " waiting 10 seconds\n",
+			       " waiting 4 seconds\n",
 			       np->name);
 			while (time_before(jiffies, atmost))
 				cond_resched();
