From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 1/4 (v3)] stmmac: do not use strict_strtoul but kstrtoint
Date: Thu, 21 Jun 2012 08:03:16 +0200
Message-ID: <1340258599-3083-2-git-send-email-peppe.cavallaro@st.com>
References: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:52188 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755416Ab2FUGEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 02:04:37 -0400
In-Reply-To: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the obsolete strict_strtoul with kstrtoint.

v2: also removed casting on kstrtoul.
v3: use kstrtoint instead of kstrtoul due to all vars are integer.
    thanks to E. Dumazet.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   27 +++++++-------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 590e95b..eba49cb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2129,42 +2129,35 @@ static int __init stmmac_cmdline_opt(char *str)
 		return -EINVAL;
 	while ((opt = strsep(&str, ",")) != NULL) {
 		if (!strncmp(opt, "debug:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
+			if (kstrtoint(opt + 6, 0, &debug))
 				goto err;
 		} else if (!strncmp(opt, "phyaddr:", 8)) {
-			if (strict_strtoul(opt + 8, 0,
-					   (unsigned long *)&phyaddr))
+			if (kstrtoint(opt + 8, 0, &phyaddr))
 				goto err;
 		} else if (!strncmp(opt, "dma_txsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_txsize))
+			if (kstrtoint(opt + 11, 0, &dma_txsize))
 				goto err;
 		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_rxsize))
+			if (kstrtoint(opt + 11, 0, &dma_rxsize))
 				goto err;
 		} else if (!strncmp(opt, "buf_sz:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&buf_sz))
+			if (kstrtoint(opt + 7, 0, &buf_sz))
 				goto err;
 		} else if (!strncmp(opt, "tc:", 3)) {
-			if (strict_strtoul(opt + 3, 0, (unsigned long *)&tc))
+			if (kstrtoint(opt + 3, 0, &tc))
 				goto err;
 		} else if (!strncmp(opt, "watchdog:", 9)) {
-			if (strict_strtoul(opt + 9, 0,
-					   (unsigned long *)&watchdog))
+			if (kstrtoint(opt + 9, 0, &watchdog))
 				goto err;
 		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
-			if (strict_strtoul(opt + 10, 0,
-					   (unsigned long *)&flow_ctrl))
+			if (kstrtoint(opt + 10, 0, &flow_ctrl))
 				goto err;
 		} else if (!strncmp(opt, "pause:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&pause))
+			if (kstrtoint(opt + 6, 0, &pause))
 				goto err;
 #ifdef CONFIG_STMMAC_TIMER
 		} else if (!strncmp(opt, "tmrate:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&tmrate))
+			if (kstrtoint(opt + 7, 0, &tmrate))
 				goto err;
 #endif
 		}
-- 
1.7.4.4
