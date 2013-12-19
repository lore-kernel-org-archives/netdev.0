From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Thu, 19 Dec 2013 11:32:53 +0800
Message-ID: <52B268E5.4090008@huawei.com>
References: <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org> <52B172B9.7030609@huawei.com> <20131218102132.GB3505@order.stressinduktion.org> <52B18DB4.80403@gmail.com> <20131218142715.GC3505@order.stressinduktion.org> <52B1BB73.20005@gmail.com> <20131218154648.GD3505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<joe@perches.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5061 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab3LSDjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 22:39:08 -0500
In-Reply-To: <20131218154648.GD3505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 23:46, Hannes Frederic Sowa wrote:
> On Wed, Dec 18, 2013 at 11:12:51PM +0800, Ding Tianhong wrote:
>> =E4=BA=8E 2013/12/18 22:27, Hannes Frederic Sowa =E5=86=99=E9=81=93:
>>> On Wed, Dec 18, 2013 at 07:57:40PM +0800, Ding Tianhong wrote:
>>>> yes, I cannot repruduce the bug again.
>>>
>>> Hmm, it actually seems hard to hit even if the race happens. Even i=
f slab
>>> poisoning is active it would only hit if ->solicit would be called =
again,
>>> because that is the only pointer dereference directly used in the o=
ld memory.
>>>
>>> neigh_alloc allocates memory with kzalloc, so it would null out tha=
t memory,
>>> so the race would not only have to race with kfree, the memory need=
s to be
>>> reallocated in the mean time.
>>>
>>> I would suggest adding some poisoning manually in neigh_release bef=
ore kfree
>>> and check for this in all periodic called functions. Maybe we can s=
ee it
>>> again?
>>>
>> Great, thanks for your help, I think make the neigh_release not kfre=
e neighbour until
>> the timer is over is a clear way to  fix this, maybe you could anoth=
er idea, glad to
>> hear your opinion.
>=20
> But I don't suggest this as an fix, just as a help for debugging this=
 issue.
>=20
> Maybe you could also store the _RET_IP_ in the to be freed struct nei=
ghbour
> (just before kfree) and thus have it available in case the machine pa=
nics (or
> simply print it with printk).
>=20
> Maybe it would make sense to use kmem_cache_create and kmem_cache_all=
oc for
> struct neighs so we can better utilize the slub debugging features.
>=20
> Greetings,
>=20
>   Hannes
>=20
>=20

Good idea, I will try it, but I still could not make it happen again.

I can repeat the process that the problem happed:

(1).A: xxx.xxx.xxx.83, B:xxx.xxx.xxx.84
(2). down A, B instead of A, ifconfig B xxx.xxx.xxx.83
(3).use "/sbin/arping -I %s -U -b -c 1 -w 4 %s "to tell vlan B is xxx.x=
xx.xxx.83,
(4). then it happened.=20

Regards
Ding
> .
>=20
