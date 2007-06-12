From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:26:58 -0700 (PDT)
Message-ID: <20070612.142658.45082832.davem@davemloft.net>
References: <20070612.140240.00078635.davem@davemloft.net>
	<466F0C92.5080306@garzik.org>
	<466F0D78.7090404@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751966AbXFLV0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:26:43 -0400
In-Reply-To: <466F0D78.7090404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 12 Jun 2007 14:17:44 -0700

> Jeff Garzik wrote:
> > 
> > If hardware w/ multiple queues will the capability for different MAC 
> > addresses, different RX filters, etc. does it make sense to add that 
> > below the net_device level?
> > 
> > We will have to add all the configuration machinery at the per-queue 
> > level that already exists at the per-netdev level.
> 
> Perhaps the mac-vlan patch would be a good fit.  Currently it is all
> software based, but if the hardware can filter on MAC, it can basically
> do mac-vlan acceleration.  The mac-vlan devices are just like 'real' ethernet
> devices, so they can be used with whatever schemes work with regular devices.

Interesting.

But to answer Jeff's question, that's not really the model being
used to implement multiple queues.

The MAC is still very much centralized in most designs.

So one way they'll do it is to support assigning N MAC addresses,
and you configure the input filters of the chip to push packets
for each MAC to the proper receive queue.

So the MAC will accept any of those in the N MAC addresses as
it's own, then you use the filtering facilities to steer
frames to the correct RX queue.

The TX and RX queues can be so isolated as to be able to be exported
to virtualization nodes.  You can give them full access to the DMA
queues and assosciated mailboxes.  So instead of all of this bogus
virtualized device overhead, you just give the guest access to the
real device.

So you can use multiple queues either for better single node SMP
performance, or better virtualization performance.

