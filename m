From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH RFT] b44: Truncate PHY address
Date: Sat, 22 Mar 2008 01:24:20 +0100
Message-ID: <200803220124.21355.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: agb@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:43842 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbYCVA2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 20:28:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ROMs on embedded devices store incorrect values for
the PHY address of the ethernet device.
It looks like the number is sign-extended.
Truncate the value by applying the PHY-address mask to it.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

This patch is untested and needs some testing before it
can go upstream, but I think the chance of introducing bugs
with this is almost zero, as the PHY address register really is
only 5 bits long. So this will do The Right Thing (tm) in any case.
Please report result of the testing back to me. I will also run some
tests later and then submit the patch for inclusion.


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
