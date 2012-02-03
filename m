From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 1/4] qlcnic: Stop pause ctrl frames on fw hang.
Date: Fri, 3 Feb 2012 15:45:41 -0800
Message-ID: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:43381
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753925Ab2BDABk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:01:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

When firmware hang is detected, fw should stop sending pause control frames.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 7bfdf57..a47c70b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2999,8 +2999,18 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 {
-	u32 state;
-
+	u32 state, xg_val = 0, gb_val = 0;
+
+	qlcnic_xg_set_xg0_mask(xg_val);
+	qlcnic_xg_set_xg1_mask(xg_val);
+	QLCWR32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, xg_val);
+	qlcnic_gb_set_gb0_mask(gb_val);
+	qlcnic_gb_set_gb1_mask(gb_val);
+	qlcnic_gb_set_gb2_mask(gb_val);
+	qlcnic_gb_set_gb3_mask(gb_val);
+	QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, gb_val);
+	dev_info(&adapter->pdev->dev, "Pause control frames disabled"
+				" on all ports\n");
 	adapter->need_fw_reset = 1;
 	if (qlcnic_api_lock(adapter))
 		return;
-- 
1.6.4.4
