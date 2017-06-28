From: thor.thayer@linux.intel.com
Subject: [PATCHv2 1/3] ethtool: stmmac: Fix Designware ethtool register dump
Date: Wed, 28 Jun 2017 10:13:40 -0500
Message-ID: <1498662822-12173-2-git-send-email-thor.thayer@linux.intel.com>
References: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6095 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752492AbdF1PLM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 11:11:12 -0400
In-Reply-To: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

The commit fbf68229ffe7 ("net: stmmac: unify registers dumps methods")

in the Linux kernel modified the register dump to store the DMA registers
at the DMA register offset (0x1000) but ethtool (stmmac.c) looks for the
DMA registers after the MAC registers which is offset 12.
This patch adds the DMA register offset so that indexing is correct.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
v2  Modify the commit message to specify commit from Linux kernel.
    Add Acked-by.
---
 stmmac.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/stmmac.c b/stmmac.c
index fb69bfe..e1bb291 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -14,6 +14,9 @@
 #include <string.h>
 #include "internal.h"
 
+/* The DMA Registers start at offset 0x1000 in the DW IP */
+#define DMA_REG_OFFSET	(0x1000 / 4)
+
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs)
 {
@@ -36,6 +39,7 @@ int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
+	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
 	for (i = 0; i < 9; i++)
 		fprintf(stdout, "CSR%d  0x%08X\n", i, *stmmac_reg++);
 
@@ -59,6 +63,7 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
+	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
 	for (i = 0; i < 22; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
-- 
2.7.4
