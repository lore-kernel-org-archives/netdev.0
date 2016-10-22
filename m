From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] amd-xgbe: Fix error return code in xgbe_probe()
Date: Sat, 22 Oct 2016 14:35:30 +0000
Message-ID: <1477146930-727-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33121 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936520AbcJVOfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:35:43 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so11509258pfa.0
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:35:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -ENODEV from the DMA is not supported error
handling case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 667e120..6997f11 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -613,6 +613,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	attr = device_get_dma_attr(dev);
 	if (attr == DEV_DMA_NOT_SUPPORTED) {
 		dev_err(dev, "DMA is not supported");
+		ret = -ENODEV;
 		goto err_io;
 	}
 	pdata->coherent = (attr == DEV_DMA_COHERENT);
