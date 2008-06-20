From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Fri, 20 Jun 2008 14:52:33 -0400
Message-ID: <20080620145233.3e11b6fe.billfink@mindspring.com>
References: <20080619.041024.116139711.davem@davemloft.net>
	<OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org, vinay@linux.vnet.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:52428 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbYFTSwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 14:52:40 -0400
In-Reply-To: <OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a general question about this new tx queueing model, which
I haven't seen discussed to this point.

Although hopefully not frequent events, if the tx queue is kept in
the driver rather than the network midlayer, what are the ramifications
of a routing change which requires changing the output to a new interface,
considering for example that on our 10-GigE interfaces we typically set
txqueuelen to 10000.

Similarly, what are the ramifications of such a change to the bonding
driver (either in a load balancing or active/backup scenario) when one
of the interfaces fails (again hopefully a rare event).

Just wanting to get a better understanding of any possible impacts of
the new model, recognizing that as with most significant changes there
will be both positive and negative efects, with the negative hopefully
kept to a minimum possible.

						-Thanks

						-Bill



On Fri, 20 Jun 2008, Krishna Kumar2 wrote:

> Great, and this looks cool for batching too :)
> 
> Couple of comments:
> 
> 1. The modified drivers has a backlog of upto tx_queue_len skbs
>     compared to unmodified drivers which had tx_queue_len+q->limit.
>     Won't this result in a performance hit since packet drops will
>     take place earlier?
> 
> 2. __tg3_xmit_backlog() should check for not running too long. This
>     also means calling netif_schedule() if tx_backlog is !empty, to
>     avoid rotting packets in the backlog queue.
> 
> Thanks,
> 
> - KK
> 
> David Miller <davem@davemloft.net> wrote on 06/19/2008 04:40:24 PM:
> 
> >
> > tg3: Manage TX backlog in-driver.
> >
> > We no longer stop and wake the generic device queue.
> > Instead we manage the backlog inside of the driver,
> > and the mid-layer thinks that the device can always
> > receive packets.
> >
> > Signed-off-by: David S. Miller <davem@davemloft.net>
