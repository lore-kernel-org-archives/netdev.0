From: Micah Gruber <micah.gruber@gmail.com>
Subject: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in mace_interrupt()
 in drivers/net/pcmcia/nmclan_cs.c
Date: Tue, 24 Jul 2007 10:44:56 +0800
Message-ID: <46A567A8.6050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:50486 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbXGXCkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 22:40:19 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1273471nze
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 19:40:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a potential null dereference bug where we dereference 
DEV before a null check. This patch simply moves the dereferencing after 
the null check.

Signed-off-by: Micah Gruber <micah.gruber@gmail.com>

---

--- a/drivers/net/pcmcia/nmclan_cs.c    
+++ b/drivers/net/pcmcia/nmclan_cs.c    
@@ -996,7 +996,7 @@
 {
   struct net_device *dev = (struct net_device *) dev_id;
   mace_private *lp = netdev_priv(dev);
-  kio_addr_t ioaddr = dev->base_addr;
+  kio_addr_t ioaddr;
   int status;
   int IntrCnt = MACE_MAX_IR_ITERATIONS;

@@ -1006,6 +1006,8 @@
     return IRQ_NONE;
   }

+  ioaddr = dev->base_addr;
+
   if (lp->tx_irq_disabled) {
     printk(
       (lp->tx_irq_disabled?

