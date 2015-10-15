From: Nikolay Borisov <n.borisov@siteground.com>
Subject: Re: [PATCH v2] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Thu, 15 Oct 2015 23:20:04 +0300
Message-ID: <CAJFSNy6TaL1padva6euP1-8XFFwPFnBYgsMaEmeWrHpf8AJM-A@mail.gmail.com>
References: <1444906569-9131-1-git-send-email-kernel@kyup.com>
	<1444915978.4200.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<561FAD24.4050708@kyup.com>
	<1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
	<1444934818.25595.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Nikolay Borisov <kernel@kyup.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36181 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbbJOUUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 16:20:06 -0400
Received: by oihr205 with SMTP id r205so52880215oih.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 13:20:04 -0700 (PDT)
In-Reply-To: <1444934818.25595.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 9:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-10-15 at 20:25 +0200, Jozsef Kadlecsik wrote:
>
>> Nikolay answered this pretty well: we wouldn't need the spinlock at all,
>> because all commands are serialized anyway with the netlink mutex. But the
>> garbage collector is called by a timer and therefore spinlock is used.
>>
>
> Good, please Nikolay, send a v2 of the patch with all these details
> explained in the changelog, so that we can all agree.

While GFP_ATOMIC does indeed look the correct solution for this particular
case I was wondering whether something like (GFP_KERNEL & ~__GFP_WAIT)
wouldn't also make the cut without causing sleeping? I guess this is exactly
the sort of situation that Mel Gorman's patch can address
(marc.info/?l=linux-kernel&m=144283282101953) ?

In any case I will send v2 tomorrow.

>
> If properly explained, no need to add the stack trace which does not
> really tell us the story.
>
> Thanks !
>
>
>
