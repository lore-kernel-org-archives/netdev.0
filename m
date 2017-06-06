From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: fix pf2vf bulletin DMA mapping leak
Date: Tue,  6 Jun 2017 16:30:31 +0200
Message-ID: <20170606143031.863-1-mschmidt@redhat.com>
Cc: Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54496 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751418AbdFFOax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 10:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When freeing VF's DMA mappings, an already NULLed pointer was checked
again due to an apparent copy&paste error. Consequently, the pf2vf
bulletin DMA mapping was not freed.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index bdfd53b46b..870ea001a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3042,7 +3042,7 @@ void bnx2x_vf_pci_dealloc(struct bnx2x *bp)
 {
 	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->vf2pf_mbox_mapping,
 		       sizeof(struct bnx2x_vf_mbx_msg));
-	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->pf2vf_bulletin_mapping,
+	BNX2X_PCI_FREE(bp->pf2vf_bulletin, bp->pf2vf_bulletin_mapping,
 		       sizeof(union pf_vf_bulletin));
 }
 
-- 
2.13.0
