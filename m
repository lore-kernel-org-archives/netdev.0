From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPV6 routing problem
Date: Wed, 22 Jan 2014 08:07:59 +0100
Message-ID: <20140122070759.GB28225@order.stressinduktion.org>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57130 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaAVHIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:08:14 -0500
Content-Disposition: inline
In-Reply-To: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Jan 21, 2014 at 06:41:58PM -0700, Sharat Masetty wrote:
>  I have an IPV6 routing problem that has only surfaced on a 3.10
> kernel version. This problem is not seen on 3.4 kernel. I will keep
> the problem statement as brief as possible.

Could you do me a favor and test this on a recent 3.13 kernel? Thanks!
Please also state the specific kernel version (I guess you use one).

> I have two interfaces say eth0 and eth1. I have a host route to a
> destination over eth1, but this route has a global gateway
> address(via) of the router on the link. When this global gateway is
> present in the route, the kernel does not seem to pick up the route,
> but falls back to the default route which is eth0. When this gateway
> is removed from the route or if the gateway is changed to a link local
> address of the router, instead of the global address, then routing
> seems to work as expected and kernel picks up interface eth1.
> 
> == does not work ==
> <dest-addr> via <global scope -gateway addr>dev eth1 metric 1024
> <global scope -gateway addr> dev eth1  metric 1024

Do you have CONFIG_IPV6_ROUTER_PREF activated?

> 
> I checked the git commits diff between 3.4 and 3.10 for ipv6/route.c
> and ipv6/ip6_fib.c, but looks like they are close to an year apart
> with lots of changes. Hence I wanted to reach out to you to see if any
> recent changes in IPV6 routing is causing this difference in behavior.

It should be a problem in ipv6/route.c, ip6_fib.c does not really care about
interfaces that much.

Thanks,

  Hannes
