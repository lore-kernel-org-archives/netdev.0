From: Ben Greear <greearb@candelatech.com>
Subject: Re: MTU and TCP transmit offload.
Date: Wed, 21 Sep 2011 16:42:22 -0700
Message-ID: <4E7A765E.6020701@candelatech.com>
References: <4E7A51EE.8010403@candelatech.com> <4E7A612C.9090508@hp.com> <4E7A6225.8040902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51017 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab1IUXmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 19:42:35 -0400
In-Reply-To: <4E7A6225.8040902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2011 03:16 PM, Ben Greear wrote:
> On 09/21/2011 03:11 PM, Rick Jones wrote:
>> On 09/21/2011 02:06 PM, Ben Greear wrote:
>>> We saw something interesting while doing some testing
>>> on 3.0.4.
>>>
>>> We configured 2 Ethernet NICs with standard 1500 MTU, and added
>>> a mac-vlan on each, with MTU of 300. The goal was to generate as
>>> many ~300 byte TCP packets as possible, for load testing purposes.
>>> We configured our tool to open sockets on the mac-vlans and send/receive
>>> TCP (IPv4) traffic.
>>
>> Presumably one could instead set static PathMTU entries in the routing tables and accomplish the same thing as you did with the mac-vlans?
>>
>>> This actually seems to work quite nicely, allowing user-space to
>>> do large writes (24k in our case), and it appears have lots of
>>> small packets on the wire. We still need to sniff with external
>>> system to verify this..but packets-per-second counters look good.
>>>
>>> Evidently this all works because macvlans know that the NIC
>>> can do TSO, and the '300' MTU is passed in the big packet
>>> given to the NIC.
>>>
>>> This got me thinking...at least for my purposes, it would be
>>> nice to have a per-socket 'MTU' setting. The idea is that
>>> you could ask the NIC to do the TSO at whatever 'mtu' you
>>> wanted, without having to resort to mac-vlans with artificially
>>> small MTU.
>>>
>>> So, is there any interest in supporting such a socket option?
>>>
>>> I can't think of any use besides TCP traffic load testing, but
>>> perhaps someone else can think of one? Or, is load-testing
>>> enough?
>>
>> Isn't that covered by setsockopt() support for TCP_MAX_SEG? With TSO what gets passed to the NIC isn't the MTU, but the connection's MSS derived (in part at
>> least) from the MTU of the egress interface. If one had made a setsockopt(TCP_MAX_SEG) call prior to the connect() or listen() call, presumably that would have
>> influenced the MSS exchange at connection establishment.
>
> Ohh, that looks promising!
>
> I'll give that a try.

This works like a charm.  I'm so glad I don't need to hack
a new sockopt!

Thanks,
Ben

>
> Thanks,
> Ben
>
>>
>> rick jones
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
