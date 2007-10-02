From: akpm@linux-foundation.org
Subject: [patch 06/13] Fix a potential NULL pointer dereference in uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Tue, 02 Oct 2007 14:11:38 -0700
Message-ID: <200710022111.l92LBcIs022492@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	micah.gruber@gmail.com, grundler@parisc-linux.org, kyle@mcmartin.ca
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37409 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754955AbXJBVMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:12:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Micah Gruber <micah.gruber@gmail.com>

This patch fixes an apparent potential null dereference bug where we
dereference dev before a null check.  This patch simply remvoes the
can't-happen test for a null pointer.

Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
Acked-by: Jeff Garzik <jeff@garzik.org>
Acked-by: Kyle McMartin <kyle@mcmartin.ca>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/uli526x.c |    5 -----
 1 file changed, 5 deletions(-)

diff -puN drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt drivers/net/tulip/uli526x.c
--- a/drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt
+++ a/drivers/net/tulip/uli526x.c
@@ -664,11 +664,6 @@ static irqreturn_t uli526x_interrupt(int
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
-	if (!dev) {
-		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
-		return IRQ_NONE;
-	}
-
 	spin_lock_irqsave(&db->lock, flags);
 	outl(0, ioaddr + DCR7);
 
_
