From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: Fixes to avoid soft lockup in sunvnet
Date: Mon, 11 Aug 2014 17:03:54 -0400
Message-ID: <20140811210354.GB20351@oracle.com>
References: <20140810194807.GB5222@oracle.com>
 <20140811.135642.2149726326739266234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24650 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950AbaHKVEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:04:01 -0400
Content-Disposition: inline
In-Reply-To: <20140811.135642.2149726326739266234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (08/11/14 13:56), David Miller wrote:
> 
> Please don't fix multiple things in one huge patch, split up the
> changes into separate easily reviewed patches.

So there were 4 different sources of soft-lockup here, each of them
was just a few lines of change. Do you really want these as 4 patches?

I have no issues doing that (and also fixing the rest below)
but I just wanted to make sure that's really what's being asked for- 
since it seems like a lot of small patches, for something that made 
sense for me to test as one piece.


> 
> > +/*
> > + * Heuristic for the number of times to exponentially backoff and
> > + * retry sending an LDC trigger when EAGAIN is encountered
> > + */
> 
> In the networking, comments are formatted:
> 
> /* Like
>  * this.
>  */
> 
> > +			printk(KERN_INFO 
> > +			    "ECONNRESET %x:%x:%x:%x:%x:%x\n",
> > +			    port->raddr[0], port->raddr[1],
> > +			    port->raddr[2], port->raddr[3],
> > +			    port->raddr[4], port->raddr[5]);
> 
> This is not indented correctly.  The second and subsequent lines
> of the printk() function call should start at exactly the first
> column after the openning parenthesis of the function call.
> 
> > +	/*
> > +	 * Kick off a tasklet to wake the queue.  We cannot call 
> > +	 * maybe_tx_wakeup directly here because we could deadlock on
> > +	 * netif_tx_lock() with dev_watchdog()
> > +	 */
> 
> Comment formatting.
> 
> > +	/*
> > +	 * We don't rely on the ACKs to free the skb in vnet_start_xmit(),
> > +	 * thus it is safe to not set VIO_ACK_ENABLE for each transmission:
> > +	 * the protocol itself does not require it as long as the peer
> > +	 * sends a VIO_SUBTYPE_ACK for VIO_DRING_STOPPED. 
> > +	 *
> > +	 * An ACK for every packet in the ring is expensive as the
> > +	 * sending of LDC messages is slow and affects performance.
> > +	 */
> 
> Likewise.
