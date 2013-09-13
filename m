From: Andy Johnson <johnsonzjo@gmail.com>
Subject: Re: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 21:26:08 +0300
Message-ID: <CAF0Lin0WvJU8W1LErQjs+ZRq8_mrwX7femuByvM3i7VhQrdbpw@mail.gmail.com>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
	<CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
	<20130913164404.GA32431@order.stressinduktion.org>
	<CAOp4FwQ6YWpMtZ9-64tVDc29RhtiUjwinQjZ32mjEu_pZfRHHA@mail.gmail.com>
	<20130913181712.GA29989@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Loganaden Velvindron <loganaden@gmail.com>,
	Andy Johnson <johnsonzjo@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:61654 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab3IMS0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 14:26:10 -0400
Received: by mail-wg0-f43.google.com with SMTP id z12so1468422wgg.34
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 11:26:08 -0700 (PDT)
In-Reply-To: <20130913181712.GA29989@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My question was out of pure interest and not because of any practical
need. However, preparing a patch for supporting rate limiting for
ICMPv6 is easy and I am ready to do it. I want to know before, what
other people think about it - is it needed ?

regards,
Andy


On Fri, Sep 13, 2013 at 9:17 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Sep 13, 2013 at 09:26:11PM +0400, Loganaden Velvindron wrote:
>> On Fri, Sep 13, 2013 at 8:44 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > On Fri, Sep 13, 2013 at 06:57:56PM +0300, Andy Johnson wrote:
>> >> Hello,
>> >> After probing into the RFC of ICMPv6, I am even more confused.
>> >>
>> >> RFC 4443 says:
>> >>
>> >> 2.4.  Message Processing Rules
>> >> ...
>> >>
>> >> (f) Finally, in order to limit the bandwidth and forwarding costs
>> >>        incurred by originating ICMPv6 error messages, an IPv6 node MUST
>> >>        limit the rate of ICMPv6 error messages it originates.
>> >> ...
>> >> The rate-limiting parameters SHOULD be configurable.
>> >> ...
>> >>
>> >> Any ideas?
>> >
>> > Well, nobody has implemented it because nobody missed the feature yet. I
>> > don't believe there is another reason for that. If you come up with a
>> > patch, I am sure it can go upstream.
>> >
>> > Do you want to try to come up with a patch? We need to be a bit
>> > careful regarding neighbor discovery but otherwise this should be
>> > relativ straightforward. In the meantime you could also implement such
>> > ratelimiting with netfilter.
>>
>> Careful ? Can you please elaborate ?
>
> From my memory I knew we have rate limiting for redirect messages,
> so I assuemed the rate limiter would be on the ndisc_send* path. But
> ratelimiting ndisc redirects is a special case and only happens in
> ndisc_send_redirect. I assuemd we would need to special case
> icmpv6_xrlim_allow to always pass ndisc ns/na packets, sorry.
>
> Maybe we could also switch to icmpv6_xrlim_allow for redirects to make
> this configurable?
>
> Btw. for sending redirects we seem to call inet_peer_xrlim_allow once
> in the redirect function but also check it in ip6_forward. Maybe we can
> drop the check in ip6_forward?
>
> Greetings,
>
>   Hannes
>
