From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] cassini: init before use in cas_interruptN.
Date: Thu, 25 Aug 2011 17:02:49 +0200
Message-ID: <20110825150249.GA21897@electric-eye.fr.zoreil.com>
References: <201108251558.45290.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38077 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912Ab1HYPUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 11:20:49 -0400
Content-Disposition: inline
In-Reply-To: <201108251558.45290.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Spotted-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---

 David, any opinion regarding the removal of the USE_NAPI #ifdef
 in this driver ?

 drivers/net/cassini.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 646c86b..fdb7a17 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2452,14 +2452,13 @@ static irqreturn_t cas_interruptN(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct cas *cp = netdev_priv(dev);
 	unsigned long flags;
-	int ring;
+	int ring = (irq == cp->pci_irq_INTC) ? 2 : 3;
 	u32 status = readl(cp->regs + REG_PLUS_INTRN_STATUS(ring));
 
 	/* check for shared irq */
 	if (status == 0)
 		return IRQ_NONE;
 
-	ring = (irq == cp->pci_irq_INTC) ? 2 : 3;
 	spin_lock_irqsave(&cp->lock, flags);
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
-- 
1.7.4.4
