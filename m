From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] skge: Unmask interrupts in case of spurious interrupts
Date: Sun, 30 Nov 2014 12:51:31 +0100
Message-ID: <1417348291-1302-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: mlindner@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of a spurious interrupt dont forget to reenable the interrupts that
have been masked by reading the interrupt source register.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/marvell/skge.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 264eab7..7173836 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3433,10 +3433,9 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 
 	if (status & IS_HW_ERR)
 		skge_error_irq(hw);
-
+out:
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
-out:
 	spin_unlock(&hw->hw_lock);
 
 	return IRQ_RETVAL(handled);
-- 
1.9.1
