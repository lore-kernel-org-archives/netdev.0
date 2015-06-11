From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 13/19] bna: correct comparisons/assignments to bool
Date: Thu, 11 Jun 2015 15:52:25 +0200
Message-ID: <1434030751-28835-14-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754674AbbFKNwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:22 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 29e0428..52fc439 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1373,7 +1373,7 @@ static enum bfi_ioc_img_ver_cmp
 bfa_ioc_fw_ver_patch_cmp(struct bfi_ioc_image_hdr *base_fwhdr,
 			 struct bfi_ioc_image_hdr *fwhdr_to_cmp)
 {
-	if (bfa_ioc_fw_ver_compatible(base_fwhdr, fwhdr_to_cmp) == false)
+	if (!bfa_ioc_fw_ver_compatible(base_fwhdr, fwhdr_to_cmp))
 		return BFI_IOC_IMG_VER_INCOMP;
 
 	if (fwhdr_to_cmp->fwver.patch > base_fwhdr->fwver.patch)
@@ -1384,7 +1384,7 @@ bfa_ioc_fw_ver_patch_cmp(struct bfi_ioc_image_hdr *base_fwhdr,
 	/* GA takes priority over internal builds of the same patch stream.
 	 * At this point major minor maint and patch numbers are same.
 	 */
-	if (fwhdr_is_ga(base_fwhdr) == true)
+	if (fwhdr_is_ga(base_fwhdr))
 		if (fwhdr_is_ga(fwhdr_to_cmp))
 			return BFI_IOC_IMG_VER_SAME;
 		else
@@ -2209,7 +2209,7 @@ bfa_nw_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
 	/*
 	 *  Hold semaphore to serialize pll init and fwtrc.
 	*/
-	if (bfa_nw_ioc_sem_get(ioc->ioc_regs.ioc_init_sem_reg) == 0)
+	if (!bfa_nw_ioc_sem_get(ioc->ioc_regs.ioc_init_sem_reg))
 		return 1;
 
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
@@ -2264,7 +2264,7 @@ bfa_nw_ioc_debug_save_ftrc(struct bfa_ioc *ioc)
 	int tlen;
 
 	if (ioc->dbg_fwsave_once) {
-		ioc->dbg_fwsave_once = 0;
+		ioc->dbg_fwsave_once = false;
 		if (ioc->dbg_fwsave_len) {
 			tlen = ioc->dbg_fwsave_len;
 			bfa_nw_ioc_debug_fwtrc(ioc, ioc->dbg_fwsave, &tlen);
-- 
2.3.6
