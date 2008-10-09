From: Patrick McHardy <kaber@trash.net>
Subject: Re: IGMP sent to Foreign VLAN
Date: Thu, 09 Oct 2008 14:31:32 +0200
Message-ID: <48EDF9A4.2090908@trash.net>
References: <1223322707.24688.46.camel@deepthought.nh.local>	 <20081007.160702.189194318.davem@davemloft.net>	 <48EBF677.1060602@trash.net> <1223508896.24688.95.camel@deepthought.nh.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarod Neuner <j.neuner@networkharbor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49736 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757689AbYJIMbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 08:31:35 -0400
In-Reply-To: <1223508896.24688.95.camel@deepthought.nh.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarod Neuner wrote:
>> Patrick McHardy wrote:
>> We've been talking about an IFF_ALLVLAN flag on netdev a while
>> ago, which would disable VLAN hardware filters, similar to
>> IFF_ALLMULTI. An additional flag on the ethernet device could
>> indicate that it should receive unknown VLANs directly. That
>> would introduce some possible inconsistencies however since the
>> flag could be set without the VLAN code even loaded, in which
>> case it would not have any effect.
> 
> My original thought was to do something like this in net/core/dev.c
> using a method similar to handle_bridge or handle_macvlen.  So, if the
> packet doesn't get handled by the ptype_base list and IFF_ALLVLAN is
> set, then strip the header and let the packet through.  The sticky point
> would be whether or not this policy should be enabled by default, as it
> seems to be in other network stacks.

I don't think we should change the default, it would probably
catch some people by surprise. It might not be handled properly
by packet filtering rules etc.

>> Another possibility would be to use a catch-all VLAN device with
>> VID 0xfff (reserved for implementation use). This would allow
>> to configure priority mappings, header reordering etc. and have
>> separate statistics. The drivers could just use the magic VID
>> as an indication to disable filtering, but I would still suggest
>> to add the IFF_ALLVLAN flag because its useful on its own.
> 
> Most switches treat VLAN 1 as the "Default" or "Administration" VLAN.
> It might make sense to map VLAN 1 to the incoming interface, and then
> use that as a catch all.  Then again, that might be a terrible idea as
> well. =)

I prefer 0xfff because its not used for anything else so far.
Especially the administrative VLAN (even if only by convention)
doesn't seem by a good idea because its pretty likely you
would treat it differently from unknown VLANs wrt. filtering.

So .. would you be interested in implementing this properly?
I think its a good change and I could help you if needed or
take care of some parts like the drivers myself.

