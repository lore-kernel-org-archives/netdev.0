From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 6/9] bnxt_en: Do not setup PHY unless driving a single PF.
Date: Sun, 12 Feb 2017 19:18:15 -0500
Message-ID: <1486945098-4086-7-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35469 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdBMATA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:19:00 -0500
Received: by mail-it0-f54.google.com with SMTP id 203so170032420ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:19:00 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If it is a VF or an NPAR function, the firmware call to setup the PHY
will fail.  Adding this check will prevent unnecessary firmware calls
to setup the PHY unless calling from the PF.  This will also eliminate
many unnecessary warning messages when the call from a VF or NPAR fails.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f3d829f..afd1190 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5853,6 +5853,9 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 			   rc);
 		return rc;
 	}
+	if (!BNXT_SINGLE_PF(bp))
+		return 0;
+
 	if ((link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) &&
 	    (link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) !=
 	    link_info->req_flow_ctrl)
-- 
1.8.3.1
