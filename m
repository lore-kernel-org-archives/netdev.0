From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Mon, 12 Sep 2016 13:17:24 -0600
Message-ID: <bf36b487-1cdf-ede9-1ed8-cca17c7f5fc6@cumulusnetworks.com>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        =?UTF-8?Q?Andreas_H=c3=bcbner?= <andreas@k4n.de>,
        netdev@vger.kernel.org, "d. caratti" <davide.caratti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34782 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755094AbcILTR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 15:17:27 -0400
Received: by mail-pf0-f169.google.com with SMTP id p64so55363174pfb.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 12:17:27 -0700 (PDT)
In-Reply-To: <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/16 11:26 AM, Hannes Frederic Sowa wrote:
> Hello,
> 
> On 12.09.2016 16:27, Andreas Hübner wrote:
>> Hi,
>>
>> I'm currently debugging a potential issue with the icmpv6 stack and
>> hopefully this is the correct place to ask. (Was actually looking for a
>> more specific list, but didn't find anything. Please point me to a more
>> apropriate list if this is out of place here.)
>>
>> I have the following setup:
>>   - 2 directly connected hosts (A+B), both have only link local addresses
>>     configured (interface on both hosts is eth0)
>>   - host B is also connected to another host C (via interface eth1)
>>   - main routing table (relevant part) on host B looks like this:
>>
>>       fe80::/64 dev eth1  proto kernel  metric 256
>>       fe80::/64 dev eth0  proto kernel  metric 256
>>
>>   - host A is trying to ICMPv6 ping the link local address of host B
>>
>> The issue I currently have is, that the echo reply that host B should
>> generate is never sent back to host A. If I change the order of the
>> routing table entries on host B, everything works fine.
>> (host A is connected on eth0)
>>
>> I'm wondering, if this is how it is supposed to work. Do we need to do a
>> routing table lookup when generating an ICMPv6 echo reply for link local
>> addresses?  (From my understanding, this is not done in the neighbour
>> discovery stack, so why here?)
> 
> For global addresses this is necessary as asymetric routing could be
> involved and we don't want to treat ping echos in any way special.
> 
>> Actually, I'm convinced I must be doing something wrong here. The setup
>> for the issue is quite trivial, someone would have tripped over it
>> already. The only condition is that one host has multiple interfaces
>> with ipv6 enabled.
>>
>> Any help in shedding some light onto this issue would be appreciated.
> 
> This shouldn't be the case. We certainly carry over the ifindex of the
> received packet into the routing lookup of the outgoing packet, thus the
> appropriate rule, with outgoing ifindex should be selected.
> 
> I also couldn't reproduce your problem here with my system. Can you
> verify with tcpdump that the packet is leaving on another interface?

v4.4 and on there are fib6 tracepoints that show the lookup result. May provide some insights.

perf record -a -e fib6:* 
perf script
