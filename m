From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 3/4] qlcnic: Fix firmware abort code check.
Date: Fri, 3 Feb 2012 15:45:43 -0800
Message-ID: <1328312745-19245-3-git-send-email-sony.chacko@qlogic.com>
References: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:33578
	"EHLO AM1EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753563Ab2BDABk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:01:40 -0500
In-Reply-To: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Check bits 8-28 of peg_halt status register for firmware abort code.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a47c70b..dba9531 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3159,7 +3159,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
 	peg_status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
-	if (LSW(MSB(peg_status)) == 0x67)
+	if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 		dev_err(&adapter->pdev->dev,
 			"Firmware aborted with error code 0x00006700. "
 				"Device is being reset.\n");
-- 
1.6.4.4
