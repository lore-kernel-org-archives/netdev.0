From: Micah Gruber <micah.gruber@gmail.com>
Subject: [PATCH] Fix a potential NULL pointer dereference in uli526x_interrupt()
 in drivers/net/tulip/uli526x.c
Date: Tue, 04 Sep 2007 16:06:50 +0800
Message-ID: <46DD121A.2010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:40362 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbXIDIFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 04:05:43 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1736660wxd
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 01:05:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a potential null dereference bug where we dereference dev before a null check. This patch simply moves the dereferencing after the null check.

Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
---

--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -663,7 +663,7 @@
 {
 	struct net_device *dev = dev_id;
 	struct uli526x_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr;
+	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
 	if (!dev) {
@@ -671,8 +671,6 @@
 		return IRQ_NONE;
 	}
 
-	ioaddr = dev->base_addr;
-
 	spin_lock_irqsave(&db->lock, flags);
 	outl(0, ioaddr + DCR7);

