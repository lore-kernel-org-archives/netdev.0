From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] sky2: pci posting issues
Date: Wed, 16 Nov 2011 15:42:56 -0800
Message-ID: <20111116234344.621810647@vyatta.com>
References: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48424 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab1KPXwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:52:33 -0500
Content-Disposition: inline; filename=sky2-pci-posting-wol.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of the reset and setup paths have possible PCI posting issues.
When setting registers, a read is necessary to force the writes to complete.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This needs to be applied to net-next and -net

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:32.898508932 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:38.282631277 -0800
@@ -869,6 +869,7 @@ static void sky2_wol_init(struct sky2_po
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
+	sky2_read32(hw, B0_CTST);
 }
 
 static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
@@ -2045,6 +2046,8 @@ static void sky2_tx_reset(struct sky2_hw
 
 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
+
+	sky2_read32(hw, B0_CTST);
 }
 
 static void sky2_hw_down(struct sky2_port *sky2)
