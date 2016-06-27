From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 2/9] net: hns: fix code style about hns driver
Date: Mon, 27 Jun 2016 17:54:08 +0800
Message-ID: <1467021255-95900-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
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
Received: from szxga01-in.huawei.com ([58.251.152.64]:32871 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbcF0Jf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 05:35:59 -0400
In-Reply-To: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

This patch fixes code sytle of hns driver to make it
simple.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 8473287..611b67b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -253,10 +253,9 @@ static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 		reg_val_1  = 0x1 << port;
 		port_rst_off = dsaf_dev->mac_cb[port]->port_rst_off;
 		/* there is difference between V1 and V2 in register.*/
-		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
-			reg_val_2  = 0x1041041 << port_rst_off;
-		else
-			reg_val_2  = 0x2082082 << port_rst_off;
+		reg_val_2 = AE_IS_VER1(dsaf_dev->dsaf_ver) ?
+				0x1041041 : 0x2082082;
+		reg_val_2 <<= port_rst_off;
 
 		if (!dereset) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
@@ -272,12 +271,11 @@ static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 				       reg_val_1);
 		}
 	} else {
-		reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
+		reg_val_1 = 0x15540;
+		reg_val_2 = AE_IS_VER1(dsaf_dev->dsaf_ver) ? 0x100 : 0x40;
 
-		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
-			reg_val_2 = 0x100 << dsaf_dev->reset_offset;
-		else
-			reg_val_2 = 0x40 << dsaf_dev->reset_offset;
+		reg_val_1 <<= dsaf_dev->reset_offset;
+		reg_val_2 <<= dsaf_dev->reset_offset;
 
 		if (!dereset) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
-- 
1.9.1
