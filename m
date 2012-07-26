From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 11:26:26 -0700
Message-ID: <CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
References: <1343290414.2626.11181.camel@edumazet-glaptop>
	<20120726.011853.973075299731735416.davem@davemloft.net>
	<1343291278.2626.11188.camel@edumazet-glaptop>
	<20120726.014736.1066206957795563053.davem@davemloft.net>
	<CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
	<1343323858.2626.11783.camel@edumazet-glaptop>
	<1343324175.2626.11790.camel@edumazet-glaptop>
	<1343324633.2626.11801.camel@edumazet-glaptop>
	<1343324896.2626.11808.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51796 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab2GZS01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 14:26:27 -0400
Received: by yenl2 with SMTP id l2so2294852yen.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 11:26:27 -0700 (PDT)
In-Reply-To: <1343324896.2626.11808.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 26, 2012 at 10:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-26 at 19:43 +0200, Eric Dumazet wrote:
>> On Thu, 2012-07-26 at 19:36 +0200, Eric Dumazet wrote:
>> > On Thu, 2012-07-26 at 19:31 +0200, Eric Dumazet wrote:
>> > > On Thu, 2012-07-26 at 10:18 -0700, Alexander Duyck wrote:
>> > >
>> > > > I tested this patch and it looks like it runs, but still has the same
>> > > > performance issue.  I did some digging into the annotation for
>> > > > ip_route_intput_noref and it seems like the issue is that I am hitting
>> > > > the dst_hold call in  __mkroute_input.
>> > >
>> > > David suggested a percpu cache.
>> > >
>> > > nh_rth_input would be allocated by alloc_percpu(struct dst *)
>> > >
>> > > I can work on this.
>> >
>> > Wait a minute, on input we should use the noref trick too.
>> >
>>
>> Something like : (on top of latest David patch)
>
> Sorry updated patch : (missing skb_dst_set() before 'out' label)

The previous results were with a slight modifications to your earlier
patch.  With this patch applied I am seeing 10.4Mpps with 8 queues,
reaching a maximum of 11.6Mpps with 9 queues.

When we have a final version for this patch let me know and I will
give it a quick run and throw in my tested by.

Thanks,

Alex
