From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/2] qlcnic: fix checks for auto_fw_reset
Date: Wed, 23 Feb 2011 05:21:24 -0800
Message-ID: <1298467285-7201-2-git-send-email-amit.salecha@qlogic.com>
References: <1298467285-7201-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26687 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753079Ab1BWNVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 08:21:39 -0500
In-Reply-To: <1298467285-7201-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Remove checks of 1 for auto_fw_reset module parameter.
  auto_fw_reset is of type int and can have value > 1.
o Remove unnecessary #define for 1

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_main.c |    9 ++++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 44e316f..fa7f794 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -867,7 +867,6 @@ struct qlcnic_nic_intr_coalesce {
 #define LINKEVENT_LINKSPEED_MBPS	0
 #define LINKEVENT_LINKSPEED_ENCODED	1
 
-#define AUTO_FW_RESET_ENABLED	0x01
 /* firmware response header:
  *	63:58 - message type
  *	57:56 - owner
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 37c04b4..4994b94 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -42,7 +42,7 @@ static int use_msi_x = 1;
 module_param(use_msi_x, int, 0444);
 MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
 
-static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
+static int auto_fw_reset = 1;
 module_param(auto_fw_reset, int, 0644);
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
 
@@ -2959,8 +2959,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->reset_context &&
-		    auto_fw_reset == AUTO_FW_RESET_ENABLED) {
+		if (adapter->reset_context && auto_fw_reset) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2973,7 +2972,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_request_reset(adapter);
 
-	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED))
+	if (auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_info(&netdev->dev, "firmware hang detected\n");
@@ -2982,7 +2981,7 @@ detach:
 	adapter->dev_state = (state == QLCNIC_DEV_NEED_QUISCENT) ? state :
 		QLCNIC_DEV_NEED_RESET;
 
-	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED) &&
+	if (auto_fw_reset &&
 		!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
 
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
-- 
1.7.3.2

