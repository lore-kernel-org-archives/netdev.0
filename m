From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] skge: increase TX threshold for Jumbo
Date: Mon, 26 Nov 2007 11:54:52 -0800
Message-ID: <20071126195557.762317974@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47448 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753580AbXKZUEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 15:04:13 -0500
Content-Disposition: inline; filename=skge-tx-thr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to increase TX threshold when doing Jumbo frames on dual port board
to avoid underruns. (Code from sk98lin).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/skge.c	2007-11-21 14:05:59.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 14:06:15.000000000 -0800
@@ -1633,15 +1633,14 @@ static void genesis_mac_init(struct skge
 	}
 	xm_write16(hw, port, XM_RX_CMD, r);
 
-
 	/* We want short frames padded to 60 bytes. */
 	xm_write16(hw, port, XM_TX_CMD, XM_TX_AUTO_PAD);
 
-	/*
-	 * Bump up the transmit threshold. This helps hold off transmit
-	 * underruns when we're blasting traffic from both ports at once.
-	 */
-	xm_write16(hw, port, XM_TX_THR, 512);
+	/* Increase threshold for jumbo frames on dual port */
+	if (hw->ports > 1 && jumbo)
+		xm_write16(hw, port, XM_TX_THR, 1020);
+	else
+		xm_write16(hw, port, XM_TX_THR, 512);
 
 	/*
 	 * Enable the reception of all error frames. This is is

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

