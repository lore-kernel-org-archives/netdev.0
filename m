From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Sun, 22 May 2016 12:30:11 -0400
Message-ID: <5741DE93.7090202@mojatatu.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36463 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbcEVQa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 12:30:28 -0400
Received: by mail-io0-f194.google.com with SMTP id a79so15083468ioe.3
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 09:30:28 -0700 (PDT)
In-Reply-To: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-19 08:35 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Large tc dumps (tc -s {qdisc|class} sh dev ethX) done by Google BwE host
> agent [1] are problematic at scale :
>
> For each qdisc/class found in the dump, we currently lock the root qdisc
> spinlock in order to get stats. Sampling stats every 5 seconds from
> thousands of HTB classes is a challenge when the root qdisc spinlock is
> under high pressure.
>

Good stuff.
There are other optimization we could do in such large scale dumps
(such as not dumping something that hasnt been updated)
Could we have changed it to be rcu?

> These stats are using u64 or u32 fields, so reading integral values
> should not prevent writers from doing concurrent updates if the kernel
> arch is a 64bit one.
>

Meaning it wont work on other archs? is atomic read not dependable
on other setups?


> Being able to atomically fetch all counters like packets and bytes sent
> at the expense of interfering in fast path (queue and dequeue packets)
> is simply not worth the pain, as the values are generally stale after 1
> usec.
>
> These lock acquisitions slow down the fast path by 10 to 20 %
>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
