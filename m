From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/11] bnxt_en: Enable MRU enables bit when configuring VNIC MRU.
Date: Fri,  1 Jul 2016 18:46:25 -0400
Message-ID: <1467413189-29566-8-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34865 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbcGAWqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:49 -0400
Received: by mail-pa0-f49.google.com with SMTP id hl6so42285114pac.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:49 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For correctness, the MRU enables bit must be set when passing the
MRU to firmware during vnic configuration.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b489fb6..28a5aee 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3414,7 +3414,8 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_CFG, -1, -1);
 	/* Only RSS support for now TBD: COS & LB */
 	req.enables = cpu_to_le32(VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP |
-				  VNIC_CFG_REQ_ENABLES_RSS_RULE);
+				  VNIC_CFG_REQ_ENABLES_RSS_RULE |
+				  VNIC_CFG_REQ_ENABLES_MRU);
 	req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx);
 	req.cos_rule = cpu_to_le16(0xffff);
 	if (vnic->flags & BNXT_VNIC_RSS_FLAG)
-- 
1.8.3.1
