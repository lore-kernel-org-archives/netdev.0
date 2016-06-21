From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 01/19] net: hns: bug fix of ge reset sequence
Date: Tue, 21 Jun 2016 11:56:21 +0800
Message-ID: <1466481399-70080-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42935 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbcFUDiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:38:19 -0400
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The bit fileds of PPE reset register are different between HNS v1 and
HNS v2, but the current procedure just only match HNS v1. Here is a
patch to fix it.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 96cb628..09e60d6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -271,7 +271,11 @@ static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 		}
 	} else {
 		reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
-		reg_val_2 = 0x100 << dsaf_dev->reset_offset;
+
+		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+			reg_val_2 = 0x100 << dsaf_dev->reset_offset;
+		else
+			reg_val_2 = 0x40 << dsaf_dev->reset_offset;
 
 		if (!dereset) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
-- 
1.9.1
