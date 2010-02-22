From: gfilip@ee.ethz.ch
Subject: [PATCH 4/5] temac: dma MMIO for Virtex4
Date: Mon, 22 Feb 2010 20:07:00 +0100
Message-ID: <1266865621-28955-4-git-send-email-gfilip@ee.ethz.ch>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-3-git-send-email-gfilip@ee.ethz.ch>
Cc: glikely@secretlab.ca, Filip Gospodinov <gfilip@ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:56361 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753673Ab0BVTOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:14:38 -0500
In-Reply-To: <1266865621-28955-3-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch belongs to a set of patches which extends the temac driver to support Virtex4-FX. It was successfully tested on the ML403 evaluation board.

Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
---
 drivers/net/ll_temac_main.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 2e7421c..8b4e1b9 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -115,6 +115,17 @@ void temac_indirect_out32(struct temac_local *lp, int reg, u32 value)
 	temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK | reg);
 }
 
+#ifdef CONFIG_XILINX_VIRTEX_4_FX
+static u32 temac_dma_in32(struct temac_local *lp, int reg)
+{
+	return in_be32((u32 *)(lp->dma_regs + reg));
+}
+
+static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
+{
+	out_be32((u32 *)(lp->dma_regs + reg), value);
+}
+#else
 static u32 temac_dma_in32(struct temac_local *lp, int reg)
 {
 	return dcr_read(lp->sdma_dcrs, reg);
@@ -124,6 +135,7 @@ static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
 {
 	dcr_write(lp->sdma_dcrs, reg, value);
 }
+#endif
 
 /**
  * temac_dma_bd_init - Setup buffer descriptor rings
-- 
1.6.4.4

