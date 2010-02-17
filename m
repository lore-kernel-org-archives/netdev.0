From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 2/8] bnx2x: clean up in case of error in bnx2x_init_hw()
Date: Wed, 17 Feb 2010 14:03:33 +0200
Message-ID: <1266408213.25691.843.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2045 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756831Ab0BQMMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: clean up MCP state in case of error in bnx2x_init_hw().

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d7aef84..16685a1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7530,6 +7530,9 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_init_hw(bp, load_code);
 	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
+		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
 		goto load_error2;
 	}
 
-- 
1.6.3.3




