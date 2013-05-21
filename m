From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: remove netdev->trans_start updates within the driver
Date: Tue, 21 May 2013 15:27:00 -0400
Message-ID: <1369164421-20996-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:44065 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752560Ab3EUTwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 15:52:11 -0400
In-Reply-To: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Code is removed because netdev->trans_start updates made by the driver
will be ignored by the kernel.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 +---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 -
 3 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index c67d1eb..5e7fb1d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -382,8 +382,6 @@ static int qlcnic_83xx_idc_tx_soft_reset(struct qlcnic_adapter *adapter)
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
 
-	adapter->netdev->trans_start = jiffies;
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9a7519f..0da38df 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3153,10 +3153,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->ahw->reset_context && qlcnic_auto_fw_reset) {
+		if (adapter->ahw->reset_context && qlcnic_auto_fw_reset)
 			qlcnic_reset_hw_context(adapter);
-			adapter->netdev->trans_start = jiffies;
-		}
 
 		return 0;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 3869c38..196b2d1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -1734,7 +1734,6 @@ static int qlcnic_sriov_vf_handle_context_reset(struct qlcnic_adapter *adapter)
 
 	if (!qlcnic_sriov_vf_reinit_driver(adapter)) {
 		qlcnic_sriov_vf_attach(adapter);
-		adapter->netdev->trans_start = jiffies;
 		adapter->tx_timeo_cnt = 0;
 		adapter->reset_ctx_cnt = 0;
 		adapter->fw_fail_cnt = 0;
-- 
1.5.6
