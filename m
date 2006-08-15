From: akpm@osdl.org
Subject: [patch 29/41] smc911x: Re-release spinlock on spurious interrupt
Date: Mon, 14 Aug 2006 23:00:17 -0700
Message-ID: <200608150600.k7F60Htq012692@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34194 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965134AbWHOGA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:27 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Korsgaard <jacmet@sunsite.dk>

The smc911x driver forgets to release the spinlock on spurious interrupts. 
This little patch fixes it.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/smc911x.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/smc911x.c~smc911x-re-release-spinlock-on-spurious-interrupt drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~smc911x-re-release-spinlock-on-spurious-interrupt
+++ a/drivers/net/smc911x.c
@@ -1090,6 +1090,7 @@ static irqreturn_t smc911x_interrupt(int
 	/* Spurious interrupt check */
 	if ((SMC_GET_IRQ_CFG() & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
 		(INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) {
+		spin_unlock_irqrestore(&lp->lock, flags);
 		return IRQ_NONE;
 	}
 
_
