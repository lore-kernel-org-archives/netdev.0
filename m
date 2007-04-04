From: Shani Moideen <shani.moideen@wipro.com>
Subject: [PATCH] Replace with time_after in drivers/net/tokenring/3c359.c
Date: Wed, 04 Apr 2007 09:50:10 +0530
Message-ID: <1175660410.2247.21.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@osdl.org
To: mikep@linuxtr.net, linux-tr@linuxtr.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:34547 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992627AbXDDEVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 00:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Replacing with time_after in drivers/net/tokenring/3c359.c
Applies and compiles clean on latest linus tree.

thanks.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 7580bde..512cd4d 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -61,6 +61,7 @@
 #include <linux/pci.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
+#include <linux/jiffies.h>
 
 #include <net/checksum.h>
 
@@ -409,7 +410,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL  card not responding to global reset.\n", dev->name);
 			return -ENODEV;
 		}
@@ -520,7 +521,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=jiffies;
 	while ( !(readw(xl_mmio + MMIO_INTSTATUS_AUTO) & INTSTAT_SRB) ) { 
 		schedule();		
-		if(jiffies-t > 15*HZ) {
+		if(time_after(jiffies, t + 15*HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			return -ENODEV; 
 		}
@@ -796,7 +797,7 @@ static int xl_open_hw(struct net_device *dev)
 	t=jiffies;
 	while (! (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) { 
 		schedule();		
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40*HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ; 
 		}
@@ -1011,7 +1012,7 @@ static void xl_reset(struct net_device *dev)
 
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40*HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ; 
 		}
@@ -1283,7 +1284,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNSTALL not responding.\n", dev->name);
 			break ; 
 		}
@@ -1292,7 +1293,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNDISABLE not responding.\n", dev->name);
 			break ;
 		}
@@ -1301,7 +1302,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPSTALL not responding.\n", dev->name);
 			break ; 
 		}
@@ -1318,7 +1319,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (!(readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-CLOSENIC not responding.\n", dev->name);
 			break ; 
 		}
@@ -1347,7 +1348,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies,t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPRESET not responding.\n", dev->name);
 			break ; 
 		}
@@ -1356,7 +1357,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10*HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNRESET not responding.\n", dev->name);
 			break ; 
 		}

-- 
Shani Moideen
