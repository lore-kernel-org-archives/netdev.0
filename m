From: John Linn <john.linn@xilinx.com>
Subject: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0 is used
Date: Wed, 26 May 2010 11:29:18 -0600
Message-ID: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john.williams@petalogix.com, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>,
	Brian Hill <brian.hill@xilinx.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-va3.bigfish.com ([216.32.180.114]:59598 "EHLO
	mail181-va3-R.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757268Ab0EZRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 13:47:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is not checking the interrupt for DMA correctly so that an
interrupt number of 0 will cause a false error.

Signed-off-by: Brian Hill <brian.hill@xilinx.com>
Signed-off-by: John Linn <john.linn@xilinx.com>
---
 drivers/net/ll_temac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index fa7620e..0615737 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -950,7 +950,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 
 	lp->rx_irq = irq_of_parse_and_map(np, 0);
 	lp->tx_irq = irq_of_parse_and_map(np, 1);
-	if (!lp->rx_irq || !lp->tx_irq) {
+	if ((lp->rx_irq == NO_IRQ) || (lp->tx_irq == NO_IRQ)) {
 		dev_err(&op->dev, "could not determine irqs\n");
 		rc = -ENOMEM;
 		goto nodev;
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


