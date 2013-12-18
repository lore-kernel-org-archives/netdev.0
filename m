From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 10:28:15 +0100
Message-ID: <20131218092815.GA3505@order.stressinduktion.org>
References: <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com> <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35772 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab3LRJ2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:28:17 -0500
Content-Disposition: inline
In-Reply-To: <52B1635D.7020205@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 04:57:01PM +0800, Ding Tianhong wrote:
> On 2013/12/18 16:41, Hannes Frederic Sowa wrote:
> > On Wed, Dec 18, 2013 at 04:19:43PM +0800, Ding Tianhong wrote:
> >> 0xffffffff812f8e29 <neigh_timer_handler+265>:   mov    0xe8(%rbx),%rax
> >> 0xffffffff812f8e30 <neigh_timer_handler+272>:   mov    %rbp,%rsi
> >> 0xffffffff812f8e33 <neigh_timer_handler+275>:   mov    %rbx,%rdi
> >> 0xffffffff812f8e36 <neigh_timer_handler+278>:   callq  *0x8(%rax)						<-----crash
> >> /usr/src/linux/net/core/neighbour.c: 877
> >> 0xffffffff812f8e39 <neigh_timer_handler+281>:   lea    0x3c(%rbx),%rax
> > 
> > For me it looks like this:
> > 
> > %rax is neigh->ops and the function pointer solicit is NULL and causes the the
> > page fault.
> > 
> > 
> yes, it is. So I was trying to find the situation that may free the neighbour when
> the timer is running, but I could not yet.

Hm. Ok. It is actually ops which is NULL, not the function pointer, may bad.

Could you try to follow param or table links and check if this is an arp or
ndisc one? Maybe some interactions with arp.c or ndisc.c causes this bug?
