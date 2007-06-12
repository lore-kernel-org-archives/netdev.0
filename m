From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 17:59:43 -0400
Message-ID: <466F174F.5090206@garzik.org>
References: <20070612.140240.00078635.davem@davemloft.net>	<466F0C92.5080306@garzik.org> <466F0D78.7090404@candelatech.com>	<20070612.142658.45082832.davem@davemloft.net>	<466F142C.4040109@garzik.org> <adazm347sdw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	netdev@vger.kernel.org, kaber@trash.net, hadi@cyberus.ca,
	peter.p.waskiewicz.jr@intel.com, auke-jan.h.kok@intel.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58731 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755548AbXFLV7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:59:49 -0400
In-Reply-To: <adazm347sdw.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > > The MAC is still very much centralized in most designs.
>  > > So one way they'll do it is to support assigning N MAC addresses,
>  > > and you configure the input filters of the chip to push packets
>  > > for each MAC to the proper receive queue.
>  > > So the MAC will accept any of those in the N MAC addresses as
>  > > it's own, then you use the filtering facilities to steer
>  > > frames to the correct RX queue.
>  > 
>  > Not quite...  You'll have to deal with multiple Rx filters, not just
>  > the current one-filter-for-all model present in today's NICs.  Pools
>  > of queues will have separate configured characteristics.  The "steer"
>  > portion you mention is a bottleneck that wants to be eliminated.
> 
> I think you're misunderstanding.  These NICs still have only one
> physical port, so sending or receiving real packets onto a physical
> wire is fundamentally serialized.  The steering of packets to receive
> queues is done right after the packets are received from the wire --
> in fact it can be done as soon as the NIC has parsed enough of the
> headers to make a decision, which might be before the full packet has
> even been received.  The steering is no more of a bottleneck than the
> physical link is.

No, you're misreading.  People are putting in independent configurable 
Rx filters because a single Rx filter setup for all queues was a 
bottleneck.  Not a performance bottleneck but a configuration and 
flexibility limitation that's being removed.

And where shall we put the configuration machinery, to support sub-queues?
Shall we duplicate the existing configuration code for sub-queues?
What will ifconfig/ip usage look like?
How will it differ from configurating full net_devices, if you are 
assigning the same types of parameters?

	Jeff



