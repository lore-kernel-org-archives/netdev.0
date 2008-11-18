From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ARP table question
Date: Mon, 17 Nov 2008 17:39:45 -0800
Message-ID: <49221CE1.9000807@hp.com>
References: <491B1841.9050404@candelatech.com>	<491B31EB.4050304@candelatech.com>	<491B5452.6020709@candelatech.com>	<20081116.191628.135824721.davem@davemloft.net>	<4921B521.1010305@candelatech.com>	<49220D75.1070803@candelatech.com> <4922119E.6030601@hp.com> <49221929.7060504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11842 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbYKRBju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 20:39:50 -0500
In-Reply-To: <49221929.7060504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Rick Jones wrote:
> 
>>> +static unsigned long neigh_rand_retry(struct neighbour* neigh) {
>>> +    if (neigh->parms->retrans_rand_backoff) {
>>> +        return net_random() % neigh->parms->retrans_rand_backoff;
>>> +    }
>>> +    return 0;
>>> +}
>>> +
>>>  /* Called when a timer expires for a neighbour entry. */
>>
>>
>> I thought that mod was something we tried to avoid?  Could you instead 
>> use something that isn't random but perhaps varies among all the 
>> requests?  Say some of the low-order bits of the IP being resolved?
> 
> 
> This is only called when we are going to retransmit an ARP, which shouldn't
> be in any sort of hot path, so I figured MOD was fine.
> 
> The net_random is a very cheap method (last I checked), as well.
> 
> So, I think that part is OK as it is, but I'm open to
> persuasion :)

Perhaps I'm confused, or simply channeling Emily Litella again, but if 
you only do this on the 1st through Nth retransmissions (ie after the 
first retransmission timer has popped) don't you still have a thundering 
herd problem on the first transmission and the first retransmission of 
ARP requests?

rick jones
