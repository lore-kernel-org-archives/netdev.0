From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 18:50:29 -0700
Message-ID: <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33755 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbcETBut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 21:50:49 -0400
Received: by mail-yw0-f195.google.com with SMTP id y6so12972603ywe.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:50:49 -0700 (PDT)
In-Reply-To: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> These stats are using u64 or u32 fields, so reading integral values
> should not prevent writers from doing concurrent updates if the kernel
> arch is a 64bit one.
>
> Being able to atomically fetch all counters like packets and bytes sent
> at the expense of interfering in fast path (queue and dequeue packets)
> is simply not worth the pain, as the values are generally stale after 1
> usec.

I think one purpose of this lock is to make sure we have an atomic
snapshot of these counters as a whole. IOW, we may need another
lock rather than the qdisc root lock to guarantee this.
