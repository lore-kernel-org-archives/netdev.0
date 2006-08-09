From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: phy power problems on 88e805X chips
Date: Wed, 9 Aug 2006 14:14:50 -0700
Message-ID: <20060809141450.2e104dfe@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4589 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751380AbWHIVO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 17:14:59 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the 88E805X chipsets (used in laptops), the PHY was not getting powered
out of shutdown properly. The variable reg1 was getting reused incorrectly.
This is probably the cause of the bug.
	http://bugzilla.kernel.org/show_bug.cgi?id=6471

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netdev-2.6.orig/drivers/net/sky2.c	2006-08-09 14:13:36.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-08-09 14:14:07.000000000 -0700
@@ -233,6 +233,8 @@
 			if (hw->ports > 1)
 				reg1 |= PCI_Y2_PHY2_COMA;
 		}
+		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+		udelay(100);
 
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
 			sky2_pci_write32(hw, PCI_DEV_REG3, 0);
@@ -242,9 +244,6 @@
 			sky2_pci_write32(hw, PCI_DEV_REG5, 0);
 		}
 
-		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-		udelay(100);
-
 		break;
 
 	case PCI_D3hot:
