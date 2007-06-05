From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] sky2: enable clocks before probe
Date: Mon, 04 Jun 2007 17:23:24 -0700
Message-ID: <20070605002738.861630497@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46592 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759211AbXFEAnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:21 -0400
Content-Disposition: inline; filename=sky2-ex-power.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Catch-22: On Yukon EX (88E8071) need to have internal clocks enabled
before reading chip id. It is harmless on other chips.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- a/drivers/net/sky2.c	2007-06-04 08:46:43.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:45.000000000 -0700
@@ -2519,6 +2519,9 @@ static int __devinit sky2_init(struct sk
 {
 	u8 t8;
 
+	/* Enable all clocks */
+	sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
@@ -2532,10 +2535,6 @@ static int __devinit sky2_init(struct sk
 		dev_warn(&hw->pdev->dev, "this driver not yet tested on this chip type\n"
 			 "Please report success or failure to <netdev@vger.kernel.org>\n");
 
-	/* Make sure and enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
-
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
 	/* This rev is really old, and requires untested workarounds */

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

