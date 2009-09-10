From: Patrick McHardy <kaber@trash.net>
Subject: Re: igb bandwidth allocation configuration
Date: Thu, 10 Sep 2009 13:28:14 +0200
Message-ID: <4AA8E2CE.2080707@trash.net>
References: <20090910081844.GA5421@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbZIJL2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 07:28:17 -0400
In-Reply-To: <20090910081844.GA5421@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> Hi,
> 
> I have been looking into adding support the 82586's per-PF/VF
> bandwidth allocation to the igb driver. It seems that the trickiest
> part is working out how to expose things to user-space.
> 
> I was thinking along the lines of an ethtool option as follows:
> 
> 	ethtool --bandwidth ethN LIMIT...
> 
> 	where:
> 		* There is one LIMIT per PF/VF.
> 		  The 82576 can have up to 7 VFs per PF,
> 		  so there would be up to 8 LIMITS
> 		* A keyword (none?) can be used to denote that
> 		  bandwidth allocation should be disabled for the
> 		  corresponding VM
> 		* Otherwise LIMITS are in Megabits/s
> 
> This may get a bit combersome if there are a lot of VFs per PF,
> perhaps a better syntax would be:
> 
> 	ethtool --bandwidth ethN M=LIMIT...
> 
> 	where:
> 		* LIMIT is as above
> 		* M is some key to denote which VF/PF is
> 		  having its limit set.
> 
> Internally it seems that actually the limits are applied to HW Tx queues
> rather than directly VMs. There are 16 such queues. Accordingly it might
> be useful to design an interface to set limits per-queue using ethtool.
> But this would seem to also require exposing which queues are associated
> with which PF/VF.

Just an idea since I don't know much about this stuff:

Since we now have the mq packet scheduler, which exposes the device
queues as qdisc classes, how about adding driver-specific configuration
attributes that are passed to the driver by the mq scheduler? This
would allow to configure per-queue bandwidth limits using regular TC
commands and also use those limits without VFs for any kind of traffic.
Drivers not supporting this would refuse unsupported options.

