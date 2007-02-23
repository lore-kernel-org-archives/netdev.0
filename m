From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: fix for use on big endian
Date: Fri, 23 Feb 2007 15:10:45 -0800
Message-ID: <20070223231353.405627000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40973 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933269AbXBWXRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:31 -0500
Content-Disposition: inline; filename=sky2-big-endian.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben added this for 2.6.18, it allows sky2 to run on big endian.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:45:34.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:45:36.000000000 -0800
@@ -3254,12 +3254,13 @@
 	spin_lock_init(&hw->hw_lock);
 
 #ifdef __BIG_ENDIAN
-	/* byte swap descriptors in hardware */
+	/* The sk98lin vendor driver uses hardware byte swapping but
+	 * this driver uses software swapping.
+	 */
 	{
 		u32 reg;
-
 		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
-		reg |= PCI_REV_DESC;
+		reg &= ~PCI_REV_DESC;
 		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
 	}
 #endif

--
Stephen Hemminger <shemminger@linux-foundation.org>

