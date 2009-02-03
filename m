From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] sky2: remove unneede workaround
Date: Tue, 03 Feb 2009 13:27:27 -0800
Message-ID: <20090203212755.892910982@vyatta.com>
References: <20090203212726.983207890@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:48592 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbZBCV3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 16:29:25 -0500
Content-Disposition: inline; filename=sky2-tim-opt.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This workaround is not needed. It was inherited from sk98lin driver but only
applies to an early development version of the chip that is not supported
by sky2.  The workaround required an unnecessary pci read which hurts performance

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-01-26 17:23:25.869792360 -0800
+++ b/drivers/net/sky2.c	2009-01-27 09:43:21.770394724 -0800
@@ -2687,13 +2687,6 @@ static int sky2_poll(struct napi_struct 
 			goto done;
 	}
 
-	/* Bug/Errata workaround?
-	 * Need to kick the TX irq moderation timer.
-	 */
-	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-	}
 	napi_complete(napi);
 	sky2_read32(hw, B0_Y2_SP_LISR);
 done:

-- 

