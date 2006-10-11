From: Amol Lad <amol@verismonetworks.com>
Subject: [PATCH 2/4] drivers/net/sb1000.c: Replacing yield() with a better
	alternative
Date: Wed, 11 Oct 2006 18:37:57 +0530
Message-ID: <1160572077.19143.343.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel Janitors <kernel-janitors@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.verismonetworks.com ([164.164.99.228]:8429 "EHLO
	mail01.verismonetworks.com") by vger.kernel.org with ESMTP
	id S1751264AbWJKNEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 09:04:36 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cond_resched() seems to be a better alternative

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
diff -uprN -X linux-2.6.19-rc1-orig/Documentation/dontdiff linux-2.6.19-rc1-orig/drivers/net/sb1000.c linux-2.6.19-rc1/drivers/net/sb1000.c
--- linux-2.6.19-rc1-orig/drivers/net/sb1000.c	2006-10-05 14:00:48.000000000 +0530
+++ linux-2.6.19-rc1/drivers/net/sb1000.c	2006-10-11 17:57:02.000000000 +0530
@@ -264,7 +264,7 @@ card_wait_for_busy_clear(const int ioadd
 	timeout = jiffies + TimeOutJiffies;
 	while (a & 0x80 || a & 0x40) {
 		/* a little sleep */
-		yield();
+		cond_resched();
 
 		a = inb(ioaddr[0] + 7);
 		if (time_after_eq(jiffies, timeout)) {
@@ -288,7 +288,7 @@ card_wait_for_ready(const int ioaddr[], 
 	timeout = jiffies + TimeOutJiffies;
 	while (a & 0x80 || !(a & 0x40)) {
 		/* a little sleep */
-		yield();
+		cond_resched();
 
 		a = inb(ioaddr[1] + 6);
 		if (time_after_eq(jiffies, timeout)) {


