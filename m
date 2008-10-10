From: Patrick McHardy <kaber@trash.net>
Subject: Re: IGMP sent to Foreign VLAN
Date: Fri, 10 Oct 2008 18:28:06 +0200
Message-ID: <48EF8296.3070507@trash.net>
References: <1223322707.24688.46.camel@deepthought.nh.local>	 <20081007.160702.189194318.davem@davemloft.net>	 <48EBF677.1060602@trash.net>	 <1223508896.24688.95.camel@deepthought.nh.local>	 <48EDF9A4.2090908@trash.net> <1223569129.24688.159.camel@deepthought.nh.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarod Neuner <j.neuner@networkharbor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58318 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756934AbYJJQ2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 12:28:11 -0400
In-Reply-To: <1223569129.24688.159.camel@deepthought.nh.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarod Neuner wrote:
> On Thu, 2008-10-09 at 07:31 -0500, Patrick McHardy wrote:
>> I don't think we should change the default, it would probably
>> catch some people by surprise. It might not be handled properly
>> by packet filtering rules etc.
> 
> On the other hand, I was surprised that VLAN packets were being dropped
> altogether.  Net admins tend to assign a link to a particular VLAN with
> little regard to the VLAN configuration of the hosts on that link.  I'm
> thinking of two general situations:
> 
> 1) If the kernel is resident on an application device (PC, Multimedia
> Device, SOHO Router, etc.), and a packet for a particular VLAN reaches
> the network interface with a correct MAC and a correct IP, then they
> were probably delivered correctly, whether that host is configured with
> that VLAN ID or even if the VLAN module is loaded.
> 
> 2) If the kernel is configured to route incoming VLAN packets, and a
> packet arrives with an unconfigured VLAN ID, then it seems perfectly
> reasonable to route it as if it had no VLAN tag.
> 
> I'm sure someone has a setup that expects that foreign VLANs will be
> dropped - but I suspect far more are generally indifferent to the
> policy.  There might even be a handful that will be pleasantly surprised
> when IGMP snooping suddenly starts to work.

Possible, but besides the fact that this has been our default
since even before VLAN was merged, a reason why this absolutely
has to be manually enabled is that it requires to disable hardware
filters for consistent, driver-independant behaviour.

>> So .. would you be interested in implementing this properly?
>> I think its a good change and I could help you if needed or
>> take care of some parts like the drivers myself.
> 
> I've got quite a bit on my plate at the moment, but I will give it a
> shot.  I'll try to come up with some of the IFF_ALLVLAN functionality
> over the next few days and get back to you.

Great, thanks.
