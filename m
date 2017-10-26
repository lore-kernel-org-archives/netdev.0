From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/14] bnxt_en: Check for zero length value in bnxt_get_nvram_item().
Date: Thu, 26 Oct 2017 11:51:22 -0400
Message-ID: <1509033092-1887-5-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:48403 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932426AbdJZPvu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:50 -0400
Received: by mail-qk0-f196.google.com with SMTP id d67so4850730qkg.5
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:50 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return -EINVAL if the length is zero and not proceed to do essentially
nothing.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 3cbe771..85be1cb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1773,6 +1773,9 @@ static int bnxt_get_nvram_item(struct net_device *dev, u32 index, u32 offset,
 	dma_addr_t dma_handle;
 	struct hwrm_nvm_read_input req = {0};
 
+	if (!length)
+		return -EINVAL;
+
 	buf = dma_alloc_coherent(&bp->pdev->dev, length, &dma_handle,
 				 GFP_KERNEL);
 	if (!buf) {
-- 
1.8.3.1
