From: Shani Moideen <shani.moideen@wipro.com>
Subject: [PATCH-resend]drivers/net/eexpress.c replace with time_after &&
	time_before in drivers/net/eexpress.c
Date: Fri, 30 Mar 2007 15:19:45 +0530
Message-ID: <1175248186.2494.31.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@osdl.org, netdev@vger.kernel.org
To: jeff@garzik.org, marcin.slusarz@gmail.com, philb@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:39378 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945966AbXC3JuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 05:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Resending the patch with few corrections related to time_after and
time_before in drivers/net/eexpress.c as suggested by Marcin slusarz.

thanks.


Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 3868b80..1321757 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -115,6 +115,7 @@
 #include <linux/mca-legacy.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
+#include <linux/jiffies.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -556,7 +557,7 @@ static void unstick_cu(struct net_device *dev)
 
 	if (lp->started)
 	{
-		if ((jiffies - dev->trans_start)>50)
+		if (time_after( jiffies, dev->trans_start + 50))
 		{
 			if (lp->tx_link==lp->last_tx_restart)
 			{
@@ -612,7 +613,7 @@ static void unstick_cu(struct net_device *dev)
 	}
 	else
 	{
-		if ((jiffies-lp->init_time)>10)
+		if (time_after(jiffies, lp->init_time + 10))
 		{
 			unsigned short status = scb_status(dev);
 			printk(KERN_WARNING "%s: i82586 startup timed out, status %04x, resetting...\n",
@@ -776,7 +777,7 @@ static unsigned short eexp_start_irq(struct net_device *dev,
 static void eexp_cmd_clear(struct net_device *dev)
 {
 	unsigned long int oldtime = jiffies;
-	while (scb_rdcmd(dev) && ((jiffies-oldtime)<10));
+	while (scb_rdcmd(dev) && (time_before(jiffies, oldtime + 10)));
 	if (scb_rdcmd(dev)) {
 		printk("%s: command didn't clear\n", dev->name);
 	}
@@ -1650,7 +1651,7 @@ eexp_set_multicast(struct net_device *dev)
 #endif
                 oj = jiffies;
                 while ((SCB_CUstat(scb_status(dev)) == 2) &&
-                       ((jiffies-oj) < 2000));
+                       (time_before(jiffies, oj + 2000)));
 		if (SCB_CUstat(scb_status(dev)) == 2)
 			printk("%s: warning, CU didn't stop\n", dev->name);
                 lp->started &= ~(STARTED_CU);

-- 
Shani Moideen
