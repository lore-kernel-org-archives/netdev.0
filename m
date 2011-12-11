From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH/resend] m68k/net: Remove obsolete IRQ_FLG_* users
Date: Sun, 11 Dec 2011 10:04:05 +0100
Message-ID: <1323594245-25269-1-git-send-email-geert@linux-m68k.org>
Cc: linux-m68k@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:43985 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab1LKJEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 04:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The m68k core irq code stopped honoring these flags during the irq
restructuring in 2006.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
Please take or ack, so I can remove the definition for IRQ_FLG_FAST in
the m68k code

 drivers/net/ethernet/natsemi/macsonic.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index a2eacbf..5987d17 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -142,8 +142,7 @@ static int macsonic_open(struct net_device* dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQ_FLG_FAST,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 				dev->name, dev->irq);
@@ -154,8 +153,8 @@ static int macsonic_open(struct net_device* dev)
 	 * rupt as well, which must prevent re-entrance of the sonic handler.
 	 */
 	if (dev->irq == IRQ_AUTO_3) {
-		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt,
-					IRQ_FLG_FAST, "sonic", dev);
+		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt, 0,
+				     "sonic", dev);
 		if (retval) {
 			printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 					dev->name, IRQ_NUBUS_9);
-- 
1.7.0.4
