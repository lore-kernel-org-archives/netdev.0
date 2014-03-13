From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 1/2] netpoll: Remove dead netpoll_rx code
Date: Thu, 13 Mar 2014 13:46:17 -0700
Message-ID: <87eh256d46.fsf@xmission.com>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40956 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755040AbaCMUqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:46:25 -0400
In-Reply-To: <20140313.152311.1995854418463980325.davem@davemloft.net> (David
	Miller's message of "Thu, 13 Mar 2014 15:23:11 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 11 Mar 2014 13:48:01 -0700
>
>> To play devil's advocate to my own patch.  Does anyone know where kgdb
>> over network (kgdboe) code lives today?
>> 
>> What little I could find in a quick google search strongly suggests that
>> kgdboe was abandoned in 2010 or so.
>> 
>> I am trying to figure out if there are any active out of tree projects
>> that need by directional netpoll.
>
> Good questions.
>
> I, perhaps mistakenly, kept the functionality around because there
> were claims that we'd use it in-tree.
>
> That of course never materialized.
>
> The fact that people have a lot of trouble even finding the kgdboe
> sources is quite telling, indeed.

Also telling is that we actually broken kgdboe support in 2011 when
netpoll_poll was removed.

> Let's kill it, we can pull it back in (perhaps with a better design)
> if something is proposed in-tree that will need it.

Sounds good.  Patches to follow shortly.

> But I'm skeptical we ever will need it, and even if such a
> reinstatement is proposed f.e. for the kgdboe use case it has holes.
>
> Consider the case where kgdboe takes a breakpoint in a hardware
> interrupt handler.  What happens?  We cannot allow it to perform a
> full back-and-forth conversation with the remote gdb from such a
> context.

In interests of full disclosure I missed a subtle detail, and what
the code does today is that when netpoll_poll_dev is running is that it
intercepts and drops all in-coming packets.

So I think the current packet receive design might be salvaged, if
someone gets interested again.  The bitrot is pretty significant
currently.

Still I should point out that the code that drops received skbs is
technically wrong today.  It uses kfree_skb, instead of the needed
dev_kfree_skb_any that is needed to work in any context netpoll_rx
might be called in.

Eric
