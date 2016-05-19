From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 11:41:39 -0700
Message-ID: <573E08E3.3020200@hpe.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:40808 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933423AbcESSlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:41:42 -0400
In-Reply-To: <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2016 11:03 AM, Alexander Duyck wrote:
> On Thu, May 19, 2016 at 10:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> With HTB qdisc, here are the numbers for 200 concurrent TCP_RR, on a host with 48 hyperthreads.
...
>>
>> That would be a 8 % increase.
>
> The main point of the busy lock is to deal with the bulk throughput
> case, not the latency case which would be relatively well behaved.
> The problem wasn't really related to lock bouncing slowing things
> down.  It was the fairness between the threads that was killing us
> because the dequeue needs to have priority.

Quibbledrift... While the origins of the netperf TCP_RR test center on 
measuring latency, I'm not sure I'd call 200 of them running 
concurrently a latency test.  Indeed it may be neither fish nor fowl, 
but it will certainly be exercising the basic packet send/receive path 
rather fully and is likely a reasonable proxy for aggregate small packet 
performance.

happy benchmarking,

rick jones
