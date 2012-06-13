From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/4 (v2)] stmmac: do not use strict_strtoul but kstrtoul
Date: Wed, 13 Jun 2012 09:17:05 +0200
Message-ID: <1339571827-7162-3-git-send-email-peppe.cavallaro@st.com>
References: <1339571827-7162-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, yuvalmin@broadcom.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:45209 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924Ab2FMHRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 03:17:33 -0400
In-Reply-To: <1339571827-7162-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the obsolete strict_strtoul with kstrtoul.

v2: also removed casting on kstrtoul.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   67 +++++++++-----------
 2 files changed, 31 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 6d07ba2..1d70f64 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -88,7 +88,7 @@ struct stmmac_priv {
 	int synopsys_id;
 };
 
-extern int phyaddr;
+extern unsigned long int phyaddr;
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8899e10..bd53003 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -80,39 +80,39 @@
 
 /* Module parameters */
 #define TX_TIMEO 5000 /* default 5 seconds */
-static int watchdog = TX_TIMEO;
-module_param(watchdog, int, S_IRUGO | S_IWUSR);
+static unsigned long int watchdog = TX_TIMEO;
+module_param(watchdog, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(watchdog, "Transmit timeout in milliseconds");
 
-static int debug = -1;		/* -1: default, 0: no output, 16:  all */
-module_param(debug, int, S_IRUGO | S_IWUSR);
+static unsigned long int debug = -1; /* -1: default, 0: no output, 16:  all */
+module_param(debug, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "Message Level (0: no output, 16: all)");
 
-int phyaddr = -1;
-module_param(phyaddr, int, S_IRUGO);
+unsigned long int phyaddr = -1;
+module_param(phyaddr, ulong, S_IRUGO);
 MODULE_PARM_DESC(phyaddr, "Physical device address");
 
 #define DMA_TX_SIZE 256
-static int dma_txsize = DMA_TX_SIZE;
-module_param(dma_txsize, int, S_IRUGO | S_IWUSR);
+static unsigned long int dma_txsize = DMA_TX_SIZE;
+module_param(dma_txsize, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(dma_txsize, "Number of descriptors in the TX list");
 
 #define DMA_RX_SIZE 256
-static int dma_rxsize = DMA_RX_SIZE;
-module_param(dma_rxsize, int, S_IRUGO | S_IWUSR);
+static unsigned long int dma_rxsize = DMA_RX_SIZE;
+module_param(dma_rxsize, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(dma_rxsize, "Number of descriptors in the RX list");
 
-static int flow_ctrl = FLOW_OFF;
-module_param(flow_ctrl, int, S_IRUGO | S_IWUSR);
+static unsigned long int flow_ctrl = FLOW_OFF;
+module_param(flow_ctrl, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(flow_ctrl, "Flow control ability [on/off]");
 
-static int pause = PAUSE_TIME;
-module_param(pause, int, S_IRUGO | S_IWUSR);
+static unsigned long int pause = PAUSE_TIME;
+module_param(pause, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(pause, "Flow Control Pause Time");
 
 #define TC_DEFAULT 64
-static int tc = TC_DEFAULT;
-module_param(tc, int, S_IRUGO | S_IWUSR);
+static unsigned long int tc = TC_DEFAULT;
+module_param(tc, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tc, "DMA threshold control value");
 
 /* Pay attention to tune this parameter; take care of both
@@ -120,14 +120,14 @@ MODULE_PARM_DESC(tc, "DMA threshold control value");
  * Many tests showed that ~4ms latency seems to be good enough. */
 #ifdef CONFIG_STMMAC_TIMER
 #define DEFAULT_PERIODIC_RATE	256
-static int tmrate = DEFAULT_PERIODIC_RATE;
-module_param(tmrate, int, S_IRUGO | S_IWUSR);
+static unsigned long int tmrate = DEFAULT_PERIODIC_RATE;
+module_param(tmrate, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tmrate, "External timer freq. (default: 256Hz)");
 #endif
 
 #define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
-static int buf_sz = DMA_BUFFER_SIZE;
-module_param(buf_sz, int, S_IRUGO | S_IWUSR);
+static unsigned long int buf_sz = DMA_BUFFER_SIZE;
+module_param(buf_sz, ulong, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
@@ -2126,42 +2126,35 @@ static int __init stmmac_cmdline_opt(char *str)
 		return -EINVAL;
 	while ((opt = strsep(&str, ",")) != NULL) {
 		if (!strncmp(opt, "debug:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
+			if (kstrtoul(opt + 6, 0, &debug))
 				goto err;
 		} else if (!strncmp(opt, "phyaddr:", 8)) {
-			if (strict_strtoul(opt + 8, 0,
-					   (unsigned long *)&phyaddr))
+			if (kstrtoul(opt + 8, 0, &phyaddr))
 				goto err;
 		} else if (!strncmp(opt, "dma_txsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_txsize))
+			if (kstrtoul(opt + 11, 0, &dma_txsize))
 				goto err;
 		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_rxsize))
+			if (kstrtoul(opt + 11, 0, &dma_rxsize))
 				goto err;
 		} else if (!strncmp(opt, "buf_sz:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&buf_sz))
+			if (kstrtoul(opt + 7, 0, &buf_sz))
 				goto err;
 		} else if (!strncmp(opt, "tc:", 3)) {
-			if (strict_strtoul(opt + 3, 0, (unsigned long *)&tc))
+			if (kstrtoul(opt + 3, 0, &tc))
 				goto err;
 		} else if (!strncmp(opt, "watchdog:", 9)) {
-			if (strict_strtoul(opt + 9, 0,
-					   (unsigned long *)&watchdog))
+			if (kstrtoul(opt + 9, 0, &watchdog))
 				goto err;
 		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
-			if (strict_strtoul(opt + 10, 0,
-					   (unsigned long *)&flow_ctrl))
+			if (kstrtoul(opt + 10, 0, &flow_ctrl))
 				goto err;
 		} else if (!strncmp(opt, "pause:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&pause))
+			if (kstrtoul(opt + 6, 0, &pause))
 				goto err;
 #ifdef CONFIG_STMMAC_TIMER
 		} else if (!strncmp(opt, "tmrate:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&tmrate))
+			if (kstrtoul(opt + 7, 0, &tmrate))
 				goto err;
 #endif
 		}
-- 
1.7.4.4
