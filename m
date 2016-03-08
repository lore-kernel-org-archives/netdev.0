From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net] net: hns: set xge statistic reg as read only
Date: Tue, 8 Mar 2016 11:51:47 +0800
Message-ID: <1457409107-77001-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:42619 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbcCHDlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:41:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

As the user manual describs, XGE_DFX_CTRL_CFG.xge_dfx_ctrl_cfg should be
configed as zero if we want xge statistic reg to be read only. But the
older hisilicon arm64 process gets the other meanings. So it seems that
we need to identify the process and then config it rightly.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9439f04..7fe1c1c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -714,8 +714,9 @@ static void hns_dsaf_tbl_stat_en(struct dsaf_device *dsaf_dev)
  */
 static void hns_dsaf_rocee_bp_en(struct dsaf_device *dsaf_dev)
 {
-	dsaf_set_dev_bit(dsaf_dev, DSAF_XGE_CTRL_SIG_CFG_0_REG,
-			 DSAF_FC_XGE_TX_PAUSE_S, 1);
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+		dsaf_set_dev_bit(dsaf_dev, DSAF_XGE_CTRL_SIG_CFG_0_REG,
+				 DSAF_FC_XGE_TX_PAUSE_S, 1);
 }
 
 /* set msk for dsaf exception irq*/
-- 
1.9.1
