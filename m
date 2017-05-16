From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/2] bnxt_en: Check status of firmware DCBX agent before setting DCB_CAP_DCBX_HOST.
Date: Tue, 16 May 2017 16:39:44 -0400
Message-ID: <1494967184-12865-3-git-send-email-michael.chan@broadcom.com>
References: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34323 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdEPUkb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:40:31 -0400
Received: by mail-pf0-f174.google.com with SMTP id 9so46178039pfj.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:40:31 -0700 (PDT)
In-Reply-To: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, all the host based DCBX settings from lldpad will fail if the
firmware DCBX agent is running.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index 46de2f8..5c6dd0c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -553,8 +553,10 @@ static u8 bnxt_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	if ((mode & DCB_CAP_DCBX_VER_CEE) || !(mode & DCB_CAP_DCBX_VER_IEEE))
 		return 1;
 
-	if ((mode & DCB_CAP_DCBX_HOST) && BNXT_VF(bp))
-		return 1;
+	if (mode & DCB_CAP_DCBX_HOST) {
+		if (BNXT_VF(bp) || (bp->flags & BNXT_FLAG_FW_LLDP_AGENT))
+			return 1;
+	}
 
 	if (mode == bp->dcbx_cap)
 		return 0;
-- 
1.8.3.1
