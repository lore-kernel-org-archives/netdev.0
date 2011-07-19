From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/3] stmmac: remove warning when compile as built-in
Date: Tue, 19 Jul 2011 10:38:04 +0200
Message-ID: <1311064684-20246-3-git-send-email-peppe.cavallaro@st.com>
References: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:45479 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752386Ab1GSIjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 04:39:16 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4E9341B8
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 08:39:13 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 131A127B6
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 08:39:13 +0000 (GMT)
In-Reply-To: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch removes the following serie of warnings
when the driver is compiled as built-in:

drivers/net/stmmac/stmmac_main.c: In function stmmac_cmdline_opt:
drivers/net/stmmac/stmmac_main.c:1855:12: warning: ignoring return
value of kstrtoul, declared with attribute warn_unused_result
[snip]

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |   65 ++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a11a339..2856d66 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1851,33 +1851,52 @@ static int __init stmmac_cmdline_opt(char *str)
 	if (!str || !*str)
 		return -EINVAL;
 	while ((opt = strsep(&str, ",")) != NULL) {
-		if (!strncmp(opt, "debug:", 6))
-			strict_strtoul(opt + 6, 0, (unsigned long *)&debug);
-		else if (!strncmp(opt, "phyaddr:", 8))
-			strict_strtoul(opt + 8, 0, (unsigned long *)&phyaddr);
-		else if (!strncmp(opt, "dma_txsize:", 11))
-			strict_strtoul(opt + 11, 0,
-				       (unsigned long *)&dma_txsize);
-		else if (!strncmp(opt, "dma_rxsize:", 11))
-			strict_strtoul(opt + 11, 0,
-				       (unsigned long *)&dma_rxsize);
-		else if (!strncmp(opt, "buf_sz:", 7))
-			strict_strtoul(opt + 7, 0, (unsigned long *)&buf_sz);
-		else if (!strncmp(opt, "tc:", 3))
-			strict_strtoul(opt + 3, 0, (unsigned long *)&tc);
-		else if (!strncmp(opt, "watchdog:", 9))
-			strict_strtoul(opt + 9, 0, (unsigned long *)&watchdog);
-		else if (!strncmp(opt, "flow_ctrl:", 10))
-			strict_strtoul(opt + 10, 0,
-				       (unsigned long *)&flow_ctrl);
-		else if (!strncmp(opt, "pause:", 6))
-			strict_strtoul(opt + 6, 0, (unsigned long *)&pause);
+		if (!strncmp(opt, "debug:", 6)) {
+			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
+				goto err;
+		} else if (!strncmp(opt, "phyaddr:", 8)) {
+			if (strict_strtoul(opt + 8, 0,
+					   (unsigned long *)&phyaddr))
+				goto err;
+		} else if (!strncmp(opt, "dma_txsize:", 11)) {
+			if (strict_strtoul(opt + 11, 0,
+					   (unsigned long *)&dma_txsize))
+				goto err;
+		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
+			if (strict_strtoul(opt + 11, 0,
+					   (unsigned long *)&dma_rxsize))
+				goto err;
+		} else if (!strncmp(opt, "buf_sz:", 7)) {
+			if (strict_strtoul(opt + 7, 0,
+					   (unsigned long *)&buf_sz))
+				goto err;
+		} else if (!strncmp(opt, "tc:", 3)) {
+			if (strict_strtoul(opt + 3, 0, (unsigned long *)&tc))
+				goto err;
+		} else if (!strncmp(opt, "watchdog:", 9)) {
+			if (strict_strtoul(opt + 9, 0,
+					   (unsigned long *)&watchdog))
+				goto err;
+		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
+			if (strict_strtoul(opt + 10, 0,
+					   (unsigned long *)&flow_ctrl))
+				goto err;
+		} else if (!strncmp(opt, "pause:", 6)) {
+			if (strict_strtoul(opt + 6, 0, (unsigned long *)&pause))
+				goto err;
 #ifdef CONFIG_STMMAC_TIMER
-		else if (!strncmp(opt, "tmrate:", 7))
-			strict_strtoul(opt + 7, 0, (unsigned long *)&tmrate);
+		} else if (!strncmp(opt, "tmrate:", 7)) {
+			if (strict_strtoul(opt + 7, 0,
+					   (unsigned long *)&tmrate))
+				goto err;
 #endif
+		}
 	}
 	return 0;
+
+err:
+	pr_err("%s: ERROR broken module parameter conversion", __func__);
+	return -EINVAL;
 }
 
 __setup("stmmaceth=", stmmac_cmdline_opt);
-- 
1.7.4.4

