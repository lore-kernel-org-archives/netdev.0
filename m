From: thor.thayer@linux.intel.com
Subject: [PATCHv2 2/3] ethtool: stmmac: Add macros for number of registers
Date: Wed, 28 Jun 2017 10:13:41 -0500
Message-ID: <1498662822-12173-3-git-send-email-thor.thayer@linux.intel.com>
References: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30327 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751553AbdF1PKv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 11:10:51 -0400
In-Reply-To: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

This patch adds macros for the number of registers to
loop through to make the code easier to read.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
---
v2  New commit. Add macros for number of registers.
---
 stmmac.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/stmmac.c b/stmmac.c
index e1bb291..ab83779 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -14,6 +14,10 @@
 #include <string.h>
 #include "internal.h"
 
+#define MAC100_DMA_REG_NUM	9
+#define GMAC_REG_NUM		55
+#define GMAC_DMA_REG_NUM	22
+
 /* The DMA Registers start at offset 0x1000 in the DW IP */
 #define DMA_REG_OFFSET	(0x1000 / 4)
 
@@ -40,7 +44,7 @@ int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
 	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
-	for (i = 0; i < 9; i++)
+	for (i = 0; i < MAC100_DMA_REG_NUM; i++)
 		fprintf(stdout, "CSR%d  0x%08X\n", i, *stmmac_reg++);
 
 	fprintf(stdout, "DMA cur tx buf addr 0x%08X\n", *stmmac_reg++);
@@ -58,13 +62,13 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 
 	fprintf(stdout, "ST GMAC Registers\n");
 	fprintf(stdout, "GMAC Registers\n");
-	for (i = 0; i < 55; i++)
+	for (i = 0; i < GMAC_REG_NUM; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
 	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
-	for (i = 0; i < 22; i++)
+	for (i = 0; i < GMAC_DMA_REG_NUM; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
 	return 0;
-- 
2.7.4
