From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: no need to reset pause bits on shutdown
Date: Thu, 15 Feb 2007 16:40:31 -0800
Message-ID: <20070216004141.831209000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40586 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422936AbXBPAn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:28 -0500
Content-Disposition: inline; filename=sky2-no-asym-down.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resetting the pause bits on shutdown is not necessary.
The code was inherited from the vendor driver, and it is currently #ifdef'd
out there as well.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-13 15:08:31.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-13 15:13:03.000000000 -0800
@@ -1742,13 +1742,6 @@
 	reg &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
-	if (sky2->flow_status == FC_RX) {
-		/* restore Asymmetric Pause bit */
-		gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
-			     gm_phy_read(hw, port, PHY_MARV_AUNE_ADV)
-			     | PHY_M_AN_ASP);
-	}
-
 	netif_carrier_off(sky2->netdev);
 	netif_stop_queue(sky2->netdev);
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

