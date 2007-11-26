From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] skge: receive flush logic
Date: Mon, 26 Nov 2007 11:54:49 -0800
Message-ID: <20071126195557.595722308@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53065 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbXKZT7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 14:59:15 -0500
Content-Disposition: inline; filename=skge-no-rcv-flush.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Receive FIFO overrun is not catastrophic condition, so don't flush when
it happens.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-11-21 14:36:31.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 14:40:58.000000000 -0800
@@ -1801,11 +1801,6 @@ static void genesis_mac_intr(struct skge
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
 		++dev->stats.tx_fifo_errors;
 	}
-
-	if (status & XM_IS_RXF_OV) {
-		xm_write32(hw, port, XM_MODE, XM_MD_FRF);
-		++dev->stats.rx_fifo_errors;
-	}
 }
 
 static void genesis_link_up(struct skge_port *skge)
@@ -1862,9 +1857,9 @@ static void genesis_link_up(struct skge_
 
 	xm_write32(hw, port, XM_MODE, mode);
 
-	/* Turn on detection of Tx underrun, Rx overrun */
+	/* Turn on detection of Tx underrun */
 	msk = xm_read16(hw, port, XM_IMSK);
-	msk &= ~(XM_IS_RXF_OV | XM_IS_TXF_UR);
+	msk &= ~XM_IS_TXF_UR;
 	xm_write16(hw, port, XM_IMSK, msk);
 
 	xm_read16(hw, port, XM_ISRC);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

