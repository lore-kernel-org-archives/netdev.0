From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 5/6] bnx2x: handle CHIP_REVISION during init_one
Date: Mon, 23 Jan 2012 12:31:55 -0500
Message-ID: <1327339916-19138-6-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1725 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221Ab2AWKhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:48 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

The macro `CHIP_IS_E1x' requires `bp' to be initialized.
As `bp' is not yet initialized during this phase of `bnx2x_init_dev',
it accessed uninitialized fields in the struct.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ffeaaa9..f4c2fe5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10536,6 +10536,9 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 {
 	struct bnx2x *bp;
 	int rc;
+	bool chip_is_e1x = (board_type == BCM57710 ||
+			    board_type == BCM57711 ||
+			    board_type == BCM57711E);
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp = netdev_priv(dev);
@@ -10624,7 +10627,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0, 0);
 
-	if (CHIP_IS_E1x(bp)) {
+	if (chip_is_e1x) {
 		REG_WR(bp, PXP2_REG_PGL_ADDR_88_F1, 0);
 		REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F1, 0);
 		REG_WR(bp, PXP2_REG_PGL_ADDR_90_F1, 0);
@@ -10635,9 +10638,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	 * Enable internal target-read (in case we are probed after PF FLR).
 	 * Must be done prior to any BAR read access. Only for 57712 and up
 	 */
-	if (board_type != BCM57710 &&
-	    board_type != BCM57711 &&
-	    board_type != BCM57711E)
+	if (!chip_is_e1x)
 		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
 
 	/* Reset the load counter */
-- 
1.7.1
