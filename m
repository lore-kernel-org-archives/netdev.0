From: mathieu.poirier@linaro.org
Subject: [PATCH 6/8] donauboe: replace excessive udelay with msleep
Date: Fri, 20 Apr 2012 14:56:14 -0600
Message-ID: <1334955376-17793-7-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34059 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607Ab2DTU4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:56:30 -0400
Received: by mail-pb0-f46.google.com with SMTP id un15so1475811pbc.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:56:30 -0700 (PDT)
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

No driver should spin the CPU for 10ms, so better use
an msleep, which is allowed in the ->suspend function.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/irda/donauboe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 4351296..510b9c8 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1710,7 +1710,7 @@ toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
 
 /* Flush all packets */
   while ((i--) && (self->txpending))
-    udelay (10000);
+    msleep(10);
 
   spin_lock_irqsave(&self->spinlock, flags);
 
-- 
1.7.5.4
