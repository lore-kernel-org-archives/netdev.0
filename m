From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 05/10] net: hns: set xge statistic reg as read only
Date: Tue, 22 Mar 2016 16:06:26 +0800
Message-ID: <1458633991-64313-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34668 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbcCVHvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 03:51:45 -0400
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

As the user manual of HNS V2 describs, XGE_DFX_CTRL_CFG.xge_dfx_ctrl_cfg
should be configed as zero if we want xge statistic reg to be read only.
But HNS V1 gets the other meanings. It needs to be identified the process
and then config it rightly.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 38fc5be..5c1ac9b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -748,8 +748,9 @@ static void hns_dsaf_tbl_stat_en(struct dsaf_device *dsaf_dev)
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
