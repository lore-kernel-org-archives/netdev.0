From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 4/9] atl1: use defined functions to disable irq
Date: Fri, 13 Apr 2012 20:09:49 +0400
Message-ID: <1334333394-38404-5-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54713 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like direct writes to IMR register is not good idea,
because there are exist functions to make this work.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index a8935df..4fcdf57 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -266,7 +266,7 @@ static s32 atl1_reset_hw(struct atl1_hw *hw)
 	 * interrupts & Clear any pending interrupt events
 	 */
 	/*
-	 * iowrite32(0, hw->hw_addr + REG_IMR);
+	 * atlx_irq_disable(adapter);
 	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
 	 */
 
@@ -2512,7 +2512,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 					"pcie phy link down %x\n", status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
-				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+				atlx_irq_disable(adapter);
 				schedule_work(&adapter->reset_dev_task);
 				return IRQ_HANDLED;
 			}
@@ -2524,7 +2524,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 					"pcie DMA r/w error (status = 0x%x)\n",
 					status);
-			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+			atlx_irq_disable(adapter);
 			schedule_work(&adapter->reset_dev_task);
 			return IRQ_HANDLED;
 		}
-- 
1.7.1
