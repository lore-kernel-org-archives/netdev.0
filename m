From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH] net: eth: altera: Resolve false errors from MSGDMA to TSE
Date: Fri, 24 Apr 2015 02:32:07 -0500
Message-ID: <1429860727-1359-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <cnphoon@altera.com>,
	<ennoerlangen@gmail.com>,
	Vince Bridgers <vbridger@opensource.altera.com>
To: <netdev@vger.kernel.org>, <nios2-dev@lists.rocketboards.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chee Nouk Phoon <cnphoon@altera.com>

This patch resolves false errors from MSGDMA in TX mSGDMA MM to ST
mode, and is a continuation of the patch recently submitted by Andrea
Oetken. The MSGDMA had a logic bug that masked detection of this issue
prior to Quartus 14.1/Build 164. When the MSGDMA logic bug was addressed
in Quartus 14.1/Build 164, the driver problem was exposed.

The problem is corrected by making sure MSGDMA_DESC_CTL_TR_ERR_IRQ is not
set for any of the transmit DMA descriptors, and only used for receive
descriptors.

Fixes: 71cd26e altera tse: Error-Bit on tx-avalon-stream always set.

Signed-off-by: Chee Nouk Phoon <cnphoon@altera.com>
Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>a
Cc: Andreas Oetken <ennoerlangen@gmail.com>
---
 drivers/net/ethernet/altera/altera_msgdmahw.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_msgdmahw.h b/drivers/net/ethernet/altera/altera_msgdmahw.h
index eba070f..89cd11d 100644
--- a/drivers/net/ethernet/altera/altera_msgdmahw.h
+++ b/drivers/net/ethernet/altera/altera_msgdmahw.h
@@ -58,15 +58,12 @@ struct msgdma_extended_desc {
 /* Tx buffer control flags
  */
 #define MSGDMA_DESC_CTL_TX_FIRST	(MSGDMA_DESC_CTL_GEN_SOP |	\
-					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
 					 MSGDMA_DESC_CTL_GO)
 
-#define MSGDMA_DESC_CTL_TX_MIDDLE	(MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
-					 MSGDMA_DESC_CTL_GO)
+#define MSGDMA_DESC_CTL_TX_MIDDLE	(MSGDMA_DESC_CTL_GO)
 
 #define MSGDMA_DESC_CTL_TX_LAST		(MSGDMA_DESC_CTL_GEN_EOP |	\
 					 MSGDMA_DESC_CTL_TR_COMP_IRQ |	\
-					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
 					 MSGDMA_DESC_CTL_GO)
 
 #define MSGDMA_DESC_CTL_TX_SINGLE	(MSGDMA_DESC_CTL_GEN_SOP |	\
-- 
1.9.1
