From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Fri, 08 Jun 2007 10:00:20 -0700
Message-ID: <46698B24.2030309@candelatech.com>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com> <466826C6.6000206@openvz.org> <46682976.8050904@candelatech.com> <46697D0A.40006@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60492 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968866AbXFHRAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 13:00:41 -0400
In-Reply-To: <46697D0A.40006@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Ben Greear wrote:
>
> [snip]
>
>   
>>>> I would also like some way to identify veth from other device types,
>>>> preferably
>>>> something like a value in sysfs.   However, that should not hold up
>>>>     
>>>>         
>>> We can do this with ethtool. It can get and print the driver name of
>>> the device.
>>>   
>>>       
>> I think I'd like something in sysfs that we could query for any
>> interface.  Possible return
>> strings could be:
>> VLAN
>> VETH
>> ETH
>> PPP
>> BRIDGE
>> AP /* wifi access point interface */
>> STA /* wifi station */
>> ....
>>
>> I will cook up a patch for consideration after veth goes in.
>>
>>     
>
> Ben, could you please tell what sysfs features do you
> plan to implement?
>   
I think this is the only thing that has a chance of getting into the kernel.
Basically, I have a user-space app and I want to be able to definitively 
know the type for
all interfaces.  Currently, I have a hodge-podge of logic to query 
various ioctls and /proc
files and finally, guess by name if nothing else works.  There must be a 
better way :P

I have another sysfs patch that allows setting a default skb->mark for 
an interface so that you can set the skb->mark
before it hits the connection tracking logic, but I'm been told this one 
has very little chance
of getting into the kernel.  The skb->mark patch is only useful (as far 
as I can tell) if you
also include a patch Patrick McHardy did for me that allowed the 
conn-tracking logic to
use skb->mark as part of it's tuple.  This allows me to do NAT between 
virtual routers
(routing tables) on the same machine using veth-equivalent drivers to 
connect the
routers.  He thinks this will probably not ever get into the kernel either.

I have another sysctl related send-to-self patch that also has little 
chance of getting into the kernel, but
it might be quite useful with veth (it's useful to me..but my needs 
aren't exactly mainstream :))
I'll post this separately for consideration....

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


