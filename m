From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 16:57:01 +0800
Message-ID: <52B1635D.7020205@huawei.com>
References: <20131203.232122.852236751455974887.davem@davemloft.net> <529EC95A.5080908@huawei.com> <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com> <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<joe@perches.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:62658 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab3LRI7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:59:08 -0500
In-Reply-To: <20131218084106.GF27460@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 16:41, Hannes Frederic Sowa wrote:
> On Wed, Dec 18, 2013 at 04:19:43PM +0800, Ding Tianhong wrote:
>> 0xffffffff812f8e29 <neigh_timer_handler+265>:   mov    0xe8(%rbx),%rax
>> 0xffffffff812f8e30 <neigh_timer_handler+272>:   mov    %rbp,%rsi
>> 0xffffffff812f8e33 <neigh_timer_handler+275>:   mov    %rbx,%rdi
>> 0xffffffff812f8e36 <neigh_timer_handler+278>:   callq  *0x8(%rax)						<-----crash
>> /usr/src/linux/net/core/neighbour.c: 877
>> 0xffffffff812f8e39 <neigh_timer_handler+281>:   lea    0x3c(%rbx),%rax
> 
> For me it looks like this:
> 
> %rax is neigh->ops and the function pointer solicit is NULL and causes the the
> page fault.
> 
> 
yes, it is. So I was trying to find the situation that may free the neighbour when
the timer is running, but I could not yet.

Regards
Ding

> 
