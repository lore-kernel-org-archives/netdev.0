From: amit.salecha@qlogic.com
Subject: [PATCHv3 NEXT 2/5] qlcnic: disable tx timeout recovery
Date: Tue, 13 Jul 2010 23:33:32 -0700
Message-ID: <1279089215-23231-3-git-send-email-amit.salecha@qlogic.com>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:37212 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752372Ab0GNGdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 02:33:36 -0400
In-Reply-To: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Disable tx timeout recovery, if auto_fw_reset is disable

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 4d18313..0fef8c3 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2581,7 +2581,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->reset_context) {
+		if (adapter->reset_context &&
+		    auto_fw_reset == AUTO_FW_RESET_ENABLED) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2594,7 +2595,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_request_reset(adapter);
 
-	clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
+	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED))
+		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_info(&netdev->dev, "firmware hang detected\n");
 
-- 
1.6.0.2

