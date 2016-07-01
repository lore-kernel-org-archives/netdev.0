From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 2/9] net: hns: fix code style about hns driver
Date: Fri, 1 Jul 2016 17:34:06 +0800
Message-ID: <1467365653-83331-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch fixes code sytle of hns driver to make it
simple.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
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
