From: Patrick McHardy <kaber@trash.net>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 23:24:35 +0100
Message-ID: <4744B023.60504@trash.net>
References: <474387E4.7020802@candelatech.com>	<47448C4F.3060107@candelatech.com> <20071121120027.54c277ea@freepuppy.rosehill> <4744943E.2010000@trash.net> <47449AE9.5020301@candelatech.com> <47449F57.7080500@trash.net> <4744A8A3.8060406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43791 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbXKUWYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 17:24:46 -0500
In-Reply-To: <4744A8A3.8060406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
>>
>> That comes from iproute itself, but the missing LOWER-UP flag
>> indicates it and that should be enough for bridging and bonding.
>> I'm unsure about this though since its still a big difference in
>> userspace visible behaviour, people might just as well manually
>> configure failover once routing disappears or the device goes down,
>> or just have routing fall through to different routes. All this
>> wouldn't work anymore.
>>
>> Maybe we can make this optional somehow without too much uglyness?
>
> I'm fine with that..we can just add a new vlan-device flag similar to the
> reorder-header flag.

An alternative to this would be something like Julian Anastasov static 
routes
patch. Not sure if it has ever been considered for merging, but its a 
cleaner
way than doing per-device hacks.

http://www.ssi.bg/~ja/

>
> With the current code, on 'UP' of the underlying
> code, all of the VLANs will also go UP, even if the user had previously
> put them DOWN.  That seems like it could be quite dangerous/unexpected
> to me..but I guess it's required if we are going to automatically DOWN 
> them...

Yeah, I too never liked this behaviour.

>
> One other thought:  Maybe we could tell a small lie and say that we have
> NO-CARRIER on the VLAN when the underlying device is down OR has no 
> carrier?
>
> That way we keep normal link up/down semantics w/out having to change the
> admin state of the VLANs...

Thats pretty much what the operstate is doing, it should go to
IF_OPER_LOWERLAYERDOWN when the lower device is down. But as I
said above, people could actually rely on routes disappearing.


