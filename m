From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] sky2: enable PCI config writes
Date: Mon, 05 Nov 2007 15:52:08 -0800
Message-ID: <20071105235339.973177053@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36639 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045AbXKEX4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:56:44 -0500
Content-Disposition: inline; filename=sky2-enable-pci-config.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some boards, PCI configuration space access is turned off by default.
The 2.6.24 driver doesn't turn it on, and should have.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-11-05 10:01:10.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:01:44.000000000 -0800
@@ -2791,6 +2791,9 @@ static void sky2_reset(struct sky2_hw *h
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
+	/* allow writes to PCI config */
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+
 	/* clear PCI errors, if any */
 	pci_read_config_word(pdev, PCI_STATUS, &status);
 	status |= PCI_STATUS_ERROR_BITS;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

