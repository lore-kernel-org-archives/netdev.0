From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 20:17:12 +0200
Message-ID: <20130913181712.GA29989@order.stressinduktion.org>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com> <CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com> <20130913164404.GA32431@order.stressinduktion.org> <CAOp4FwQ6YWpMtZ9-64tVDc29RhtiUjwinQjZ32mjEu_pZfRHHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Johnson <johnsonzjo@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56357 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384Ab3IMSRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 14:17:14 -0400
Content-Disposition: inline
In-Reply-To: <CAOp4FwQ6YWpMtZ9-64tVDc29RhtiUjwinQjZ32mjEu_pZfRHHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 09:26:11PM +0400, Loganaden Velvindron wrote:
> On Fri, Sep 13, 2013 at 8:44 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Fri, Sep 13, 2013 at 06:57:56PM +0300, Andy Johnson wrote:
> >> Hello,
> >> After probing into the RFC of ICMPv6, I am even more confused.
> >>
> >> RFC 4443 says:
> >>
> >> 2.4.  Message Processing Rules
> >> ...
> >>
> >> (f) Finally, in order to limit the bandwidth and forwarding costs
> >>        incurred by originating ICMPv6 error messages, an IPv6 node MUST
> >>        limit the rate of ICMPv6 error messages it originates.
> >> ...
> >> The rate-limiting parameters SHOULD be configurable.
> >> ...
> >>
> >> Any ideas?
> >
> > Well, nobody has implemented it because nobody missed the feature yet. I
> > don't believe there is another reason for that. If you come up with a
> > patch, I am sure it can go upstream.
> >
> > Do you want to try to come up with a patch? We need to be a bit
> > careful regarding neighbor discovery but otherwise this should be
> > relativ straightforward. In the meantime you could also implement such
> > ratelimiting with netfilter.
> 
> Careful ? Can you please elaborate ?

>From my memory I knew we have rate limiting for redirect messages,
so I assuemed the rate limiter would be on the ndisc_send* path. But
ratelimiting ndisc redirects is a special case and only happens in
ndisc_send_redirect. I assuemd we would need to special case
icmpv6_xrlim_allow to always pass ndisc ns/na packets, sorry.

Maybe we could also switch to icmpv6_xrlim_allow for redirects to make
this configurable?

Btw. for sending redirects we seem to call inet_peer_xrlim_allow once
in the redirect function but also check it in ip6_forward. Maybe we can
drop the check in ip6_forward?

Greetings,

  Hannes
