From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 02/19] net: hns: fix hns dsaf v1 dont support tx_pause close
Date: Tue, 21 Jun 2016 11:56:22 +0800
Message-ID: <1466481399-70080-3-git-send-email-Yisen.Zhuang@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:42931 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbcFUDiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:38:19 -0400
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqiaqian@huawei.com>

For service port, hns dsaf v1 support to close tx_pause.
However, the port will be invalid when it run command
ethtool to close tx_pause. This patch will fix it.

Signed-off-by: Qianqian Xie <xieqiaqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index ac03c4a..422f97d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1114,10 +1114,10 @@ int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				 u32 en)
 {
 	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
-		if (!en)
+		if (!en) {
 			dev_err(dsaf_dev->dev, "dsafv1 can't close rx_pause!\n");
-
-		return -EINVAL;
+			return -EINVAL;
+		}
 	}
 
 	dsaf_set_dev_bit(dsaf_dev, DSAF_PAUSE_CFG_REG + mac_id * 4,
-- 
1.9.1
