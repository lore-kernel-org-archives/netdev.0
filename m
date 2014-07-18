From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH v2 0/3] Broadcast/Multicast rate limit via Ethtool
 Coalesce
Date: Fri, 18 Jul 2014 11:07:35 +0530
Message-ID: <53C8B29F.5@ti.com>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com> <20140709.164420.157865201153845876.davem@davemloft.net> <53C76990.3000304@ti.com> <063D6719AE5E284EB5DD2968C1650D6D172768B0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172768B0-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 17 July 2014 06:23 PM, David Laight wrote:
>> From: Mugunthan V N
>> On Thursday 10 July 2014 05:14 AM, David Miller wrote:
>>> From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>>> Date: Wed, 9 Jul 2014 12:44:07 +0530
>>>
>>>> A system/cpu can be loaded by a hacker with flooding of broadcast or
>>>> multicast packets, to prevent this some Ethernet controllers like CPSW
>>>> provide a mechanism to limit the broadcast/multicast packet rate via
>>>> hardware limiters. This patch series enables this feature via
>>>> Ethtool Coalesce.
>>> This is pretty bogus if you ask me.
>>>
>>> What is the difference from accepting a high rate of unicast packets?
>>> I say it is no different.
>>>
>>> Therefore, this feature makes no sense to me at all.
>> Any packet storm can cause an endpoint some issues. Typically packet
>> storms will cause the system CPU to thrash resulting is very low system
>> performance.
>>
>> Unicast storms only target a single destination end station, it can be
>> easily mitigated by the host adding a blocking entry in the LUT for each
>> aggressor.
>>
>> Broadcast and multicast target multiple end stations, or an entire
>> network, not only can it cause CPU thrashing, it can result in loss of
>> other broadcast and multicast services. The rate limiting feature allow
>> the broadcast and or multicast traffic to be dropped if the rates are
>> too high. This eliminates the CPU thrashing issue. It also allows the
>> system to analyze the aggressors and block them for future transgressions.
> Rate limiting multicast traffic will definitely cause the loss of multicast
> services.

When a system apply the rate limit, the system should expect to miss
some of the broadcast/multicast packet depending on the rate limit it
applies.

>
> My experience of broadcast storms is that many of the ethernet switches
> (probably especially the cheap ones) end up using a much slower software?
> path for broadcasts. In a broadcast storm they start discarding normal
> traffic - to point where a single ssh session becomes unusable.
> This is true even when isolated from the storm by a 10M hub.
>
> Broadcast storms are probably mostly caused by network topology issues.
> Especially is switches are sending traffic to 'all ports' while resetting
> the spanning tree tables.
>

This is one more example where broadcast/multicast rate limit can be used.

Regards
Mugunthan V N
