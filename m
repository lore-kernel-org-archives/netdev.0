From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Thu, 03 Mar 2005 14:46:31 -0600
Message-ID: <2.454130102@selenic.com>
References: <1.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <1.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shorten carrier detect timeout to 4 seconds.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: np/net/core/netpoll.c
===================================================================
--- np.orig/net/core/netpoll.c	2005-03-03 14:13:38.700080023 -0600
+++ np/net/core/netpoll.c	2005-03-03 14:16:21.980600535 -0600
@@ -593,7 +593,7 @@ int netpoll_setup(struct netpoll *np)
 		rtnl_shunlock();
 
 		atleast = jiffies + HZ/10;
- 		atmost = jiffies + 10*HZ;
+ 		atmost = jiffies + 4*HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
 				printk(KERN_NOTICE
@@ -606,7 +606,7 @@ int netpoll_setup(struct netpoll *np)
 
 		if (time_before(jiffies, atleast)) {
 			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
-			       " waiting 10 seconds\n",
+			       " waiting 4 seconds\n",
 			       np->name);
 			while (time_before(jiffies, atmost))
 				cond_resched();
