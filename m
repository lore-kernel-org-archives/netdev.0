From: shemminger@osdl.org
Subject: [PATCH 8/9] sky2: pci post bug
Date: Mon, 28 Aug 2006 10:00:52 -0700
Message-ID: <20060828170220.807901174@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42626 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751259AbWH1SQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:38 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-pci-post.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that PCI write occurs before the delay.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-08-28 10:00:17.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-28 10:00:20.000000000 -0700
@@ -531,6 +531,7 @@
 		reg1 |= phy_power[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	sky2_pci_read32(hw, PCI_DEV_REG1);
 	udelay(100);
 }
 
@@ -766,9 +767,10 @@
 /* Update chip's next pointer */
 static inline void sky2_put_idx(struct sky2_hw *hw, unsigned q, u16 idx)
 {
+	q = Y2_QADDR(q, PREF_UNIT_PUT_IDX);
 	wmb();
-	sky2_write16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX), idx);
-	mmiowb();
+	sky2_write16(hw, q, idx);
+	sky2_read16(hw, q);
 }
 
 

--
Stephen Hemminger <shemminger@osdl.org>

