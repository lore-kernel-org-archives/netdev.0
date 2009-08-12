From: David Miller <davem@davemloft.net>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 12 Aug 2009 16:29:21 -0700 (PDT)
Message-ID: <20090812.162921.244358554.davem@davemloft.net>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbZHLX3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 19:29:10 -0400
In-Reply-To: <20090807170600.9a2eff2e.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 7 Aug 2009 17:06:00 -0400

> To kludge around this, I made a different patch to the myri10ge driver.
> This time I hardcoded the NUMA node in the call to alloc_pages_node()
> to 2 for devices with an IRQ between 113 and 118 (eth2 through eth7)
> and to 0 for devices with an IRQ between 119 and 124 (eth8 through eth13).
> This is of course very specific to our specific system (NUMA node ids
> and Myricom 10-GigE device IRQs), and is not something that would be
> generically applicable.  But it was useful as a test, and it did
> improve the receive side performance substantially!

This, unfortunately, won't be comprehensive.  You'd also need to
kludge the NUMA node used for allocation of the skb->data buffer via
the netdev_alloc_skb() calls in myri10ge_rx_done() and friends.

This could possibly account for why, with your kludge, you still
were only getting 56.4703 Gbps
