From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: locating the 'tc actions' hook
Date: Sun, 11 Aug 2013 20:55:09 -0400
Message-ID: <5208326D.5030903@mojatatu.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com> <51FAECBF.3030704@intel.com> <51FCEDCF.8010107@mojatatu.com> <51FFCEB3.3010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:50065 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189Ab3HLAzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 20:55:13 -0400
Received: by mail-ie0-f181.google.com with SMTP id x14so7265200ief.40
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 17:55:13 -0700 (PDT)
In-Reply-To: <51FFCEB3.3010404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-08-05 12:11 PM, John Fastabend wrote:

> Actually in the first case here I was considering egress traffic.
>


[..]
> Separating the classifier chain from the qdisc allows using the
> classifiers to pick a qdisc via queue_mapping because qdisc's are
> attached to queues when using sch_mq.
>

[..]
> Sorry I mucked two examples one egress and one ingress together without
> clearly stating it. The second case here was ingress the first egress.
>

Ok. Still fine; if a tag of some form exists, the driver should be
able to inherit it and pass it down to the hardware.
There's akready precedence on such offloading, this should just
follow in the same spirit.

> But currently we have a situation on egress where multiqueue devices
> use mq or mqprio which aligns qdisc's with queues. This fixes the
> performance penalties but you lose the ability to have state across
> multiple queues and the ability to bind flows to queues.
>

If the goal is to share resources, there's no way to avoid locks.
You have to update resource usage state which is a write operation.
Dont even bother with rcu.

> For example a SW rate limiter that applies to a set of queues or a set
> of tuned low latency queues. To fix this we can attach a qdisc (htb,
> whatever) to the netdev but this has performance penalties. So we are
> left with a trade off between functionality and performance.
>
> On the ingress side we may have many queues but as soon as we add a
> qdisc/classifier/action we have a single lock.
>

[..]
> Thanks. I'll see if I can draw up what I'm thinking here a bit more
> clearly and send it your way.

I think that would help me. Maybe we should take it offline and sync up.

cheers,
jamal
