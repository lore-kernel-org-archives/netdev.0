From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: sky2: Correct mistakenly switched read/write sequence
Date: Sat, 1 Dec 2012 13:42:39 +0100
Message-ID: <20121201124239.GB3914@neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: shemminger@vyatta.com, mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:40755 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751423Ab2LAMmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 07:42:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sky2_all_down() the order of the read()/write() access to B0_IMSK seems to
be mistakenly switched. The original intention was obviously to avoid PCI write
posting.
This patch fixes the order.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/marvell/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 78946fe..b20d2fd 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3481,8 +3481,8 @@ static void sky2_all_down(struct sky2_hw *hw)
 	int i;
 
 	if (hw->flags & SKY2_HW_IRQ_SETUP) {
-		sky2_read32(hw, B0_IMSK);
 		sky2_write32(hw, B0_IMSK, 0);
+		sky2_read32(hw, B0_IMSK);
 
 		synchronize_irq(hw->pdev->irq);
 		napi_disable(&hw->napi);
-- 
1.7.9.5
