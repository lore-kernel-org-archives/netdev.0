From: Ben Greear <greearb@candelatech.com>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Sun, 26 Apr 2009 12:58:35 -0700
Message-ID: <49F4BCEB.6040507@candelatech.com>
References: <49F1DE6F.1030606@trash.net> <49F1EB2F.1050505@candelatech.com> <30658.1240619463@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42963 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbZDZT6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 15:58:42 -0400
In-Reply-To: <30658.1240619463@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
>> If so, I think that is not a good idea and could possibly be considered
>> a security issue.  I think instead there should be a new flag for VLANs
>> that is 'preferred-admin-state'.  To be UP, both the underlying device
>> and the preferred state must be UP.  That should allow bouncing eth0
>> w/out affecting the eventual admin state of the VLANs on eth0 in
>> the example above.
>>     
>
> 	I dunno if it's a security issue, but I'd agree it's wrong.  I
> looked, and I suspect that a couple of judiciously placed "if
> (dev->flags & IFF_UP)" bits ought to sort things out by simply not
> copying the carrier state to the upper level VLAN device if that device
> is down.  Unless somebody works this up over the weekend, I'll work that
> out on Monday.
>   
That may be fine.  I suppose you'll also be ignoring admin state changes 
for the
underlying devices in the VLAN code?  Ie, if eth0 goes admin down, you won't
change the eth0.5 vlan to be admin down?


> 	Would they actually need a flag, or could it be worked out just
> by checking their IFF_UP-ness?
>   
If no admin state is propagated at all, I think you can skip any extra 
flags.  But,
if you want to propagate admin state (as the kernel does now with VLANs),
then I don't see how you can get by without another flag.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


