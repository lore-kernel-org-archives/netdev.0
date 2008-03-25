From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44: Truncate PHY address
Date: Tue, 25 Mar 2008 18:04:46 +0100
Message-ID: <200803251804.46422.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: agb@openwrt.org, Gary Zambrano <zambrano@broadcom.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:34475 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbYCYRGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 13:06:00 -0400
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

Jeff, this is a bugfix for 2.6.25.


Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2008-02-16 19:08:12.000000000 +0100
+++ wireless-testing/drivers/net/b44.c	2008-03-22 01:13:21.000000000 +0100
@@ -2082,6 +2082,11 @@ static int __devinit b44_get_invariants(
 		addr = sdev->bus->sprom.et0mac;
 		bp->phy_addr = sdev->bus->sprom.et0phyaddr;
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
