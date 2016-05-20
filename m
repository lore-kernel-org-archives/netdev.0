From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Fri, 20 May 2016 09:01:09 -0700
Message-ID: <573F34C5.1010801@gmail.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
 <20160520092903.38620c60@redhat.com>
 <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34898 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbcETQBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 12:01:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id b66so11725428pfb.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 09:01:24 -0700 (PDT)
In-Reply-To: <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-20 06:11 AM, Eric Dumazet wrote:
> On Fri, 2016-05-20 at 09:29 +0200, Jesper Dangaard Brouer wrote:
> 
> 
>> The hole idea behind allowing bulk qdisc dequeue, was to mitigate this,
>> by allowing dequeue to do more work, while holding the lock.
>>
>> You mention HTB.  Notice HTB does not take advantage of bulk dequeue.
>> Have you tried to enable/allow HTB to bulk dequeue?
>>
> 
> Well, __QDISC___STATE_RUNNING means exactly that : one cpu is dequeueing
> many packets from the qdisc and tx them to the device.
> 
> It is generic for any kind of qdisc.
> 
> HTB bulk dequeue would have to call ->dequeue() mutiple times. If you do
> this while holding qdisc spinlock, you block other cpus from doing
> concurrent ->enqueue(), adding latencies (always the same trade off...)
> 
> HTB wont be anytime soon have separate protections for the ->enqueue()
> and the ->dequeue(). Have you looked at this monster ? I did, many
> times...
> 

I came to the conclusion that we just need to rewrite a new modern
version of HTB at some point. Easier said than done however.

> Note that I am working on a patch to transform __QDISC___STATE_RUNNING
> to a seqcount do that we can grab stats without holding the qdisc lock.
> 
> 
> 
> 
