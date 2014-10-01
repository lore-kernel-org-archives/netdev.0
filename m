From: Pramod Gurav <pramod.gurav@smartplayin.com>
Subject: [PATCH v2] ssb: Fix Sparse error in main
Date: Wed,  1 Oct 2014 22:58:02 +0530
Message-ID: <1412184482-2603-1-git-send-email-pramod.gurav@smartplayin.com>
Cc: Pramod Gurav <pramod.gurav@smartplayin.com>,
	Michael Buesch <m@bues.ch>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change fixes below sparse error:
drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
was not declared. Should it be static?

Cc: Michael Buesch <m@bues.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
---
Changes since v1:
Removed the function as it is not called anywhere in the kernel
as per suggestion from Michael Buesch.

 drivers/ssb/main.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 2fead38..1e180c4 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -90,25 +90,6 @@ found:
 }
 #endif /* CONFIG_SSB_PCMCIAHOST */
 
-#ifdef CONFIG_SSB_SDIOHOST
-struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func)
-{
-	struct ssb_bus *bus;
-
-	ssb_buses_lock();
-	list_for_each_entry(bus, &buses, list) {
-		if (bus->bustype == SSB_BUSTYPE_SDIO &&
-		    bus->host_sdio == func)
-			goto found;
-	}
-	bus = NULL;
-found:
-	ssb_buses_unlock();
-
-	return bus;
-}
-#endif /* CONFIG_SSB_SDIOHOST */
-
 int ssb_for_each_bus_call(unsigned long data,
 			  int (*func)(struct ssb_bus *bus, unsigned long data))
 {
-- 
1.8.3.2
