From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Re: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 4 Jun 2014 23:11:05 +0530
Message-ID: <CAJMXqXbf_bua3X8Q6-xutSutY7UYNtt+u=tCTaSBqb1NuKsS3w@mail.gmail.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	<CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	<1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJMXqXaqXG03e+OHr0aMh9x_N4BzBVWTkQLKgNVvq-QmDaX5Ng@mail.gmail.com>
	<1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.ne
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:60953 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaFDRlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 13:41:07 -0400
Received: by mail-ve0-f171.google.com with SMTP id oz11so9191976veb.2
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 10:41:05 -0700 (PDT)
In-Reply-To: <1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,


On Wed, Jun 4, 2014 at 8:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-06-04 at 19:23 +0530, Suprasad Mutalik Desai wrote:
>
>> I understood from you that the old route cache mechanism had DoS
>> vulnerabilities, so the new mechanism is implemented. What I am trying
>> to figure out is whether that will cause the kind of throughput drop
>> that I am seeing ?
>>
>> TCP performance
>>             - Upstream : 140 Mbps(Linux 2.6.32) --> 101Mbps (Linux 3.10.12)
>>             - Downstream : 148 Mbps(Linux 2.6.32) --> 106Mbps (Linux 3.10.12)
>
> Sure.
>
> A cache is supposed to help performance, right ?
>
> Problem with IPv4 route cache is that is was too easy to flood it and
> get worse performance.
>
> It had simply huge memory costs, and non predictable behavior [1]
>
> Better have a system behaving correctly at 99 percentile,
> than a system working well _only_ if workload is very gentle.
>
>
> [1] Well, sort of : prediction was : it's so easy to remotely crash the
> host.
>
> Your host has very little cache on cpu, very little bandwidth, so the
> previous IPv4 cache was probably helping.
>

Yes , you are correct . We are working on an embedded router which has
limited cache .

So, could you please suggest on how to address this topic w.r.t
embedded devices ( routers) which has limited memory resources ?

> Its yet not clear why a router has to checksum TCP packets.
>
> Maybe a conntracking requirement...
>

Yes, in our case the checksum is done in Linux stack as NIC doesn't
support checksum offloading .
