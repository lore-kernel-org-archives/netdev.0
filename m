From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 21:15:28 -0700 (PDT)
Message-ID: <20120727.211528.1280331721532176100.davem@davemloft.net>
References: <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	<20120726.200846.66786272076299783.davem@davemloft.net>
	<20120726.230246.219188476590178857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2G1EP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:15:29 -0400
In-Reply-To: <20120726.230246.219188476590178857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Jul 2012 23:02:46 -0700 (PDT)

> Therefore one area of simplification would be to just return a pointer
> to the FIB nexthop, rather than the fib_info pointer and the nexthop
> index.  We can get to the fib_info, if we need to, via the nh_parent
> pointer of the nexthop.

So I'm about to post an RFC set of patches which show this kind
of simplification.  It gets fib_result down to two members:

	u32		tclassid;
	struct fib_nh	*nh;

If I could get rid of that tclassid it would be really nice.  But
that's hard because the tclassid is fetched from the fib_rule and
all of that lookup path is abstracted behind a common layer
that's shared between ipv4 and ipv6 so it's a bit of work changing
arg conventions.

These changes help, but only ever so slightly, in my testing.
