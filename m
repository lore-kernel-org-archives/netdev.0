From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/2] fec: Remove <linux/fec.h> header file
Date: Tue, 21 May 2013 12:44:27 -0300
Message-ID: <1369151067-5220-2-git-send-email-fabio.estevam@freescale.com>
References: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:30822
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753426Ab3EUPqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 11:46:36 -0400
In-Reply-To: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to have a header file to hold a single structure.

Move the 'fec_platform_data' structure definition into the local "fec.h" file 
and get rid of <linux/fec.h> header.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  6 ++++++
 drivers/net/ethernet/freescale/fec_main.c |  1 -
 drivers/net/ethernet/freescale/fec_ptp.c  |  1 -
 include/linux/fec.h                       | 24 ------------------------
 4 files changed, 6 insertions(+), 26 deletions(-)
 delete mode 100644 include/linux/fec.h

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 9ce5b71..d036303 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -16,6 +16,7 @@
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/phy.h>
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
     defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
@@ -274,6 +275,11 @@ struct fec_enet_private {
 	struct fec_enet_delayed_work delay_work;
 };
 
+struct fec_platform_data {
+	phy_interface_t phy;
+	unsigned char mac[ETH_ALEN];
+};
+
 void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
 int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 706e224..148bcd2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -48,7 +48,6 @@
 #include <linux/clk.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
-#include <linux/fec.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 25fc960..24ee926 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -41,7 +41,6 @@
 #include <linux/clk.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
-#include <linux/fec.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
diff --git a/include/linux/fec.h b/include/linux/fec.h
deleted file mode 100644
index bcff455..0000000
--- a/include/linux/fec.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/* include/linux/fec.h
- *
- * Copyright (c) 2009 Orex Computed Radiography
- *   Baruch Siach <baruch@tkos.co.il>
- *
- * Copyright (C) 2010 Freescale Semiconductor, Inc.
- *
- * Header file for the FEC platform data
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#ifndef __LINUX_FEC_H__
-#define __LINUX_FEC_H__
-
-#include <linux/phy.h>
-
-struct fec_platform_data {
-	phy_interface_t phy;
-	unsigned char mac[ETH_ALEN];
-};
-
-#endif
-- 
1.8.1.2
