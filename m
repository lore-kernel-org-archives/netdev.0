From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 1/4] bnxt_en: Fix bitmap declaration to work on 32-bit arches.
Date: Tue, 8 Dec 2015 19:18:39 -0500
Message-ID: <1449620322-12961-2-git-send-email-mchan@broadcom.com>
References: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:38411 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbLIASo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 19:18:44 -0500
In-Reply-To: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The declaration of the bitmap vf_req_snif_bmap using fixed array of
unsigned long will only work on 64-bit archs.  Use DECLARE_BITMAP instead
which will work on all archs.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index bdf094f..51671e3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2693,17 +2693,16 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 	req.ver_upd = DRV_VER_UPD;
 
 	if (BNXT_PF(bp)) {
-		unsigned long vf_req_snif_bmap[4];
+		DECLARE_BITMAP(vf_req_snif_bmap, 256);
 		u32 *data = (u32 *)vf_req_snif_bmap;
 
-		memset(vf_req_snif_bmap, 0, 32);
+		memset(vf_req_snif_bmap, 0, sizeof(vf_req_snif_bmap));
 		for (i = 0; i < ARRAY_SIZE(bnxt_vf_req_snif); i++)
 			__set_bit(bnxt_vf_req_snif[i], vf_req_snif_bmap);
 
-		for (i = 0; i < 8; i++) {
-			req.vf_req_fwd[i] = cpu_to_le32(*data);
-			data++;
-		}
+		for (i = 0; i < 8; i++)
+			req.vf_req_fwd[i] = cpu_to_le32(data[i]);
+
 		req.enables |=
 			cpu_to_le32(FUNC_DRV_RGTR_REQ_ENABLES_VF_REQ_FWD);
 	}
-- 
1.8.3.1
