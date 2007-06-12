From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 17:47:53 -0400
Message-ID: <20070612214753.GB27363@metaxa.reflex>
References: <20070612.140240.00078635.davem@davemloft.net> <466F0C92.5080306@garzik.org> <466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, jeff@garzik.org, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:35464 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbXFLWgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 18:36:31 -0400
Content-Disposition: inline
In-Reply-To: <20070612.142658.45082832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 02:26:58PM -0700, David Miller wrote:
> The MAC is still very much centralized in most designs.
> 
> So one way they'll do it is to support assigning N MAC addresses,
> and you configure the input filters of the chip to push packets
> for each MAC to the proper receive queue.
> 
> So the MAC will accept any of those in the N MAC addresses as
> it's own, then you use the filtering facilities to steer
> frames to the correct RX queue.
> 
> The TX and RX queues can be so isolated as to be able to be exported
> to virtualization nodes.  You can give them full access to the DMA
> queues and assosciated mailboxes.  So instead of all of this bogus
> virtualized device overhead, you just give the guest access to the
> real device.
> 
> So you can use multiple queues either for better single node SMP
> performance, or better virtualization performance.

Are you aware of any hardware designs that allow other ways to map
packets onto rx queues?  I can think of several scenarios where it could
be advantageous to map packets by IP 3- or 5-tuple to get cpu locality
all the way up the stack on a flow-by-flow basis. But doing this would
require some way to request this mapping from the hardware.

In the extreme case it would be cool if it were possible to push a
bpf-like classifier down into the hardware to allow arbitrary kinds of
flow distribution.

Jason
