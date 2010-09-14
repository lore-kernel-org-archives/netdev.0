From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 14/18] misdn: kill big kernel lock
Date: Tue, 14 Sep 2010 21:35:05 +0200
Message-ID: <1284492909-7147-15-git-send-email-arnd@arndb.de>
References: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:51774 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab0INTfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 15:35:37 -0400
In-Reply-To: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the big kernel lock in misdn is completely
bogus, so let's just remove it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/mISDN/stack.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/mISDN/stack.c b/drivers/isdn/mISDN/stack.c
index b159bd5..a5b632e 100644
--- a/drivers/isdn/mISDN/stack.c
+++ b/drivers/isdn/mISDN/stack.c
@@ -18,7 +18,6 @@
 #include <linux/slab.h>
 #include <linux/mISDNif.h>
 #include <linux/kthread.h>
-#include <linux/smp_lock.h>
 #include "core.h"
 
 static u_int	*debug;
@@ -205,13 +204,7 @@ mISDNStackd(void *data)
 	struct mISDNstack *st = data;
 	int err = 0;
 
-#ifdef CONFIG_SMP
-	lock_kernel();
-#endif
 	sigfillset(&current->blocked);
-#ifdef CONFIG_SMP
-	unlock_kernel();
-#endif
 	if (*debug & DEBUG_MSG_THREAD)
 		printk(KERN_DEBUG "mISDNStackd %s started\n",
 		    dev_name(&st->dev->dev));
-- 
1.7.1

