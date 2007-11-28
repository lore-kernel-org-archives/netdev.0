From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Wed, 28 Nov 2007 08:38:26 -0800
Message-ID: <20071128083826.3a9400d1@freepuppy.rosehill>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
	<474C9B84.5090103@intel.com>
	<20071127145537.6bf1af68@freepuppy.rosehill>
	<474CB54A.2060804@intel.com>
	<18253.24783.174884.502970@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44646 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759856AbXK1QjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 11:39:10 -0500
In-Reply-To: <18253.24783.174884.502970@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Would this fix it?

--- a/drivers/net/e1000/e1000_main.c	2007-11-15 21:13:12.000000000 -0800
+++ b/drivers/net/e1000/e1000_main.c	2007-11-28 08:37:03.000000000 -0800
@@ -630,10 +630,10 @@ e1000_down(struct e1000_adapter *adapter
 	 * reschedule our watchdog timer */
 	set_bit(__E1000_DOWN, &adapter->flags);
 
+	e1000_irq_disable(adapter);
 #ifdef CONFIG_E1000_NAPI
-	napi_disable(&adapter->napi);
+	napi_synchronize(&adapter->napi);
 #endif
-	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
