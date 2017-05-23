From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 04/11] qed: Log incorrectly installed board
Date: Tue, 23 May 2017 09:41:21 +0300
Message-ID: <1495521688-27669-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0074.outbound.protection.outlook.com ([104.47.36.74]:55088
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964962AbdEWGmh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:37 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

In case nvram layout of board is incorrect, board may exhibit peculiar
oddities. Log such a rare event.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 5 +++++
 drivers/net/ethernet/qlogic/qed/qed_hsi.h | 2 ++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 9dd28ba..b01df24 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1698,6 +1698,11 @@ int qed_hw_init(struct qed_dev *cdev, struct qed_hw_init_params *p_params)
 			return mfw_rc;
 		}
 
+		/* Check if there is a DID mismatch between nvm-cfg/efuse */
+		if (param & FW_MB_PARAM_LOAD_DONE_DID_EFUSE_ERROR)
+			DP_NOTICE(p_hwfn,
+				  "warning: device configuration is not supported on this board type. The device may not function as expected.\n");
+
 		/* send DCBX attention request command */
 		DP_VERBOSE(p_hwfn,
 			   QED_MSG_DCB,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index eedf79a..4755d0b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -11655,6 +11655,8 @@ struct public_drv_mb {
 #define FW_MB_PARAM_GET_PF_RDMA_IWARP		0x2
 #define FW_MB_PARAM_GET_PF_RDMA_BOTH		0x3
 
+#define FW_MB_PARAM_LOAD_DONE_DID_EFUSE_ERROR	(1 << 0)
+
 	u32 drv_pulse_mb;
 #define DRV_PULSE_SEQ_MASK			0x00007fff
 #define DRV_PULSE_SYSTEM_TIME_MASK		0xffff0000
-- 
1.9.3
