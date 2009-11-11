From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/4] qlge: Do not change frame routing during suspend.
Date: Wed, 11 Nov 2009 14:54:03 -0800
Message-ID: <1257980046-2420-2-git-send-email-ron.mercer@qlogic.com>
References: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24232 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759487AbZKKXAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 18:00:35 -0500
In-Reply-To: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not need to change the frame routing to direct all frames to the
management fifo during suspend.  This is now done by the firmware.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index bd8e164..2bfa783 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3514,9 +3514,6 @@ int ql_wol(struct ql_adapter *qdev)
 	}
 
 	if (qdev->wol) {
-		/* Reroute all packets to Management Interface */
-		ql_write32(qdev, MGMT_RCV_CFG, (MGMT_RCV_CFG_RM |
-			(MGMT_RCV_CFG_RM << 16)));
 		wol |= MB_WOL_MODE_ON;
 		status = ql_mb_wol_mode(qdev, wol);
 		QPRINTK(qdev, DRV, ERR, "WOL %s (wol code 0x%x) on %s\n",
-- 
1.6.0.2

