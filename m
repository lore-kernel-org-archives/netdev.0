From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2x: Use dma_alloc_coherent() semantics
 for ILT memory allocation
Date: Wed, 8 Dec 2010 13:43:17 +0200
Message-ID: <1291808598.30114.66.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2222 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571Ab0LHLna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 06:43:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index cfc25cf..abbdf6d 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1336,7 +1336,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 #define BNX2X_ILT_ZALLOC(x, y, size) \
 	do { \
-		x = pci_alloc_consistent(bp->pdev, size, y); \
+		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
 		if (x) \
 			memset(x, 0, size); \
 	} while (0)
@@ -1344,7 +1344,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_ILT_FREE(x, y, size) \
 	do { \
 		if (x) { \
-			pci_free_consistent(bp->pdev, size, x, y); \
+			dma_free_coherent(&bp->pdev->dev, size, x, y); \
 			x = NULL; \
 			y = 0; \
 		} \
-- 
1.7.0.4




