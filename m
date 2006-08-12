From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sat, 12 Aug 2006 20:16:03 +0200
Message-ID: <20060812181603.GA31106@edgar.underground.se.axis.com>
References: <200608121207.42268.rjw@sisk.pl> <200608121631.18603.rjw@sisk.pl> <20060812161253.GA30691@edgar.underground.se.axis.com> <200608121913.01139.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:42445 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932466AbWHLSQF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 14:16:05 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k7CIG3P0030743
	for <netdev@vger.kernel.org>; Sat, 12 Aug 2006 20:16:03 +0200
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Content-Disposition: inline
In-Reply-To: <200608121913.01139.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 07:13:01PM +0200, Rafael J. Wysocki wrote:
> Apparently it doesn't.

Hi, could you try and see if this helps?

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946

Signed-off-by: Edgar E. Iglesias <edgar.iglesias@axis.com>

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 7de9a07..accefab 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2211,6 +2211,7 @@ static int skge_up(struct net_device *de
 	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
 	skge_led(skge, LED_MODE_ON);
 
+	netif_poll_enable(dev);
 	return 0;
 
  free_rx_ring:
@@ -2279,6 +2280,7 @@ static int skge_down(struct net_device *
 
 	skge_led(skge, LED_MODE_OFF);
 
+	netif_poll_disable(dev);	
 	skge_tx_clean(skge);
 	skge_rx_clean(skge);
 

