From: Ben Greear <greearb@candelatech.com>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Mon, 03 Dec 2007 10:19:02 -0800
Message-ID: <47544896.7070101@candelatech.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>	<20071201202354.672aed18@freepuppy.rosehill>	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net> <m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54798 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbXLCSTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 13:19:41 -0500
In-Reply-To: <m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
>
>   
>> Ben Greear wrote:
>>     
>>> I have a binary module that uses dev_get_by_name...it's sort of a bridge-like
>>> thing and
>>> needs user-space to tell it which device to listen for packets on...
>>>
>>> This code doesn't need or care about name-spaces, so I don't see how it could
>>> really
>>> be infringing on the author's code (any worse than loading a binary driver
>>> into the kernel
>>> ever does).
>>>       
>
> Regardless of infringement it is incompatible with a complete network
> namespace implementation.  Further it sounds like the module you are
> describing defines a kernel ABI without being merged and hopes that
> ABI will still be supportable in the future.  Honestly I think doing so
> is horrible code maintenance policy.
>   
I don't mind if the ABI changes, so long as I can still use something 
similar.

The namespace logic is interesting to me in general, but at this point I 
can't think of a way that
it actually helps this particular module.  All I really need is a way to 
grab every frame
from eth0 and then transmit it to eth1.  I'm currently doing this by 
finding the netdevice
and registering a raw-packet protocol (ie, like tcpdump would do).  At 
least up to 2.6.23,
this does not require any hacks to the kernel and uses only non GPL 
exported symbols.

Based on my understanding of the namespace logic, if I never add any 
namespaces,
the general network layout should look similar to how it does today, so 
I should have
no logical problem with my module.

> Once things are largely complete it makes sense to argue with out of
> tree module authors that because they don't have network namespace
> support in their modules, their modules are broken.   
>   
Does this imply that every module that accesses the network code *must* 
become
GPL simply because it must interact with namespace logic that is 
exported as GPL only symbols?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


