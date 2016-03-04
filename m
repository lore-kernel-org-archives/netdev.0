From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 2/3] net: hns: modified dump overtime regs
Date: Fri, 4 Mar 2016 12:38:15 +0800
Message-ID: <1457066296-66202-3-git-send-email-lisheng011@huawei.com>
References: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In V2 chip, the timeover reg_addr is different from V1;
And there are 6 regs for service ports,that is different from V1.
In dump regs function, should also fix this change.

Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 106af93..28ee26e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -931,6 +931,10 @@ void hns_rcb_get_strings(int stringset, u8 *data, int index)
 void hns_rcb_get_common_regs(struct rcb_common_cb *rcb_com, void *data)
 {
 	u32 *regs = data;
+	bool is_ver1 = AE_IS_VER1(rcb_com->dsaf_dev->dsaf_ver);
+	bool is_dbg = (rcb_com->comm_index != HNS_DSAF_COMM_SERVICE_NW_IDX);
+	u32 reg_tmp;
+	u32 reg_num_tmp;
 	u32 i = 0;
 
 	/*rcb common registers */
@@ -984,12 +988,16 @@ void hns_rcb_get_common_regs(struct rcb_common_cb *rcb_com, void *data)
 			= dsaf_read_dev(rcb_com, RCB_CFG_PKTLINE_REG + 4 * i);
 	}
 
-	regs[70] = dsaf_read_dev(rcb_com, RCB_CFG_OVERTIME_REG);
-	regs[71] = dsaf_read_dev(rcb_com, RCB_CFG_PKTLINE_INT_NUM_REG);
-	regs[72] = dsaf_read_dev(rcb_com, RCB_CFG_OVERTIME_INT_NUM_REG);
+	reg_tmp = is_ver1 ? RCB_CFG_OVERTIME_REG : RCB_PORT_CFG_OVERTIME_REG;
+	reg_num_tmp = (is_ver1 || is_dbg) ? 1 : 6;
+	for (i = 0; i < reg_num_tmp; i++)
+		regs[70 + i] = dsaf_read_dev(rcb_com, reg_tmp);
+
+	regs[76] = dsaf_read_dev(rcb_com, RCB_CFG_PKTLINE_INT_NUM_REG);
+	regs[77] = dsaf_read_dev(rcb_com, RCB_CFG_OVERTIME_INT_NUM_REG);
 
 	/* mark end of rcb common regs */
-	for (i = 73; i < 80; i++)
+	for (i = 78; i < 80; i++)
 		regs[i] = 0xcccccccc;
 }
 
-- 
1.9.1
