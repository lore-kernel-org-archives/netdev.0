From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/4] qlcnic: change reg name
Date: Wed, 25 Aug 2010 07:03:05 -0700
Message-ID: <1282744985-31540-5-git-send-email-amit.salecha@qlogic.com>
References: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27670 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753966Ab0HYODG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 10:03:06 -0400
In-Reply-To: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change QLCNIC_CRB_DEV_REF_COUNT to QLCNIC_CRB_DRV_ACTIVE to match
document.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    2 +-
 drivers/net/qlcnic/qlcnic_hdr.h     |    2 +-
 drivers/net/qlcnic/qlcnic_main.c    |   12 ++++++------
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 2805f88..e294b82 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -99,7 +99,7 @@ static const u32 diag_registers[] = {
 	CRB_XG_STATE_P3,
 	CRB_FW_CAPABILITIES_1,
 	ISR_INT_STATE_REG,
-	QLCNIC_CRB_DEV_REF_COUNT,
+	QLCNIC_CRB_DRV_ACTIVE,
 	QLCNIC_CRB_DEV_STATE,
 	QLCNIC_CRB_DRV_STATE,
 	QLCNIC_CRB_DRV_SCRATCH,
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 794f657..219de9f 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -698,7 +698,7 @@ enum {
 #define QLCNIC_PEG_ALIVE_COUNTER	(QLCNIC_CAM_RAM(0xb0))
 #define QLCNIC_PEG_HALT_STATUS1 	(QLCNIC_CAM_RAM(0xa8))
 #define QLCNIC_PEG_HALT_STATUS2 	(QLCNIC_CAM_RAM(0xac))
-#define QLCNIC_CRB_DEV_REF_COUNT	(QLCNIC_CAM_RAM(0x138))
+#define QLCNIC_CRB_DRV_ACTIVE	(QLCNIC_CAM_RAM(0x138))
 #define QLCNIC_CRB_DEV_STATE		(QLCNIC_CAM_RAM(0x140))
 
 #define QLCNIC_CRB_DRV_STATE		(QLCNIC_CAM_RAM(0x144))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 26d9e10..630a077 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -540,7 +540,7 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	void __iomem *priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
@@ -2404,9 +2404,9 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 	if (qlcnic_api_lock(adapter))
 		goto err;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
+	QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 
 	if (failed) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
@@ -2433,7 +2433,7 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 	int act, state;
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	act = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (((state & 0x11111111) == (act & 0x11111111)) ||
 			((act & 0x11111111) == ((state >> 1) & 0x11111111)))
@@ -2468,10 +2468,10 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	if (!(val & (1 << (portnum * 4)))) {
 		QLC_DEV_SET_REF_CNT(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
+		QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 	}
 
 	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-- 
1.6.0.2

