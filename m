From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 16:46:48 +0100
Message-ID: <20131218154648.GD3505@order.stressinduktion.org>
References: <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org> <52B172B9.7030609@huawei.com> <20131218102132.GB3505@order.stressinduktion.org> <52B18DB4.80403@gmail.com> <20131218142715.GC3505@order.stressinduktion.org> <52B1BB73.20005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36642 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099Ab3LRPqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 10:46:49 -0500
Content-Disposition: inline
In-Reply-To: <52B1BB73.20005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 11:12:51PM +0800, Ding Tianhong wrote:
> =E4=BA=8E 2013/12/18 22:27, Hannes Frederic Sowa =E5=86=99=E9=81=93:
> > On Wed, Dec 18, 2013 at 07:57:40PM +0800, Ding Tianhong wrote:
> >> yes, I cannot repruduce the bug again.
> >=20
> > Hmm, it actually seems hard to hit even if the race happens. Even i=
f slab
> > poisoning is active it would only hit if ->solicit would be called =
again,
> > because that is the only pointer dereference directly used in the o=
ld memory.
> >=20
> > neigh_alloc allocates memory with kzalloc, so it would null out tha=
t memory,
> > so the race would not only have to race with kfree, the memory need=
s to be
> > reallocated in the mean time.
> >=20
> > I would suggest adding some poisoning manually in neigh_release bef=
ore kfree
> > and check for this in all periodic called functions. Maybe we can s=
ee it
> > again?
> >
> Great, thanks for your help, I think make the neigh_release not kfree=
 neighbour until
> the timer is over is a clear way to  fix this, maybe you could anothe=
r idea, glad to
> hear your opinion.

But I don't suggest this as an fix, just as a help for debugging this i=
ssue.

Maybe you could also store the _RET_IP_ in the to be freed struct neigh=
bour
(just before kfree) and thus have it available in case the machine pani=
cs (or
simply print it with printk).

Maybe it would make sense to use kmem_cache_create and kmem_cache_alloc=
 for
struct neighs so we can better utilize the slub debugging features.

Greetings,

  Hannes
