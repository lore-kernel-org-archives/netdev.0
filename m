From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH 2.6.33-rc5] drivers/net: ks8851_mll ethernet network driver
Date: Wed, 27 Jan 2010 08:03:16 -0800
Message-ID: <C43529A246480145B0A6D0234BDB0F0D02129C@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o148.mxlogic.net ([208.65.145.71]:54260 "EHLO
	p01c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab0A0QR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 11:17:27 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller,

I fix a bug in ks8851_mll driver, which has existed since 2.6.32-rc6.

>From : David J. Choi <david.choi@micrel.com>

Fix a bug that the data pointers in the interrupt handler are set wrong, which is related with the 5th parameter of request_irq().   

Signed-off-by : David J. Choi <david.choi@micrel.com>
---
--- linux-2.6.33-rc5/drivers/net/ks8851_mll.c.orig	2010-01-26 17:36:51.000000000 -0800
+++ linux-2.6.33-rc5/drivers/net/ks8851_mll.c	2010-01-26 17:34:34.000000000 -0800
@@ -854,8 +854,8 @@ static void ks_update_link_status(struct
 
 static irqreturn_t ks_irq(int irq, void *pw)
 {
-	struct ks_net *ks = pw;
-	struct net_device *netdev = ks->netdev;
+	struct net_device *netdev = pw;
+	struct ks_net *ks = netdev_priv(netdev);
 	u16 status;
 
 	/*this should be the first in IRQ handler */
---
