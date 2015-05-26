From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 0/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 11:00:40 -0700
Message-ID: <CALx6S34DxrhBvnMyovQFF+Kzpvx3h6=Nviu7XOegPsZa71KrvA@mail.gmail.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	<1432660689.4060.275.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38233 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbEZSAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:00:41 -0400
Received: by igcau1 with SMTP id au1so59555919igc.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 11:00:41 -0700 (PDT)
In-Reply-To: <1432660689.4060.275.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 10:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-05-26 at 09:34 -0700, Tom Herbert wrote:
>> Added matching of CPU to a socket CPU mask. This is useful for TCP
>> listeners and unconnected UDP. This works with SO_REUSPORT to steer
>> packets to listener sockets based on CPU affinity. These patches
>> allow steering packets to listeners based on numa locality. This is
>> only useful for passive connections.
>>
>> v2:
>>   - Add cache alignment for fields used in socket lookup in sock_common
>>   - Added UDP test results
>
> What about the feedback I gave earlier Tom ???
>
> This cannot work for TCP in its current state.
>
It does work and it fixes cache server locality issues we are seeing.
Right now half of our connections are persistently crossing numa nodes
on receive-- this is having big negative impact. Yes, there may be
edge conditions where SYN goes to a different CPU than the rest of the
flow (probably need RFS or flow director for that problem), and that
sounds like something nice to fix, but this patch is not dependent on
that. Besides, did you foresee an API change would be required?

>
