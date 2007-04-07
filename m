From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] sky2: turn on clocks when doing resume
Date: Sat, 07 Apr 2007 16:02:27 -0700
Message-ID: <20070407230325.823715638@linux-foundation.org>
References: <20070407230224.486666854@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36294 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbXDGXnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:43:12 -0400
Content-Disposition: inline; filename=sky2-ec-clocks-resume.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of these chips are disabled until clock is enabled.
This fixes:
     http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=404107

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- netdev-2.6.orig/drivers/net/sky2.c	2007-04-07 15:11:48.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2007-04-07 15:12:31.000000000 -0700
@@ -3770,6 +3770,11 @@
 		goto out;
 
 	pci_enable_wake(pdev, PCI_D0, 0);
+
+	/* Re-enable all clocks */
+	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	sky2_reset(hw);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);

--

