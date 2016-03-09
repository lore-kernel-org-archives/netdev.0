From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 09 Mar 2016 12:24:00 -0500 (EST)
Message-ID: <20160309.122400.951958972682394628.davem@davemloft.net>
References: <20160309163919.GJ2207@uranus.lan>
	<20160309165850.GA49579@ast-mbp.thefacebook.com>
	<20160309170921.GL2207@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbcCIRYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:24:03 -0500
In-Reply-To: <20160309170921.GL2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 9 Mar 2016 20:09:21 +0300

> On Wed, Mar 09, 2016 at 08:58:52AM -0800, Alexei Starovoitov wrote:
> ...
>> 
>> above line is an indication that you have:
>> #if defined(CONFIG_DEBUG_PREEMPT) || defined(CONFIG_PREEMPT_TRACER)
>> turning it off will speed up things significantly.
> 
> Look, this won't change the overall picture. For sure it will
> speedup the kernel but it won't prevent the users from allowing
> allocating addresses. So timings will drop a bit but the main
> issue will remain -- there is no explicit way to limit this
> resource. We can create say 1K of netnamespaces and allocate
> 100K addresses in each, then start destorying the namespaces
> and node gonna be unreachable until everything is freed. The
> kernel works as it shold simply in case of highload is stops
> react due to big number of rtnl-locks taken.

We asked you for numbers without a lot of features enabled, it'll
help us diagnose which subsystem still causes a lot of overhead
much more clearly.

So please do so.

Although it's already pretty clear that netfilter conntrack
cleanup is insanely expensive.

You're also jumping to a lot of conclusions, work with us to fix the
fundamental performance problems rather than continually insisting on
a limit.

We should be able to remove millions of IP addresses in less than
half a second, no problem.  Limits make no sense at all.
