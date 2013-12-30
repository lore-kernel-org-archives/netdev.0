From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] stmicro: make local variables static
Date: Mon, 30 Dec 2013 10:38:57 -0800
Message-ID: <20131230103857.00dee306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55458 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab3L3SjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:39:00 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so9922839pab.5
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:39:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make variables only used in one file static. Also avoids possible
namespace collisions.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h	2013-10-06 14:48:23.770461529 -0700
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h	2013-12-30 10:16:36.348879727 -0800
@@ -108,8 +108,6 @@ struct stmmac_priv {
 	spinlock_t ptp_lock;
 };
 
-extern int phyaddr;
-
 int stmmac_mdio_unregister(struct net_device *ndev);
 int stmmac_mdio_register(struct net_device *ndev);
 void stmmac_set_ethtool_ops(struct net_device *netdev);
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c	2013-12-05 14:47:25.816499656 -0800
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c	2013-12-30 10:16:40.740830166 -0800
@@ -64,7 +64,7 @@ static int debug = -1;
 module_param(debug, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
 
-int phyaddr = -1;
+static int phyaddr = -1;
 module_param(phyaddr, int, S_IRUGO);
 MODULE_PARM_DESC(phyaddr, "Physical device address");
 
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c	2013-10-23 21:23:02.984673967 -0700
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c	2013-12-30 10:18:14.451771633 -0800
@@ -26,9 +26,9 @@
 #include <linux/pci.h>
 #include "stmmac.h"
 
-struct plat_stmmacenet_data plat_dat;
-struct stmmac_mdio_bus_data mdio_data;
-struct stmmac_dma_cfg dma_cfg;
+static struct plat_stmmacenet_data plat_dat;
+static struct stmmac_mdio_bus_data mdio_data;
+static struct stmmac_dma_cfg dma_cfg;
 
 static void stmmac_default_data(void)
 {
