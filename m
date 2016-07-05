From: weiyj_lk@163.com
Subject: [PATCH -next v2] net: hns: fix return value check in hns_dsaf_get_cfg()
Date: Tue,  5 Jul 2016 07:56:52 +0000
Message-ID: <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
	Salil Mehta <salil.mehta@huawei.com>,
	Kejian Yan <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:41659 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbcGEH60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 03:58:26 -0400
In-Reply-To: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, function devm_ioremap_resource() returns ERR_PTR()
and never returns NULL. The NULL test in the return value check should
be replaced with IS_ERR().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 86ce28a..2ef4277 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -114,9 +114,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 
 			dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev,
 								  res);
-			if (!dsaf_dev->sc_base) {
+			if (IS_ERR(dsaf_dev->sc_base)) {
 				dev_err(dsaf_dev->dev, "subctrl can not map!\n");
-				return -ENOMEM;
+				return PTR_ERR(dsaf_dev->sc_base);
 			}
 
 			res = platform_get_resource(pdev, IORESOURCE_MEM,
@@ -128,9 +128,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 
 			dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev,
 								   res);
-			if (!dsaf_dev->sds_base) {
+			if (IS_ERR(dsaf_dev->sds_base)) {
 				dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
-				return -ENOMEM;
+				return PTR_ERR(dsaf_dev->sds_base);
 			}
 		} else {
 			dsaf_dev->sub_ctrl = syscon;
@@ -146,9 +146,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		}
 	}
 	dsaf_dev->ppe_base = devm_ioremap_resource(&pdev->dev, res);
-	if (!dsaf_dev->ppe_base) {
+	if (IS_ERR(dsaf_dev->ppe_base)) {
 		dev_err(dsaf_dev->dev, "ppe-base resource can not map!\n");
-		return -ENOMEM;
+		return PTR_ERR(dsaf_dev->ppe_base);
 	}
 	dsaf_dev->ppe_paddr = res->start;
 
@@ -165,9 +165,9 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 			}
 		}
 		dsaf_dev->io_base = devm_ioremap_resource(&pdev->dev, res);
-		if (!dsaf_dev->io_base) {
+		if (IS_ERR(dsaf_dev->io_base)) {
 			dev_err(dsaf_dev->dev, "dsaf-base resource can not map!\n");
-			return -ENOMEM;
+			return PTR_ERR(dsaf_dev->io_base);
 		}
 	}
