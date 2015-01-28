From: Pramod Gurav <pramod.gurav@smartplayin.com>
Subject: [PATCH RESEND] ssb: Fix Sparse error in main
Date: Wed, 28 Jan 2015 10:52:19 +0530
Message-ID: <1422422539-18772-1-git-send-email-pramod.gurav@smartplayin.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pramod Gurav <pramod.gurav@smartplayin.com>
To: Kalle Valo <kvalo@codeaurora.org>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change fixes below sparse error:
drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
was not declared. Should it be static?

Acked-by: Michael Buesch <m@bues.ch>
Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
---
 drivers/ssb/main.c |   19 -------------------
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
1.7.9.5
