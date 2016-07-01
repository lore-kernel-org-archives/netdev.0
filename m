From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/11] bnxt_en: Assign netdev->dev_port with port ID.
Date: Fri,  1 Jul 2016 18:46:28 -0400
Message-ID: <1467413189-29566-11-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36285 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbcGAWqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:52 -0400
Received: by mail-pf0-f173.google.com with SMTP id t190so43956263pfb.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:52 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is useful for multi-function devices.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2740ac3..18be62b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4026,6 +4026,7 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 
 		pf->fw_fid = le16_to_cpu(resp->fid);
 		pf->port_id = le16_to_cpu(resp->port_id);
+		bp->dev->dev_port = pf->port_id;
 		memcpy(pf->mac_addr, resp->mac_address, ETH_ALEN);
 		memcpy(bp->dev->dev_addr, pf->mac_addr, ETH_ALEN);
 		pf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
-- 
1.8.3.1
