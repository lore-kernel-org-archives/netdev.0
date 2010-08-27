From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 22:58:41 -0700
Message-ID: <4C775411.1000302@candelatech.com>
References: <4C773BAF.7010809@candelatech.com>	<20100826.213419.189712657.davem@davemloft.net>	<4C774B8F.2030805@candelatech.com> <20100826.223604.48516081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59908 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054Ab0H0F6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:58:43 -0400
In-Reply-To: <20100826.223604.48516081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 10:36 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 26 Aug 2010 22:22:23 -0700
>
>> On 08/26/2010 09:34 PM, David Miller wrote:
>>> From: Ben Greear<greearb@candelatech.com>
>>> Date: Thu, 26 Aug 2010 21:14:39 -0700
>>>
>>>> I'll look into the NET_XMIT_CN, but if that propagates backpressure up
>>>> through mac-vlan, then something must know how to re-start the tx
>>>> logic.
>>>
>>> It doesn't need to, as it drops and frees up the packet.
>>
>> If there were 5 pkts in the socket buffer, and the attempt to
>> send the first one caused NET_XMIT_CN, then
>> based on your comment below about UDP being throttled, I assume
>> the other 4 are kept until later?
>
> It only has an effect on TCP, it causes it to decrease the
> congestion window limits.
>
> I did not state that it had any effect on UDP.  Just because I
> talk about UDP later in my email doesn't mean the two things
> are related.

Ok, but you did state that UDP is well throttled.

To me that implies some backpressure will fill up socket transmit buffers
and slow down user-space transmit if the local network device cannot handle
the load.  And if it does that, then something must know how to restart the
transmit logic.

Maybe it's well throttled on real devices by the sched logic and
the netdev-wake-queue logic but just not on vlans?

Either way, it would be nice if we could throttle w/out having to drop
packets, so a way for certain sched types to return a BUSY code and not
delete the skb still seems useful, and not fundamentally different from
handling NET_XMIT_CN.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
