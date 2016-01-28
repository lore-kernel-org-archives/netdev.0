From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Ring free response from close path should use completion ring
Date: Thu, 28 Jan 2016 03:11:20 -0500
Message-ID: <1453968682-10014-2-git-send-email-mchan@broadcom.com>
References: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:18360 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934829AbcA1IL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 03:11:26 -0500
In-Reply-To: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>

Use completion ring for ring free response from firmware.  The response
will be the last entry in the ring and we can free the ring after getting
the response.  This will guarantee no spurious DMA to freed memory.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index df835f5..17dcacd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3406,7 +3406,7 @@ static int hwrm_ring_free_send_msg(struct bnxt *bp,
 	struct hwrm_ring_free_output *resp = bp->hwrm_cmd_resp_addr;
 	u16 error_code;
 
-	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_RING_FREE, -1, -1);
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_RING_FREE, cmpl_ring_id, -1);
 	req.ring_type = ring_type;
 	req.ring_id = cpu_to_le16(ring->fw_ring_id);
 
-- 
1.8.3.1
