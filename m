From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] sky2: fix missing register reset on error path in
 sky2_test_msi()
Date: Fri, 30 Mar 2012 19:36:16 +0200
Message-ID: <20120330173616.GC2703@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:58948 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752904Ab2C3RgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 13:36:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sky2_test_msi() the temporarily set SW IRQ in B0 register is not reset in case
that request_irq() fails.
With this patch we only set the interrupt mask if request_irq() was successful.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 This applies against 3.3

 drivers/net/ethernet/marvell/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 760c2b1..0e23ce4 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4795,14 +4795,14 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 
 	init_waitqueue_head(&hw->msi_wait);
 
-	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
-
 	err = request_irq(pdev->irq, sky2_test_intr, 0, DRV_NAME, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
 		return err;
 	}
 
+	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
+
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
 	sky2_read8(hw, B0_CTST);
 
-- 
1.5.6.5
