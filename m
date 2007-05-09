From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 04/17] sky2: remove dual port workaround
Date: Tue, 08 May 2007 20:49:53 -0700
Message-ID: <20070509035028.534777319@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59044 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032759AbXEIEDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:25 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-napi-ok.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This workaround was added to deal with NAPI core and how
it affected dual port shared polling. It turned out not to
be necessary, the core code in dev_stop() waits for NAPI but
doesn't kill it.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 -------
 1 file changed, 7 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:28:54.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:28:58.000000000 -0700
@@ -1570,13 +1570,6 @@ static int sky2_down(struct net_device *
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

