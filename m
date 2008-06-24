From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 04/10] smc91x: add SMC91X_NOWAIT flag to platform data
Date: Tue, 24 Jun 2008 17:47:41 +0800
Message-ID: <1214300867-15495-5-git-send-email-eric.y.miao@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:44701 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752195AbYFXJrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 05:47:40 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.miao@marvell.com>

And also favors the usage of SMC91X_NOWAIT over the hardcoded SMC_NOWAIT
by converting "nowait" (module parameter overridable) to platform flag.

There are several possibilities:

  1. platform data present - preferred and use as is
  2. platform data absent  - use "nowait", it can be:
       a. SMC_NOWAIT if defined
       b. default to 0 if SMC_NOWAIT isn't defined
       c. overriden by module parameter

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 drivers/net/smc91x.c   |    3 ++-
 include/linux/smc91x.h |    2 ++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index b57ee44..caa0308 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -279,7 +279,7 @@ static void smc_reset(struct net_device *dev)
 	 * can't handle it then there will be no recovery except for
 	 * a hard reset or power cycle
 	 */
-	if (nowait)
+	if (lp->cfg.flags & SMC91X_NOWAIT)
 		cfg |= CONFIG_NO_WAIT;
 
 	/*
@@ -2142,6 +2142,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
+		lp->cfg.flags |= (nowait) ? SMC91X_NOWAIT : 0;
 	}
 
 	ndev->dma = (unsigned char)-1;
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index fc7682f..90434db 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -5,6 +5,8 @@
 #define SMC91X_USE_16BIT (1 << 1)
 #define SMC91X_USE_32BIT (1 << 2)
 
+#define SMC91X_NOWAIT		(1 << 3)
+
 struct smc91x_platdata {
 	unsigned long flags;
 };
-- 
1.5.4.3

