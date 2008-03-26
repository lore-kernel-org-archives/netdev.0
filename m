From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH stable] b44: Truncate PHY address
Date: Wed, 26 Mar 2008 15:00:08 +0100
Message-ID: <200803261500.08699.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, agb@openwrt.org,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:56919 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYCZOEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 10:04:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ROMs on embedded devices store incorrect values for
the PHY address of the ethernet device.
It looks like the number is sign-extended.
Truncate the value by applying the PHY-address mask to it.
The patch was tested on a bcm47xx embedded system (where the bug
triggers) and a bcm4400 PCI card.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

This patch is applied to the netdev tree.
Commit is 5ea79631c0c47d28831a0635e8af9da539d449cd


Index: linux-2.6.24.3/drivers/net/b44.c
===================================================================
--- linux-2.6.24.3.orig/drivers/net/b44.c	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24.3/drivers/net/b44.c	2008-03-26 14:54:13.000000000 +0100
@@ -2066,6 +2066,11 @@ static int __devinit b44_get_invariants(
 		addr = sdev->bus->sprom.r1.et0mac;
 		bp->phy_addr = sdev->bus->sprom.r1.et0phyaddr;
 	}
+	/* Some ROMs have buggy PHY addresses with the high
+	 * bits set (sign extension?). Truncate them to a
+	 * valid PHY address. */
+	bp->phy_addr &= 0x1F;
+
 	memcpy(bp->dev->dev_addr, addr, 6);
 
 	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){


-- 
Greetings Michael.
