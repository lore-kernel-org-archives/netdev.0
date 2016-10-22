From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: eth: altera: Fix error return code in altera_tse_probe()
Date: Sat, 22 Oct 2016 14:28:38 +0000
Message-ID: <1477146518-28470-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        nios2-dev@lists.rocketboards.org
To: Vince Bridgers <vbridger@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34991 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935471AbcJVO2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:28:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id s8so11478982pfj.2
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:28:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -EINVAL from the error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index cc9787e..8e92084 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1329,11 +1329,13 @@ static int altera_tse_probe(struct platform_device *pdev)
 		if (upper_32_bits(priv->rxdescmem_busaddr)) {
 			dev_dbg(priv->device,
 				"SGDMA bus addresses greater than 32-bits\n");
+			ret = -EINVAL;
 			goto err_free_netdev;
 		}
 		if (upper_32_bits(priv->txdescmem_busaddr)) {
 			dev_dbg(priv->device,
 				"SGDMA bus addresses greater than 32-bits\n");
+			ret = -EINVAL;
 			goto err_free_netdev;
 		}
 	} else if (priv->dmaops &&
