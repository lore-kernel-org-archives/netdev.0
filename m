From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] sky2: remove dual port workaround
Date: Mon, 14 May 2007 12:38:14 -0700
Message-ID: <20070514193945.863254347@linux-foundation.org>
References: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:33214 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752403AbXENTmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:42:45 -0400
Content-Disposition: inline; filename=sky2-napi-ok.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This workaround was added to deal with NAPI core and how
it affected dual port shared polling. It turned out not to
be necessary. Stopping device 0 only doesn't stop NAPI from
working completely after that.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 -------
 1 file changed, 7 deletions(-)

--- 2.6.21-rc1.orig/drivers/net/sky2.c	2007-05-14 12:10:18.000000000 -0700
+++ 2.6.21-rc1/drivers/net/sky2.c	2007-05-14 12:10:22.000000000 -0700
@@ -1579,13 +1579,6 @@ static int sky2_down(struct net_device *
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
-	/*
-	 * Both ports share the NAPI poll on port 0, so if necessary undo the
-	 * the disable that is done in dev_close.
-	 */
-	if (sky2->port == 0 && hw->ports > 1)
-		netif_poll_enable(dev);
-
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */

--
Stephen Hemminger <shemminger@linux-foundation.org>

