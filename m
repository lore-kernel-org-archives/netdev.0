From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 1/7] net: hns: fix a bug for cycle index
Date: Thu, 24 Mar 2016 19:08:00 +0800
Message-ID: <1458817686-159708-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qianqian Xie <xieqianqian@huawei.com>

The cycle index should be varied while the variable j is a fixed value.
The patch will fix this bug.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 5c1ac9b..5978a5c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2219,17 +2219,17 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
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
