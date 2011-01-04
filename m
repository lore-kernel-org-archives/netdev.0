From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v2 10/10] ARM: mxs: add initial pm support
Date: Tue, 4 Jan 2011 17:24:16 +0800
Message-ID: <1294133056-21195-11-git-send-email-shawn.guo@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:14110
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751805Ab1ADJXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:23:43 -0500
In-Reply-To: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a very initial pm support and basically does nothing.
With this pm support entry, drivers can start testing their own
pm functions.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v2:
 - Let build of pm.c depend on CONFIG_PM
 - Remove the blank line above device_initcall in pm.c

 arch/arm/mach-mxs/Makefile |    2 ++
 arch/arm/mach-mxs/pm.c     |   43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-mxs/pm.c

diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefile
index f23ebbd..45a2925 100644
--- a/arch/arm/mach-mxs/Makefile
+++ b/arch/arm/mach-mxs/Makefile
@@ -1,6 +1,8 @@
 # Common support
 obj-y := clock.o devices.o gpio.o icoll.o iomux.o ocotp.o system.o timer.o
 
+obj-$(CONFIG_PM) += pm.o
+
 obj-$(CONFIG_SOC_IMX23) += clock-mx23.o mm-mx23.o
 obj-$(CONFIG_SOC_IMX28) += clock-mx28.o mm-mx28.o
 
diff --git a/arch/arm/mach-mxs/pm.c b/arch/arm/mach-mxs/pm.c
new file mode 100644
index 0000000..fb042da
--- /dev/null
+++ b/arch/arm/mach-mxs/pm.c
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2010 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/suspend.h>
+#include <linux/io.h>
+#include <mach/system.h>
+
+static int mxs_suspend_enter(suspend_state_t state)
+{
+	switch (state) {
+	case PM_SUSPEND_MEM:
+		arch_idle();
+		break;
+
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct platform_suspend_ops mxs_suspend_ops = {
+	.enter = mxs_suspend_enter,
+	.valid = suspend_valid_only_mem,
+};
+
+static int __init mxs_pm_init(void)
+{
+	suspend_set_ops(&mxs_suspend_ops);
+	return 0;
+}
+device_initcall(mxs_pm_init);
-- 
1.7.1


