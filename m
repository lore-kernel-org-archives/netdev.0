From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/9] bnxt_en: Reduce maximum ring pages if page size is 64K.
Date: Sat, 14 May 2016 20:29:43 -0400
Message-ID: <1463272188-30025-5-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36684 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002AbcEOAaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:03 -0400
Received: by mail-pf0-f171.google.com with SMTP id c189so56579560pfb.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:02 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip supports 4K/8K/64K page sizes for the rings and we try to
match it to the CPU PAGE_SIZE.  The current page size limits for the rings
are based on 4K/8K page size. If the page size is 64K, these limits are
too large.  Reduce them appropriately.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 355843b..408bb00 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -425,10 +425,17 @@ struct rx_tpa_end_cmp_ext {
 
 #define MAX_TPA		64
 
+#if (BNXT_PAGE_SHIFT == 16)
+#define MAX_RX_PAGES	1
+#define MAX_RX_AGG_PAGES	4
+#define MAX_TX_PAGES	1
+#define MAX_CP_PAGES	8
+#else
 #define MAX_RX_PAGES	8
 #define MAX_RX_AGG_PAGES	32
 #define MAX_TX_PAGES	8
 #define MAX_CP_PAGES	64
+#endif
 
 #define RX_DESC_CNT (BNXT_PAGE_SIZE / sizeof(struct rx_bd))
 #define TX_DESC_CNT (BNXT_PAGE_SIZE / sizeof(struct tx_bd))
-- 
1.8.3.1
