From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH 4/4] CS89x0 : remove QQ2440 board support from the CS89x0 driver
Date: Tue,  3 Jan 2012 23:12:12 +0100
Message-ID: <1325628732-14535-4-git-send-email-jaccon.bastiaansen@gmail.com>
References: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, jaccon.bastiaansen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51206 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab2ACWM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:12:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so16247808eek.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 14:12:59 -0800 (PST)
In-Reply-To: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QQ2440 board isn't supported anymore in the kernel, so support
for this board can be removed from the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/Space.c                  |    2 +-
 drivers/net/ethernet/cirrus/cs89x0.c |    7 -------
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 04c4561..2e9c222 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -191,7 +191,7 @@ static struct devprobe2 isa_probes[] __initdata = {
 #endif
 #ifdef CONFIG_CS89x0
 #if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
-	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440)
+	defined(CONFIG_ARCH_IXDP2X01)
  	{cs89x0_probe, 0},
 #endif
 #endif
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 01cbf57..ba32c13 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -185,10 +185,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_IXDP2X01)
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
-#elif defined(CONFIG_MACH_QQ2440)
-#include <mach/qq2440.h>
-static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
-static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 #else
 /*
  * Counter for the number of CS89x0 platform device instances, which is needed
@@ -539,9 +535,6 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 		lp->force = g_cs89x0_media__force;
 #endif
 
-#if defined(CONFIG_MACH_QQ2440)
-		lp->force |= FORCE_RJ45 | FORCE_FULL;
-#endif
         }
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
-- 
1.7.1
