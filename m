From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] sky2: more receive shutdown
Date: Wed, 17 Jun 2009 10:30:33 -0700
Message-ID: <20090617173139.582840975@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45317 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758263AbZFQReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:04 -0400
Content-Disposition: inline; filename=sky2-shut1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset more parts of the receive path when device is take offline.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:50.630937431 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:52.005685817 -0700
@@ -1151,7 +1151,14 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
-	mmiowb();
+
+	/* Reset the RAM Buffer receive queue */
+	sky2_write8(hw, RB_ADDR(rxq, RB_CTRL), RB_RST_SET);
+
+	/* Reset Rx MAC FIFO */
+	sky2_write8(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), GMF_RST_SET);
+
+	sky2_read8(hw, B0_CTST);
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */

-- 

