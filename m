From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 10/19] bnx2: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:44:43 -0500
Message-ID: <1309196683-16046-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47993 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab1F0Ros (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:44:48 -0400
Received: by pvg12 with SMTP id 12so2992217pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:44:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
better way of determining if the device is PCIE or not (as it uses the
same saved PCIE capability offset).

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/bnx2.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 74580bb..7915d14 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7911,9 +7911,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->chip_id = REG_RD(bp, BNX2_MISC_ID);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		if (pci_find_capability(pdev, PCI_CAP_ID_EXP) == 0) {
-			dev_err(&pdev->dev,
-				"Cannot find PCIE capability, aborting\n");
+		if (!pci_is_pcie(pdev)) {
+			dev_err(&pdev->dev, "Not PCIE, aborting\n");
 			rc = -EIO;
 			goto err_out_unmap;
 		}
-- 
1.7.5.4

