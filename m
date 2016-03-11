From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH V2 net 1/4] net: hns: fix a bug for cycle index
Date: Fri, 11 Mar 2016 18:20:19 +0800
Message-ID: <1457691622-124657-2-git-send-email-lisheng011@huawei.com>
References: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63254 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbcCKKK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:10:28 -0500
In-Reply-To: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The cycle index should be varied while the variable j is a fixed value.
The patch will fix this bug.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 7fe1c1c..ef4f154 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2182,17 +2182,17 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 	/* dsaf onode registers */
 	for (i = 0; i < DSAF_XOD_NUM; i++) {
 		p[311 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_TSA_TC0_TC3_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_TSA_TC0_TC3_CFG_0_REG + i * 0x90);
 		p[319 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_TSA_TC4_TC7_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_TSA_TC4_TC7_CFG_0_REG + i * 0x90);
 		p[327 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_BW_TC0_TC3_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_BW_TC0_TC3_CFG_0_REG + i * 0x90);
 		p[335 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_BW_TC4_TC7_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_BW_TC4_TC7_CFG_0_REG + i * 0x90);
 		p[343 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_BW_OFFSET_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_BW_OFFSET_CFG_0_REG + i * 0x90);
 		p[351 + i] = dsaf_read_dev(ddev,
-				DSAF_XOD_ETS_TOKEN_CFG_0_REG + j * 0x90);
+				DSAF_XOD_ETS_TOKEN_CFG_0_REG + i * 0x90);
 	}
 
 	p[359] = dsaf_read_dev(ddev, DSAF_XOD_PFS_CFG_0_0_REG + port * 0x90);
-- 
1.9.1
