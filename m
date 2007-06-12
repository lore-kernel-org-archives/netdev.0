From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:52:11 -0700
Message-ID: <adazm347sdw.fsf@cisco.com>
References: <20070612.140240.00078635.davem@davemloft.net>
	<466F0C92.5080306@garzik.org> <466F0D78.7090404@candelatech.com>
	<20070612.142658.45082832.davem@davemloft.net>
	<466F142C.4040109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	netdev@vger.kernel.org, kaber@trash.net, hadi@cyberus.ca,
	peter.p.waskiewicz.jr@intel.com, auke-jan.h.kok@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:22531 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbXFLVwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:52:19 -0400
In-Reply-To: <466F142C.4040109@garzik.org> (Jeff Garzik's message of "Tue, 12 Jun 2007 17:46:20 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > The MAC is still very much centralized in most designs.
 > > So one way they'll do it is to support assigning N MAC addresses,
 > > and you configure the input filters of the chip to push packets
 > > for each MAC to the proper receive queue.
 > > So the MAC will accept any of those in the N MAC addresses as
 > > it's own, then you use the filtering facilities to steer
 > > frames to the correct RX queue.
 > 
 > Not quite...  You'll have to deal with multiple Rx filters, not just
 > the current one-filter-for-all model present in today's NICs.  Pools
 > of queues will have separate configured characteristics.  The "steer"
 > portion you mention is a bottleneck that wants to be eliminated.

I think you're misunderstanding.  These NICs still have only one
physical port, so sending or receiving real packets onto a physical
wire is fundamentally serialized.  The steering of packets to receive
queues is done right after the packets are received from the wire --
in fact it can be done as soon as the NIC has parsed enough of the
headers to make a decision, which might be before the full packet has
even been received.  The steering is no more of a bottleneck than the
physical link is.

 - R.
