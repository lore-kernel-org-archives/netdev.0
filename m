From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] qlcnic: correctly handle qlcnic_alloc_mbx_args
Date: Tue, 29 Dec 2015 15:02:18 -0500
Message-ID: <1451419338-15198-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since qlcnic_alloc_mbx_args can be failed, 
return value should be checked.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index a5f422f..daf0515 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -772,8 +772,10 @@ int qlcnic_82xx_config_intrpt(struct qlcnic_adapter *adapter, u8 op_type)
 	int i, err = 0;
 
 	for (i = 0; i < ahw->num_msix; i++) {
-		qlcnic_alloc_mbx_args(&cmd, adapter,
-				      QLCNIC_CMD_MQ_TX_CONFIG_INTR);
+		err = qlcnic_alloc_mbx_args(&cmd, adapter,
+					    QLCNIC_CMD_MQ_TX_CONFIG_INTR);
+		if (err)
+			return err;
 		type = op_type ? QLCNIC_INTRPT_ADD : QLCNIC_INTRPT_DEL;
 		val = type | (ahw->intr_tbl[i].type << 4);
 		if (ahw->intr_tbl[i].type == QLCNIC_INTRPT_MSIX)
-- 
1.9.1
