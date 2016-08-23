From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: hns: remove redundant dev_err call in hns_dsaf_get_cfg()
Date: Tue, 23 Aug 2016 15:11:03 +0000
Message-ID: <1471965063-2494-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daode Huang <huangdaode@hisilicon.com>,
        Kejian Yan <yankejian@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33329 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcHWPL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:11:29 -0400
Received: by mail-pa0-f65.google.com with SMTP id vy10so10075223pac.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:11:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 05bd19f..eb448df 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -116,10 +116,8 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 
 			dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev,
 								  res);
-			if (IS_ERR(dsaf_dev->sc_base)) {
-				dev_err(dsaf_dev->dev, "subctrl can not map!\n");
+			if (IS_ERR(dsaf_dev->sc_base))
 				return PTR_ERR(dsaf_dev->sc_base);
-			}
 
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
 						    res_idx++);
@@ -130,10 +128,8 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 
 			dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev,
 								   res);
-			if (IS_ERR(dsaf_dev->sds_base)) {
-				dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
+			if (IS_ERR(dsaf_dev->sds_base))
 				return PTR_ERR(dsaf_dev->sds_base);
-			}
 		} else {
 			dsaf_dev->sub_ctrl = syscon;
 		}
@@ -148,10 +144,8 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		}
 	}
 	dsaf_dev->ppe_base = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(dsaf_dev->ppe_base)) {
-		dev_err(dsaf_dev->dev, "ppe-base resource can not map!\n");
+	if (IS_ERR(dsaf_dev->ppe_base))
 		return PTR_ERR(dsaf_dev->ppe_base);
-	}
 	dsaf_dev->ppe_paddr = res->start;
 
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
@@ -167,10 +161,8 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 			}
 		}
 		dsaf_dev->io_base = devm_ioremap_resource(&pdev->dev, res);
-		if (IS_ERR(dsaf_dev->io_base)) {
-			dev_err(dsaf_dev->dev, "dsaf-base resource can not map!\n");
+		if (IS_ERR(dsaf_dev->io_base))
 			return PTR_ERR(dsaf_dev->io_base);
-		}
 	}
 
 	ret = device_property_read_u32(dsaf_dev->dev, "desc-num", &desc_num);
