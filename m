From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 4/8] smc91x: add SMC91X_NOWAIT flag to platform data
Date: Thu, 19 Jun 2008 19:06:51 +0800
Message-ID: <485A3DCB.90903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:44065 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617AbYFSLG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:06:57 -0400
Received: by ti-out-0910.google.com with SMTP id b6so319775tic.23
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:06:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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

