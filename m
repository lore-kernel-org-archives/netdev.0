From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 2/2] net: ethernet: xilinx: Do not use NO_IRQ in axienet
Date: Thu, 10 Jan 2013 17:58:43 +0100
Message-ID: <1357837123-18996-2-git-send-email-michal.simek@xilinx.com>
References: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:64441 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052Ab3AJQ6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:58:50 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so414809eei.31
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:58:49 -0800 (PST)
In-Reply-To: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver is used on Microblaze and will be used
on Arm Zynq.
Microblaze doesn't define NO_IRQ and no IRQ is 0.
Arm still uses NO_IRQ as -1 and there is no option
to connect IRQ to irq 0.

That's why <= 0 is only one option how to find out
undefined IRQ.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index d9f69b8..6f47100 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1590,7 +1590,7 @@ static int axienet_of_probe(struct platform_device *op)
 	lp->rx_irq = irq_of_parse_and_map(np, 1);
 	lp->tx_irq = irq_of_parse_and_map(np, 0);
 	of_node_put(np);
-	if ((lp->rx_irq == NO_IRQ) || (lp->tx_irq == NO_IRQ)) {
+	if ((lp->rx_irq <= 0) || (lp->tx_irq <= 0)) {
 		dev_err(&op->dev, "could not determine irqs\n");
 		ret = -ENOMEM;
 		goto err_iounmap_2;
-- 
1.7.0.4
