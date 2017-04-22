From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/5] bnxt_en: Check the FW_LLDP_AGENT flag before allowing DCBX host agent.
Date: Fri, 21 Apr 2017 20:11:25 -0400
Message-ID: <1492819886-19625-5-git-send-email-michael.chan@broadcom.com>
References: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36516 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426544AbdDVALo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:11:44 -0400
Received: by mail-wr0-f182.google.com with SMTP id c55so62834206wrc.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:11:43 -0700 (PDT)
In-Reply-To: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the additional flag in bnxt_hwrm_func_qcfg() before allowing
DCBX to be done in host mode.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 447ee3d..9130628 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4483,7 +4483,8 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 	}
 #endif
 	if (BNXT_PF(bp) && (le16_to_cpu(resp->flags) &
-			    FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED))
+			    (FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED |
+			     FUNC_QCFG_RESP_FLAGS_FW_LLDP_AGENT_ENABLED)))
 		bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
 
 	switch (resp->port_partition_type) {
-- 
1.8.3.1
