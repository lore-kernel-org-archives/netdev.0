From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: revert shutdown changes
Date: Thu, 16 Jul 2009 16:20:57 -0700
Message-ID: <20090716162057.20cd3ef1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39555 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933569AbZGPXVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 19:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit changes to shutdown path broke startup on some systems.

revert commit c0bad0f2e4366d5bbfe0c4a7a80bca8f4b05272b

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

--- a/drivers/net/sky2.c	2009-07-07 18:06:44.485898870 -0700
+++ b/drivers/net/sky2.c	2009-07-07 18:14:10.587041228 -0700
@@ -1151,14 +1151,7 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
-
-	/* Reset the RAM Buffer receive queue */
-	sky2_write8(hw, RB_ADDR(rxq, RB_CTRL), RB_RST_SET);
-
-	/* Reset Rx MAC FIFO */
-	sky2_write8(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), GMF_RST_SET);
-
-	sky2_read8(hw, B0_CTST);
+	mmiowb();
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */
