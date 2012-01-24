From: Alessandro Rubini <rubini@gnudd.com>
Subject: [PATCH 3/3] stmmac: remove kernel cmdline parsing
Date: Tue, 24 Jan 2012 10:09:42 +0100
Message-ID: <cccc8a7f01bf1a92d197336b9f2e2674d436993b.1327394751.git.rubini@gnudd.com>
References: <cover.1327394750.git.rubini@gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: giancarlo.asnaghi@st.com
To: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1327394750.git.rubini@gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All configurable arguments are already there as module_param, and they
work in the main command line as well, by saying
e.g. "stmmac.phyaddr=1" (I do it on my board).

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   59 ---------------------
 1 files changed, 0 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..625d0d1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1981,65 +1981,6 @@ int stmmac_restore(struct net_device *ndev)
 }
 #endif /* CONFIG_PM */
 
-#ifndef MODULE
-static int __init stmmac_cmdline_opt(char *str)
-{
-	char *opt;
-
-	if (!str || !*str)
-		return -EINVAL;
-	while ((opt = strsep(&str, ",")) != NULL) {
-		if (!strncmp(opt, "debug:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
-				goto err;
-		} else if (!strncmp(opt, "phyaddr:", 8)) {
-			if (strict_strtoul(opt + 8, 0,
-					   (unsigned long *)&phyaddr))
-				goto err;
-		} else if (!strncmp(opt, "dma_txsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_txsize))
-				goto err;
-		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_rxsize))
-				goto err;
-		} else if (!strncmp(opt, "buf_sz:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&buf_sz))
-				goto err;
-		} else if (!strncmp(opt, "tc:", 3)) {
-			if (strict_strtoul(opt + 3, 0, (unsigned long *)&tc))
-				goto err;
-		} else if (!strncmp(opt, "watchdog:", 9)) {
-			if (strict_strtoul(opt + 9, 0,
-					   (unsigned long *)&watchdog))
-				goto err;
-		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
-			if (strict_strtoul(opt + 10, 0,
-					   (unsigned long *)&flow_ctrl))
-				goto err;
-		} else if (!strncmp(opt, "pause:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&pause))
-				goto err;
-#ifdef CONFIG_STMMAC_TIMER
-		} else if (!strncmp(opt, "tmrate:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&tmrate))
-				goto err;
-#endif
-		}
-	}
-	return 0;
-
-err:
-	pr_err("%s: ERROR broken module parameter conversion", __func__);
-	return -EINVAL;
-}
-
-__setup("stmmaceth=", stmmac_cmdline_opt);
-#endif
-
 MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
 MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
 MODULE_LICENSE("GPL");
-- 
1.7.7.2
