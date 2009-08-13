From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 12 Aug 2009 22:35:50 -0400
Message-ID: <20090812223550.377a09c5.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090812.162921.244358554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:44207 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226AbZHMCfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 22:35:53 -0400
In-Reply-To: <20090812.162921.244358554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2009, David Miller wrote:

> From: Bill Fink <billfink@mindspring.com>
> Date: Fri, 7 Aug 2009 17:06:00 -0400
> 
> > To kludge around this, I made a different patch to the myri10ge driver.
> > This time I hardcoded the NUMA node in the call to alloc_pages_node()
> > to 2 for devices with an IRQ between 113 and 118 (eth2 through eth7)
> > and to 0 for devices with an IRQ between 119 and 124 (eth8 through eth13).
> > This is of course very specific to our specific system (NUMA node ids
> > and Myricom 10-GigE device IRQs), and is not something that would be
> > generically applicable.  But it was useful as a test, and it did
> > improve the receive side performance substantially!
> 
> This, unfortunately, won't be comprehensive.  You'd also need to
> kludge the NUMA node used for allocation of the skb->data buffer via
> the netdev_alloc_skb() calls in myri10ge_rx_done() and friends.
> 
> This could possibly account for why, with your kludge, you still
> were only getting 56.4703 Gbps

I actually did try this.  I changed the netdev_alloc_skb() call in
the myri10ge driver to an __alloc_skb() call and explicitly specified
the correct NUMA node (plus all the necessary extra code that gets
done under the covers by netdev_alloc_skb()).  It didn't help.

Not being a kernel developer, one thing I didn't know though was if
the skb was initially allocated on NUMA node A, as the skb got expanded
during its processing, would it always stay on NUMA node A, or could
it possibly be migrated subsequently to a different NUMA node B.

						-Thanks

						-Bill
