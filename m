From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Tx queue selection
Date: Tue, 27 Jul 2010 07:50:47 -0400
Message-ID: <20100727115047.GB6303@hmsreliant.think-freely.org>
References: <1280227867.1970.208.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58926 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab0G0LyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 07:54:19 -0400
Content-Disposition: inline
In-Reply-To: <1280227867.1970.208.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 08:51:07PM +1000, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> I'm putting my newbie hat on ... :-)
> 
> While looking at our ehea driver (and in fact another upcoming driver
> I'm helping with), I noticed it's using the "old style" multiqueue. IE.
> It doesn't use the alloc_netdev_mq() variant, creates one queue on the
> linux side, an makes its own selection of HW queue in start_xmit.
> 
> This had many drawbacks, obviously, such as not getting per-queue locks
> etc...
> 
> Now, the mechanics of converting that to the new scheme are easy enough
> to figure out by reading the code. However, where my lack of networking
> background fails me is when it comes to the policy of choosing a Tx
> queue.
> 
> ehea uses its own hash of the header, different from the "default" queue
> selection in the net core. Looking at other drivers such as ixgbe, I see
> that it can chose to use smp_processor_id() when a flag is set for which
> I don't totally understand the meaning or default to the core algorithm.
> 
IIRC, that intels Flow Director feature.  I've not used it, but from what I
understand flow director is a technology that allows a card to isolate flows to
and from a socket to a single cpu.  i.e. the cpu which handles the transmission
of frames will be the cpu that handles frames destined for that flow as well.
To do this they do some additional analysis and steering configuration in the
driver using a user space utility as well.  I don't think it makes much sense to
use smp_processor_id in your tx hashing if you don't have some sort of specific
feature like that.  The other drivers which implement ndo_select_queue don't do
it, they hash on the skb header like the core does, and make modifications to
that based on hardware capabilities.

HTH
Neil

> 
