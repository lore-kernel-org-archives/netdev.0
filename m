From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: fix compilation without
 CONFIG_BNX2X_SRIOV
Date: Wed, 27 Mar 2013 20:56:10 +0200
Message-ID: <1364410570-18129-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2100 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966Ab3C0S4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 14:56:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move mutex initialization by allocation of the mailbox it protects.

introduced in commit 1d6f3cd89 'bnx2x: Prevent VF race'

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 10af03e..fdfe33b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12522,7 +12522,6 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	 */
 	if (IS_VF(bp)) {
 		bp->doorbells = bnx2x_vf_doorbells(bp);
-		mutex_init(&bp->vf2pf_mutex);
 		rc = bnx2x_vf_pci_alloc(bp);
 		if (rc)
 			goto init_one_exit;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index db63d86..2ce7c74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3425,6 +3425,8 @@ void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 
 int bnx2x_vf_pci_alloc(struct bnx2x *bp)
 {
+	mutex_init(&bp->vf2pf_mutex);
+
 	/* allocate vf2pf mailbox for vf to pf channel */
 	BNX2X_PCI_ALLOC(bp->vf2pf_mbox, &bp->vf2pf_mbox_mapping,
 			sizeof(struct bnx2x_vf_mbx_msg));
-- 
1.7.7.2
