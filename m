From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] sis900: fix sis900_set_mode call parameters.
Date: Sun, 18 Nov 2012 23:41:50 +0100
Message-ID: <20121118224150.GA6755@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jan Janssen <medhefgo@web.de>,
	Daniele Venzano <venza@brownhat.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58405 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab2KRXFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 18:05:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leftover of 57d6d456cfb89264f87d24f52640ede23fdf12bd ("sis900: stop
using net_device.{base_addr, irq} and convert to __iomem.").

It is needed for suspend / resume to work.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jan Janssen <medhefgo@web.de>
Cc: Daniele Venzano <venza@brownhat.org>
---
 drivers/net/ethernet/sis/sis900.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index fb9f6b3..edf5edb 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -2479,7 +2479,7 @@ static int sis900_resume(struct pci_dev *pci_dev)
 	netif_start_queue(net_dev);
 
 	/* Workaround for EDB */
-	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
+	sis900_set_mode(sis_priv, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
 	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
-- 
1.7.11.7
