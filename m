From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 17/19] net: hns: Adjust the SBM module buffer threshold
Date: Thu, 30 Mar 2017 16:31:04 +0100
Message-ID: <20170330153106.14344-18-salil.mehta@huawei.com>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

HNS needs SMB Buffers to store at least two packets after sending
pause frame because of the link delay. The MTU of HNS is 9728. As
the processor user manual described, the SBM buffer threshold should
be modified.

Reported-by: Ping Zhang <zhangping5@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index abd8aec..d07b4fe 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -510,10 +510,10 @@ static void hns_dsafv2_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
 		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 48);
+			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 55);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 80);
+			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 110);
 		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
 
 		/* for no enable pfc mode */
@@ -521,10 +521,10 @@ static void hns_dsafv2_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
 		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S, 192);
+			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S, 128);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S, 240);
+			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S, 192);
 		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
 	}
 
-- 
2.7.4
