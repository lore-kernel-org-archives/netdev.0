From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 15/18] net: hns: Simplify the exception sequence in hns_ppe_init()
Date: Fri, 31 Mar 2017 12:20:29 +0100
Message-ID: <20170331112032.4692-16-salil.mehta@huawei.com>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4873 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S933294AbdCaLWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:22:21 -0400
In-Reply-To: <20170331112032.4692-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

We need to free all ppe submodule if it fails to initialize ppe by
any fault, so this patch will free all ppe resource before
hns_ppe_init() returns exception situation

Reported-by: JinchuanTian <tianjinchuan1@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 6ea8722..eba406b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -496,17 +496,17 @@ void hns_ppe_get_stats(struct hns_ppe_cb *ppe_cb, u64 *data)
  */
 int hns_ppe_init(struct dsaf_device *dsaf_dev)
 {
-	int i, k;
 	int ret;
+	int i;
 
 	for (i = 0; i < HNS_PPE_COM_NUM; i++) {
 		ret = hns_ppe_common_get_cfg(dsaf_dev, i);
 		if (ret)
-			goto get_ppe_cfg_fail;
+			goto get_cfg_fail;
 
 		ret = hns_rcb_common_get_cfg(dsaf_dev, i);
 		if (ret)
-			goto get_rcb_cfg_fail;
+			goto get_cfg_fail;
 
 		hns_ppe_get_cfg(dsaf_dev->ppe_common[i]);
 
@@ -518,13 +518,12 @@ int hns_ppe_init(struct dsaf_device *dsaf_dev)
 
 	return 0;
 
-get_rcb_cfg_fail:
-	hns_ppe_common_free_cfg(dsaf_dev, i);
-get_ppe_cfg_fail:
-	for (k = i - 1; k >= 0; k--) {
-		hns_rcb_common_free_cfg(dsaf_dev, k);
-		hns_ppe_common_free_cfg(dsaf_dev, k);
+get_cfg_fail:
+	for (i = 0; i < HNS_PPE_COM_NUM; i++) {
+		hns_rcb_common_free_cfg(dsaf_dev, i);
+		hns_ppe_common_free_cfg(dsaf_dev, i);
 	}
+
 	return ret;
 }
 
-- 
2.7.4
