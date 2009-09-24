From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Thu, 24 Sep 2009 10:07:36 -0700
Message-ID: <4ABBA758.4030609@candelatech.com>
References: <4ABAA2D0.4030608@candelatech.com> <4ABAB727.2020507@hp.com> <4ABAD48C.9010808@candelatech.com> <4ABB9EB3.1000307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57980 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbZIXRHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 13:07:34 -0400
In-Reply-To: <4ABB9EB3.1000307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2009 09:30 AM, Rick Jones wrote:
> Ben Greear wrote:
>> Rick Jones wrote:
>>> Ben Greear wrote:
>>>
>>>> When LRO is enabled, the received packet and byte counters represent
>>>> the
>>>> LRO'd packets, not the packets/bytes on the wire.
>>>
>>>
>>> When LRO is enabled, are all the bytes on the wire actually
>>> transferred into the host?
>>
>> No...the ethernet, IP and TCP headers and such are not, for packets
>> that are combined into a single large SKB.
>>
>> That is why the driver counts them wrong. The bytes are off by a few
>> percentage points, but the packet count is off by an order of magnitude.
>
> An overly philosphical question perhaps, but are ethtool stats supposed
> to represent what was on the wire, or what entered the host?

They report whatever they report, you get to set custom labels for the values,
and every NIC/driver may be different, so only humans and crazy code like mine that does
specific things based on the driver reported by ethtool should use it.

A more interesting question to me is what netdev-stats tx/rx byte counters should report?

My opinions:
ethernet header (yes)
ethernet CRC  (yes)
ethernet preamble (no)
ethernet frame gap (no)

I think many don't count the CRC, but I haven't looked recently.

Some didn't even report the ethernet header properly a few years ago, but
I think most do now.

When LRO is enabled, it's hard to say if we should report the LRO pkt
stats or the stats on the wire for the netdev-stats.  At least in my case,
I want to report the stats on the wire, but it's also good to see the
LRO stats because you can easily tell that LRO is actually working if you
see low pkts-per-second counters v/s high-bits-per-sec.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

