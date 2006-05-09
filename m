From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: ifdown kills irq mask
Date: Tue, 9 May 2006 14:46:54 -0700
Message-ID: <20060509144654.6de406f2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23690 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751169AbWEIVrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 17:47:02 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bringing down a port also masks off the status and other IRQ's
needed for device to function due to missing paren's.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -128,6 +128,7 @@ MODULE_DEVICE_TABLE(pci, sky2_id_table);
 /* Avoid conditionals by using array */
 static const unsigned txqaddr[] = { Q_XA1, Q_XA2 };
 static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
+static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
 /* This driver supports yukon2 chipset only */
 static const char *yukon2_name[] = {
@@ -1084,7 +1085,7 @@ static int sky2_up(struct net_device *de
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
-	imask |= (port == 0) ? Y2_IS_PORT_1 : Y2_IS_PORT_2;
+	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
 	return 0;
@@ -1435,7 +1436,7 @@ static int sky2_down(struct net_device *
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~(sky2->port == 0) ? Y2_IS_PORT_1 : Y2_IS_PORT_2;
+	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
 	/* turn off LED's */
