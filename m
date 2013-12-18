From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 15:27:15 +0100
Message-ID: <20131218142715.GC3505@order.stressinduktion.org>
References: <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org> <52B172B9.7030609@huawei.com> <20131218102132.GB3505@order.stressinduktion.org> <52B18DB4.80403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36466 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab3LRO1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:27:17 -0500
Content-Disposition: inline
In-Reply-To: <52B18DB4.80403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 07:57:40PM +0800, Ding Tianhong wrote:
> yes, I cannot repruduce the bug again.

Hmm, it actually seems hard to hit even if the race happens. Even if slab
poisoning is active it would only hit if ->solicit would be called again,
because that is the only pointer dereference directly used in the old memory.

neigh_alloc allocates memory with kzalloc, so it would null out that memory,
so the race would not only have to race with kfree, the memory needs to be
reallocated in the mean time.

I would suggest adding some poisoning manually in neigh_release before kfree
and check for this in all periodic called functions. Maybe we can see it
again?

Greetings,

  Hannes
