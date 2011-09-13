From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/2] qlcnic: Added error logging for firmware abort
Date: Tue, 13 Sep 2011 11:06:17 -0700
Message-ID: <1315937179-22383-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:11027
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932101Ab1IMSR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 14:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ameen Rahman <ameen.rahman@qlogic.com>

Signed-off-by: Ameen Rahman <ameen.rahman@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 690c93f..248d5fc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3087,7 +3087,7 @@ static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
 	u32 state = 0, heartbeat;
-	struct net_device *netdev = adapter->netdev;
+	u32 peg_status;
 
 	if (qlcnic_check_temp(adapter))
 		goto detach;
@@ -3127,8 +3127,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 	if (auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
-	dev_info(&netdev->dev, "firmware hang detected\n");
-	dev_info(&adapter->pdev->dev, "Dumping hw/fw registers\n"
+	dev_err(&adapter->pdev->dev, "firmware hang detected\n");
+	dev_err(&adapter->pdev->dev, "Dumping hw/fw registers\n"
 			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
 			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
 			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
@@ -3140,6 +3140,11 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
+	peg_status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+	if (LSW(MSB(peg_status)) == 0x67)
+		dev_err(&adapter->pdev->dev,
+			"Firmware aborted with error code 0x00006700. "
+				"Device is being reset.\n");
 detach:
 	adapter->dev_state = (state == QLCNIC_DEV_NEED_QUISCENT) ? state :
 		QLCNIC_DEV_NEED_RESET;
-- 
1.7.4.1
