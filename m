From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Mon, 23 Dec 2013 14:14:04 -0800
Message-ID: <CAM_iQpWarY7kHNCtVdYqMVdADFbCUmDsAVQz1+iEx9JKsdZN5w@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
	<52B1FC6D.7040005@mojatatu.com>
	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
	<52B71024.3090504@mojatatu.com>
	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
	<52B74C3A.1050900@mojatatu.com>
	<CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
	<52B82F80.8070902@mojatatu.com>
	<CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>
	<52B89FEB.9090503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:57056 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab3LWWOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 17:14:06 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so5944839obc.37
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 14:14:04 -0800 (PST)
In-Reply-To: <52B89FEB.9090503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 12:41 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Now if you have such a graph:

Making such an abstraction only helps misunderstanding, really...

> What you cannot do is, on your own as kernel, decide you want to delete
> one action that is _bound_ to a filter because one of its attributes is
> gone berserk. It doesnt matter whether such an action is mirred or foo
> or whether D and E dont exist. You can put a big hole where the town
> used to be and leave roads leading to the town.

Again, since (non-shared) actions attached to a filter are chained by
a doubly linked list, why not?

> It will still be referenced by things preeceding it (primarily the
> classifier which keeps an action chain intact), which is bad when the
> next packet arrives.

You know, there is a head for such linked list for the filter to refer,
so what's the problem with deleting a node from a linked list if
we lock it properly? In non-shared case, no filter can refer to any
action without the head of the chain, right? So what is the problem
of "referenced by things preeceding it" when they are linked and locked
properly?

> You let the user/control program which is monitoring things do that
> and "reroute" around the problem. If you insist on putting a little part
> of the medula oblangata in the stomach, then:
> the only correct way to do it is delete the filter.

Apparent not, different actions can attached to the same filter
and only mirred action has a target dev.

> And you start doing that you are making some serious policy decisions
> in the kernel and adding lots of complexity.
>

Why removing a filter when the netdev is removed is not policy?
Actually it is, ONLY that it is not be able to shared with current
implementation.

Since you love mechanism _so much_, why not make filters shared
by other qdisc's and stop removing them when netdev is gone in kernel?

Be realistic, Jamal, user-space is hard, you can't simply let user-space
decide everything, especially when you don't provide a simple way to do it.
Netlink is already hard to use, even with libnl, since it enforces a cache
layer. Sit down and spend some time to write some libnl code, compare it
with this patch.
