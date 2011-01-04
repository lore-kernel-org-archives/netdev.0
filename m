From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] cnic: Do not allow iSCSI and FCoE on bnx2x
 multi-function mode
Date: Mon, 3 Jan 2011 17:21:45 -0800
Message-ID: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3044 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144Ab1ADCQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 21:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the hardware does not yet support these in this mode.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4a9c628..41957fa 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4826,12 +4826,8 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 		val = CNIC_RD(dev, addr);
 		val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-			addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
-				func_mf_config[func].config);
-			val = CNIC_RD(dev, addr);
-			val &= FUNC_MF_CFG_PROTOCOL_MASK;
-			if (val != FUNC_MF_CFG_PROTOCOL_ISCSI)
-				dev->max_iscsi_conn = 0;
+			dev->max_fcoe_conn = 0;
+			dev->max_iscsi_conn = 0;
 		}
 	}
 	if (!is_valid_ether_addr(dev->mac_addr))
-- 
1.6.4.GIT


