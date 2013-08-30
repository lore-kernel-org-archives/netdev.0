From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 02/11] net: calxedaxgmac: read correct field in xgmac_desc_get_buf_len
Date: Fri, 30 Aug 2013 16:49:20 -0500
Message-ID: <1377899369-23252-2-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:58957 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab3H3Vt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:49:58 -0400
Received: by mail-oa0-f43.google.com with SMTP id i10so2953996oag.16
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:49:58 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

xgmac_desc_get_buf_len appears to have a copy/paste error. flags is the
wrong field to read. We should be reading buf_size field. cpu_to_le32
should also be le32_to_cpu. This never really mattered as this function
is only used for DMA mapping calls which happen to be nops with coherent
DMA.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 71f6720..d41af68 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -421,7 +421,7 @@ static inline void desc_set_buf_len(struct xgmac_dma_desc *p, u32 buf_sz)
 
 static inline int desc_get_buf_len(struct xgmac_dma_desc *p)
 {
-	u32 len = cpu_to_le32(p->flags);
+	u32 len = le32_to_cpu(p->buf_size);
 	return (len & DESC_BUFFER1_SZ_MASK) +
 		((len & DESC_BUFFER2_SZ_MASK) >> DESC_BUFFER2_SZ_OFFSET);
 }
-- 
1.8.1.2
