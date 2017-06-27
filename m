From: thor.thayer@linux.intel.com
Subject: [PATCH 1/2] ethtool: stmmac: Fix Designware ethtool register dump
Date: Tue, 27 Jun 2017 16:51:14 -0500
Message-ID: <1498600275-22334-2-git-send-email-thor.thayer@linux.intel.com>
References: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, Thor Thayer <thor.thayer@linux.intel.com>
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:23551 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753866AbdF0VsT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 17:48:19 -0400
In-Reply-To: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

The commit fbf68229ffe7 ("net: stmmac: unify registers dumps methods")

modified the register dump to store the DMA registers at the DMA register
offset (0x1000) but ethtool (stmmac.c) looks for the DMA registers after
the MAC registers which is offset 12.
This patch adds the DMA register offset so that indexing is correct.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
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
