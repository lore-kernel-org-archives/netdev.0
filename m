From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: udp v6 early demux?
Date: Tue, 10 Feb 2015 21:53:48 -0500
Message-ID: <54DAC43C.2090101@gmail.com>
References: <54DA3C64.1060309@gmail.com> <1423589555.28434.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:61498 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbBKCxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 21:53:50 -0500
Received: by mail-qa0-f53.google.com with SMTP id k15so695062qaq.12
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 18:53:50 -0800 (PST)
In-Reply-To: <1423589555.28434.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2015 12:32 PM, Eric Dumazet wrote:
> On Tue, 2015-02-10 at 12:14 -0500, Vlad Yasevich wrote:
>> Hi
>>
>> While testing udpv6 lockless path, I noticed that there is no
>> support for udpv6 early demux?  Is there a technical reason why,
>> or was this just something that got forgotten (kind of like
>> lockeless sendmsg)?
> 
> If you have a use case for connected UDP ipv6 flows with performance
> issues, then you might add early demux I guess.
> 
> IPv4 udp early demux has been a bit of a hack actually,
> as Shawn main usage was multicast AFAIK
> 
> 63c6f81cdde5 udp: ipv4: do not waste time in __udp4_lib_mcast_demux_lookup
> 610438b74496 udp: ipv4: fix potential use after free in udp_v4_early_demux()
> f69b923a758f udp: fix a typo in __udp4_lib_mcast_demux_lookup
> 421b3885bf6d udp: ipv4: Add udp early demux
> 
> 

I was more wondering if we can avoid the route the lookup.  It may not always be
a connected a case.  If you have multiple senders and a single receiver on the
same subnet, avoiding the route lookup with early demux might help.

-vlad
