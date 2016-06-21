From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 12/19] net: hns: fix bug of getting the wrong tcam data
Date: Tue, 21 Jun 2016 11:56:32 +0800
Message-ID: <1466481399-70080-13-git-send-email-Yisen.Zhuang@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

The current driver stores the high bit value of tcam data register
to the tcam data low element, stores the low bit value of tcam data
register to tcam data high element, this patch fixes this bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 0958ceb..7f5c248 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -975,9 +975,9 @@ static void hns_dsaf_tcam_uc_get(
 
 	/*read tcam data*/
 	ptbl_tcam_data->tbl_tcam_data_high
-		= dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
-	ptbl_tcam_data->tbl_tcam_data_low
 		= dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_HIGH_0_REG);
+	ptbl_tcam_data->tbl_tcam_data_low
+		= dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
 
 	/*read tcam mcast*/
 	tcam_read_data0 = dsaf_read_dev(dsaf_dev,
@@ -1027,9 +1027,9 @@ static void hns_dsaf_tcam_mc_get(
 
 	/*read tcam data*/
 	ptbl_tcam_data->tbl_tcam_data_high =
-		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
-	ptbl_tcam_data->tbl_tcam_data_low =
 		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_HIGH_0_REG);
+	ptbl_tcam_data->tbl_tcam_data_low =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
 
 	/*read tcam mcast*/
 	ptbl_tcam_mcast->tbl_mcast_port_msk[0] =
-- 
1.9.1
