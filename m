From: Jason Baron <jbaron@akamai.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 17:40:47 -0500
Message-ID: <5490B4EF.1030803@akamai.com>
References: <CAADnVQJ+8mtB8LD=U7XbxOC2hxhDChxOELhZ3NEYeoTk1G3LYg@mail.gmail.com> <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com> <548F0F62.7080704@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Josef Bacik <jbacik@fb.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:63969 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbaLPWkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:40:49 -0500
In-Reply-To: <548F0F62.7080704@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2014 11:42 AM, Josef Bacik wrote:
> On 12/15/2014 11:03 AM, Eric Dumazet wrote:
>> On Sun, 2014-12-14 at 22:55 -0800, Alexei Starovoitov wrote:
>>
>>> I think patches 1 and 3 are good additions, since they establish
>>> few permanent points of instrumentation in tcp stack.
>>> Patches 4-5 look more like use cases of tracepoints established
>>> before. They may feel like simple additions and, no doubt,
>>> they are useful, but since they expose things via tracing
>>> infra they become part of api and cannot be changed later,
>>> when more stats would be needed.
>>> I think systemtap like scripting on top of patches 1 and 3
>>> should solve your use case ?
>>> Also, have you looked at recent eBPF work?
>>> Though it's not completely ready yet, soon it should
>>> be able to do the same stats collection as you have
>>> in 4/5 without adding permanent pieces to the kernel.
>>
>> So it looks like web10g like interfaces are very often requested by
>> various teams.
>>
>> And we have many different views on how to hack this. I am astonished by
>> number of hacks I saw about this stuff going on.
>>
>> What about a clean way, extending current TCP_INFO, which is both
>> available as a getsockopt() for socket owners and ss/iproute2
>> information for 'external entities'
>>
>> If we consider web10g info needed, then adding a ftrace/eBPF like
>> interface is simply yet another piece of code we need to maintain,
>> and the argument of 'this should cost nothing if not activated' is
>> nonsense since major players need to constantly monitor TCP metrics and
>> behavior.
>>
>> It seems both FaceBook and Google are working on a subset of web10g.
>>
>> I suggest we meet together and establish a common ground, preferably
>> after Christmas holidays.
>>
>
> We've set up something for exactly this case at the end of January but
> have yet to get a response from Google.  If any of the Google people
> cc'ed (or really anybody, its not a strictly FB/Google thing) is
> interested please email me directly and I'll send you the details, we
> will be meeting face to face in the bay area at the end of January. 
> Thanks,
>
> Josef

We are interested in tcp tracing as well. Another requirement that we
have that
I don't think I saw is the ability to start/stop tracing on sockets
(potentially
multiple times) during the lifetime of a connection. So for example, the
ability
to use setsockopt(), to selectively start/stop tracing on a connection,
so as not
to incur overhead for non-traced sockets.

Thanks,

-Jason
