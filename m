From: Dave Jones <davej@redhat.com>
Subject: Remove useless check for null dev from uli526x_interrupt()
Date: Sun, 11 Jun 2006 20:27:32 -0400
Message-ID: <20060612002732.GA4477@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:25040 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751068AbWFLA1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 20:27:33 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k5C0RWYN013731
	for <netdev@vger.kernel.org>; Sun, 11 Jun 2006 20:27:32 -0400
Received: from devserv.devel.redhat.com (devserv.devel.redhat.com [172.16.58.1])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k5C0RW4x004247
	for <netdev@vger.kernel.org>; Sun, 11 Jun 2006 20:27:32 -0400
Received: from devserv.devel.redhat.com (localhost.localdomain [127.0.0.1])
	by devserv.devel.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k5C0RWb8004497
	for <netdev@vger.kernel.org>; Sun, 11 Jun 2006 20:27:32 -0400
Received: (from davej@localhost)
	by devserv.devel.redhat.com (8.12.11.20060308/8.12.11/Submit) id k5C0RW1e004495
	for netdev@vger.kernel.org; Sun, 11 Jun 2006 20:27:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we're already dereferencing dev a few lines above, if this
check could ever trigger, we'd have already oopsed.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6/drivers/net/tulip/uli526x.c~	2006-06-11 20:24:41.000000000 -0400
+++ linux-2.6/drivers/net/tulip/uli526x.c	2006-06-11 20:25:14.000000000 -0400
@@ -666,11 +666,6 @@ static irqreturn_t uli526x_interrupt(int
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
-	if (!dev) {
-		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
-		return IRQ_NONE;
-	}
-
 	spin_lock_irqsave(&db->lock, flags);
 	outl(0, ioaddr + DCR7);
 
