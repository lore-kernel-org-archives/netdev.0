From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] sky2: turn on clocks when doing resume
Date: Sat, 07 Apr 2007 16:42:08 -0700
Message-ID: <20070407234236.129627887@linux-foundation.org>
References: <20070407234205.348565140@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36305 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965996AbXDGXo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:44:26 -0400
Content-Disposition: inline; filename=sky2-ec-clocks-resume.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of these chips are disabled until clock is enabled.
This fixes:
     http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=404107

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- linux-2.6.20.y.orig/drivers/net/sky2.c	2007-04-07 15:54:42.000000000 -0700
+++ linux-2.6.20.y/drivers/net/sky2.c	2007-04-07 15:56:37.000000000 -0700
@@ -2437,6 +2437,10 @@
 		return -EOPNOTSUPP;
 	}
 
+	/* Make sure and enable all clocks */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
 	/* This rev is really old, and requires untested workarounds */
@@ -3610,6 +3614,9 @@
 
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
+
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 	sky2_set_power_state(hw, PCI_D0);
 
 	err = sky2_reset(hw);

--

