From: Wei Huang <daviseago@gmail.com>
Subject: Re: Which one is chosen on multiple default gateway set?
Date: Thu, 23 Aug 2012 15:30:21 +0800
Message-ID: <CAJPS4yZ-dO7Jau6R1V=jBh9xHWjfA-PaiURGzjtGo8TwmDcjSA@mail.gmail.com>
References: <CAJPS4yY7sqqsOfhiouqjmfuW3Kof-ZzHEBs9E1+QoYYce01U4Q@mail.gmail.com>
	<20120822.233808.1184757734447108096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64734 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894Ab2HWHaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:30:21 -0400
In-Reply-To: <20120822.233808.1184757734447108096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 2:38 PM, David Miller <davem@davemloft.net> wrote:
> The problem is that when a nexthop becomes unresponsive we need
> to wait for an event to timeout the routing cache entry.
>
> In 3.6.0-rc1 and later, this inconsistent behavior will happen less
> often, because the routing cache has been removed so we will do the
> full default route resolution on every route lookup.  The only problem
> at that point is socket cached routes, those will still need to wait
> for a timeout before the next default gateway will be tried.

Thanks a lot, David!

I'm using 2.6.16. Could you tell me where the code is, that detects
nexthop unresponsive, sends an event, and timeout the cache? Or are
there procs or sysctl to adjust the timer values?

Another thing I found is that the route looking-up seems to update the
routing cache entry. Is that true? In my example in the first mail,
after a while, the default gateway should have been switched to the
second one. If I ping 8.8.8.8 then, the second active gateway should
be used. But instead, if I look for the route first with "ip r get
8.8.8.8", the first inactive gateway will be the result, and it will
be used if I ping now.
Will the route looking-up even influence the behavior? Will there be a
work around way for this?

Thanks,
Wei
