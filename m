From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Wed, 28 Nov 2007 18:22:56 +0100
Message-ID: <18253.41968.996941.498155@robur.slu.se>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
	<474C9B84.5090103@intel.com>
	<20071127145537.6bf1af68@freepuppy.rosehill>
	<474CB54A.2060804@intel.com>
	<18253.24783.174884.502970@robur.slu.se>
	<20071128083826.3a9400d1@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:43086 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758861AbXK1RXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 12:23:07 -0500
In-Reply-To: <20071128083826.3a9400d1@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



 No it doesn't. besides napi_disable and napi_synchronize are identical. 
 I was trying to disarm interrupts this way too. 

 The patch I did send yesterday is the only cure so-far but I don't if 
 it's 100% bullet proof either.

 I was stress-testing it patch but ran into new problems...(scheduling)
 
 Cheers.
					--ro


Stephen Hemminger writes:
 > Would this fix it?
 > 
 > --- a/drivers/net/e1000/e1000_main.c	2007-11-15 21:13:12.000000000 -0800
 > +++ b/drivers/net/e1000/e1000_main.c	2007-11-28 08:37:03.000000000 -0800
 > @@ -630,10 +630,10 @@ e1000_down(struct e1000_adapter *adapter
 >  	 * reschedule our watchdog timer */
 >  	set_bit(__E1000_DOWN, &adapter->flags);
 >  
 > +	e1000_irq_disable(adapter);
 >  #ifdef CONFIG_E1000_NAPI
 > -	napi_disable(&adapter->napi);
 > +	napi_synchronize(&adapter->napi);
 >  #endif
 > -	e1000_irq_disable(adapter);
 >  
 >  	del_timer_sync(&adapter->tx_fifo_stall_timer);
 >  	del_timer_sync(&adapter->watchdog_timer);
