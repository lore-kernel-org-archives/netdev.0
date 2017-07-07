From: thor.thayer@linux.intel.com
Subject: [PATCHv3 1/2] ethtool: stmmac: Add macros for number of registers
Date: Fri,  7 Jul 2017 09:08:48 -0500
Message-ID: <1499436529-4852-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:60250 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750904AbdGGOFq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 10:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

This patch adds macros for the number of registers to
loop through to make the code easier to read.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
---
v2  New commit. Add macros for number of registers.
v3  Only add macros - remove DMA indexing.
---
 stmmac.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/stmmac.c b/stmmac.c
index fb69bfe..23ed31a 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -14,6 +14,10 @@
 #include <string.h>
 #include "internal.h"
 
+#define MAC100_DMA_REG_NUM	9
+#define GMAC_REG_NUM		55
+#define GMAC_DMA_REG_NUM	22
+
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs)
 {
@@ -36,7 +40,7 @@ int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
-	for (i = 0; i < 9; i++)
+	for (i = 0; i < MAC100_DMA_REG_NUM; i++)
 		fprintf(stdout, "CSR%d  0x%08X\n", i, *stmmac_reg++);
 
 	fprintf(stdout, "DMA cur tx buf addr 0x%08X\n", *stmmac_reg++);
@@ -54,12 +58,12 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 
 	fprintf(stdout, "ST GMAC Registers\n");
 	fprintf(stdout, "GMAC Registers\n");
-	for (i = 0; i < 55; i++)
+	for (i = 0; i < GMAC_REG_NUM; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
-	for (i = 0; i < 22; i++)
+	for (i = 0; i < GMAC_DMA_REG_NUM; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
 	return 0;
-- 
2.7.4
