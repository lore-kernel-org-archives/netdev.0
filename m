From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 17:46:20 -0400
Message-ID: <466F142C.4040109@garzik.org>
References: <20070612.140240.00078635.davem@davemloft.net>	<466F0C92.5080306@garzik.org>	<466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58597 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbXFLVqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:46:24 -0400
In-Reply-To: <20070612.142658.45082832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 12 Jun 2007 14:17:44 -0700
> 
>> Jeff Garzik wrote:
>>> If hardware w/ multiple queues will the capability for different MAC 
>>> addresses, different RX filters, etc. does it make sense to add that 
>>> below the net_device level?
>>>
>>> We will have to add all the configuration machinery at the per-queue 
>>> level that already exists at the per-netdev level.
>> Perhaps the mac-vlan patch would be a good fit.  Currently it is all
>> software based, but if the hardware can filter on MAC, it can basically
>> do mac-vlan acceleration.  The mac-vlan devices are just like 'real' ethernet
>> devices, so they can be used with whatever schemes work with regular devices.
> 
> Interesting.
> 
> But to answer Jeff's question, that's not really the model being
> used to implement multiple queues.
> 
> The MAC is still very much centralized in most designs.
> 
> So one way they'll do it is to support assigning N MAC addresses,
> and you configure the input filters of the chip to push packets
> for each MAC to the proper receive queue.
> 
> So the MAC will accept any of those in the N MAC addresses as
> it's own, then you use the filtering facilities to steer
> frames to the correct RX queue.

Not quite...  You'll have to deal with multiple Rx filters, not just the 
current one-filter-for-all model present in today's NICs.  Pools of 
queues will have separate configured characteristics.  The "steer" 
portion you mention is a bottleneck that wants to be eliminated.

	Jeff



