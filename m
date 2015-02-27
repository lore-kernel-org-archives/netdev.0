From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] netns: correct gfp flags for alloc_netid()
Date: Thu, 26 Feb 2015 18:19:41 -0800
Message-ID: <CAM_iQpV=wjuOfWvqRYbr+J9mA1Fa6YG9QvY9P0gnd9LYOeVGYA@mail.gmail.com>
References: <1424998490-9565-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425001791.5565.180.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46132 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbB0CTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 21:19:42 -0500
Received: by pablj1 with SMTP id lj1so2764291pab.13
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 18:19:41 -0800 (PST)
In-Reply-To: <1425001791.5565.180.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 5:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-02-26 at 16:54 -0800, Cong Wang wrote:
>> This fixes the following kernel warning:
>>
>>  ===============================
>>  [ INFO: suspicious RCU usage. ]
>>  3.19.0+ #805 Tainted: G        W
>>  -------------------------------
>>  include/linux/rcupdate.h:538 Illegal context switch in RCU read-side critical section!
>>
>>  other info that might help us debug this:
>>
>
> I do not think this is the right way to fix this.
>
> Bug is that rtnl_dump_ifinfo() should not use rcu_read_lock(), as RTNL
> is held : GFP_KERNEL allocations in control path should be the golden
> rule.
>
> I guess I should have reverted e67f88dd12f6 completely
> instead of the partial revert (2907c35ff647080)


LOL, it has been changed back and forth.

I thought rcu read lock was introduced to optimize dumping
performance, if it were really important, we should solve the
deadlock you mentioned in commit 2907c35ff647080?

Otherwise, as you said, completely revert to using rtnl lock.

Or for now just use my patch since idr doesn't allocate that
much memory in atomic?
