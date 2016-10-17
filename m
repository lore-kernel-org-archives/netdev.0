From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] fsl/fman: fix error return code in mac_probe()
Date: Mon, 17 Oct 2016 15:19:56 +0000
Message-ID: <1476717596-19526-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33517 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932871AbcJQPUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:20:02 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so9348744pac.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 08:20:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Fixes: 3933961682a3 ("fsl/fman: Add FMan MAC driver")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 8fe6b3e..cc5d07c 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -879,13 +879,17 @@ static int mac_probe(struct platform_device *_of_dev)
 
 		priv->fixed_link = kzalloc(sizeof(*priv->fixed_link),
 					   GFP_KERNEL);
-		if (!priv->fixed_link)
+		if (!priv->fixed_link) {
+			err = -ENOMEM;
 			goto _return_dev_set_drvdata;
+		}
 
 		priv->phy_node = of_node_get(mac_node);
 		phy = of_phy_find_device(priv->phy_node);
-		if (!phy)
+		if (!phy) {
+			err = -EINVAL;
 			goto _return_dev_set_drvdata;
+		}
 
 		priv->fixed_link->link = phy->link;
 		priv->fixed_link->speed = phy->speed;
